"""
G-code generator for a 2D (X/Y only) hot-wire cutter that cuts circles out
of a long block of foam, feeding the block in with a Z-axis feeder.

WHAT IT PRODUCES

  The block is cut in WINDOWS: one window is the patch of material that
  is reachable by the wire in its current position. A window is
  ROWS_PER_WINDOW rows tall and BLOCK_WIDTH wide (the full width of the
  foam block). After a window is cut, the feeder pushes exactly one
  window's worth of material past the wire and the next window is cut,
  until the stock runs out (LEAVE_UNCUT left behind).

  Circles are packed hexagonally: every other row is shifted right by
  one radius, and the row pitch is diameter * sqrt(3)/2 (+ Y_GAP), so
  rows nest into each other. Whatever width is left over at the ends of
  a row (the half-diameter left margin on offset rows, and whatever
  doesn't divide evenly on the right) is filled with the largest circle
  from DIAMETER_OPTIONS that fits, and the rest is cut away as a plain
  straight cut.

  SQUISH_ROOM is a per-edge inset: the pattern is planned on a width of
  BLOCK_WIDTH - 2*SQUISH_ROOM and then shifted right by SQUISH_ROOM, so
  neither edge of the pattern sits exactly on the edge of the material.
  The same inset is applied once in Y, at the very start of the job
  (first window only), via y_start. Y_GAP_WINDOW adds a little extra
  slack at every window seam on top of the normal row pitch.

CUT ORDER PER ROW

  1. Forward sweep, left to right: every circle's LOWER half plus the
     straight margin/gap cuts between them. Each lower half is split in
     two by a waste-severing detour (see cut_lower_half()), and the arc
     is resumed ARC_OVERLAP_ANGLE degrees before the point it left off,
     so the join is always fully severed with no witness nub.
  2. At the right edge: the last straight cut runs CUT_OFF_MARGIN past
     the end of the row, then a coating burn-off (plus optional
     RIGHT_CLEAN_REPEATS rub-clean passes along that fresh cut).
  3. Reverse sweep, right to left: every circle's UPPER half, each
     followed by a short SEVER_DISTANCE cut down off the row line and an
     M102 "360 knock" to free the piece. Straights are just travelled
     over, not cut again.
  4. At the left edge: another coating burn-off (plus optional
     LEFT_CLEAN_REPEATS rub-clean passes). The wire is left cold here.
  5. Optional pop-out pass (GENERATE_POP_OUT): one more forward sweep
     that retraces the first POP_OUT_STOP_ANGLE degrees of each upper
     arc and then cuts straight across to the circle's right point,
     nudging the now-loose piece out of the way.

PRE-CUTS

  Before its lower half is cut, each circle gets a short piece of its
  UPPER arc cut first, starting at the left point, going up over the
  top, then straight back down to the left point. This relieves the
  material before the long lower-half cut. The row's FIRST circle uses
  FIRST_CIRCLE_PRECUT_ANGLE (90 deg by default, i.e. up to the top
  point), every other circle uses CIRCLE_PRECUT_ANGLE. The upper half is
  still cut in full during the reverse sweep, re-cutting this small arc
  a second time - harmless, it's an already-open kerf. Set either angle
  to 0 to disable that case.

PERIODIC CLEANING

  Both sweeps pass through one natural point per circle where the wire
  is off in the waste/kerf rather than deep in solid material: the
  waste-severing detour on the forward sweep, and the SEVER_DISTANCE cut
  on the reverse sweep. Every CIRCLES_PER_CLEAN-th circle, instead of
  going straight back to resume cutting, the wire continues down to
  safety_y (SAFETY_BURN_OFF_Y_DISTANCE clear of the row), runs the
  burn-off heat/cool cycle, reheats to CUTTING_TEMP, and then goes to
  exactly the same point it would have gone to anyway - so the cut path
  is unaffected, there's just a cleaning stop spliced in.

  The two sweeps count independently and both counters reset at the
  start of every row, so CIRCLES_PER_CLEAN = 2 means "every 2nd circle
  of the forward sweep AND every 2nd circle of the reverse sweep", not
  "every 2nd circle overall". Set CIRCLES_PER_CLEAN = 0 to disable it;
  the once-per-row end-of-sweep cleans in emit_row() still run.

FEEDER / HOMING

  RAIL_LENGTH is the distance between the Y0 and Z0 home switches;
  MATERIAL_LENGTH is the stock length, so RAIL_LENGTH - MATERIAL_LENGTH
  is the dead gap the feeder has to close before anything can be cut.
  The initial push closes that gap minus SAFETY_DISTANCE (= ORIGIN_Y),
  parking the leading edge just short of the wire. Every subsequent push
  is exactly one window: ROWS_PER_WINDOW row pitches + Y_GAP_WINDOW.

  Hex offset parity is carried across window seams (offset_parity), so
  rows keep alternating correctly even though each window is generated
  independently.

  SINGLE_WINDOW_ONLY = true generates exactly one window with no feeder
  moves at all - useful for test cuts.

Settings live in circleGenConfig.toml.

Run:
    python circleGen8.py
Output:
    circles.gcode (or whatever OUTPUT_FILE says)
"""

import math
import tomllib
from pathlib import Path


# ---------------- EXTERNAL CONFIGURATION ----------------
# All generator settings live in circleGenConfig.toml instead of this source
# file. The config is loaded at import time, which also means
# generator_adapter.py gets a fresh set of config values after reload().
CONFIG_FILE_CANDIDATES = [
    Path(__file__).parent.parent / "circleGenConfig.toml",
    Path(__file__).with_name("circleGenConfig.toml"),
]
CONFIG_FILE = next((path for path in CONFIG_FILE_CANDIDATES if path.is_file()), None)


def _load_config():
    """Load generator settings from the external TOML file into this module's globals."""
    if CONFIG_FILE is None:
        searched = "\n".join(f"  - {path}" for path in CONFIG_FILE_CANDIDATES)
        raise FileNotFoundError(
            "Generator configuration file not found. Searched:\n" + searched
        )

    with CONFIG_FILE.open("rb") as f:
        config = tomllib.load(f)

    settings = config.get("settings", config)
    if not isinstance(settings, dict):
        raise ValueError(
            f"{CONFIG_FILE.name}: expected a [settings] table containing generator variables."
        )

    for name, value in settings.items():
        if not name.isupper():
            raise ValueError(
                f"{CONFIG_FILE.name}: invalid setting '{name}'. "
                "Generator setting names must match the ALL_CAPS names used by the script."
            )
        globals()[name] = value


_load_config()


# ---------------- DERIVED VARIABLES ----------------
# The leading edge of the stock is parked ORIGIN_Y away from the wire, which
# is exactly where row Y coordinates are measured from - deriving it here
# keeps the two from ever drifting apart.
SAFETY_DISTANCE = ORIGIN_Y


# ---------------- LAYOUT ----------------

def best_fit_diameter(diameters, available):
    """Largest diameter from the list that fits within `available` space, or None."""
    candidates = [d for d in diameters if d <= available + 1e-9]
    if not candidates:
        return None
    return max(candidates)


def row_pitch(diameter, y_gap=0.0):
    """
    Center-to-center vertical distance between two consecutive rows of a
    hex packing.

    Shared by compute_rows() (to place rows inside a window) and by the
    feeder's window_push calculation (to know how far to push between
    windows). The same pitch is correct in both places: consecutive rows
    alternate hex offset whether they're inside one window or across a
    window seam, so a seam is just another row boundary.
    """
    return diameter * math.sqrt(3) / 2 + y_gap


def compute_rows(rows_per_window, diameter, y_gap=0.0, start_offset=0, y_start=0.0):
    """
    Return [(row_y, is_offset), ...] for the rows of one window.

    row_y is the circle CENTER height, plane-local (ORIGIN_Y is added at
    emit time). y_start is the SQUISH_ROOM-on-Y leading-edge inset, used
    for the first window only. start_offset carries the hex offset parity
    over from the previous window so the alternation never breaks at a
    seam.
    """
    radius = diameter / 2
    pitch = row_pitch(diameter, y_gap)

    rows = []
    for i in range(rows_per_window):
        y = y_start + radius + i * pitch
        is_offset = ((i + start_offset) % 2 == 1)
        rows.append((y, is_offset))

    return rows


def compute_row_segments(usable_width, main_diameter, is_offset, diameter_options, x_gap=0.0):
    """
    Build the left-to-right list of segments for one row, planned on the
    squish-inset `usable_width` (see build_window()).

    Each segment is a tuple:
      ("straight", x_start, x_end)
      ("circle",   x_start, x_end, diameter)

    Offset (hex) rows start one radius in; that leading margin and
    whatever is left over on the right are each filled with the largest
    diameter from diameter_options that fits, and any remainder becomes a
    plain straight cut.
    """
    radius = main_diameter / 2
    left_margin = radius if is_offset else 0.0

    available = usable_width - left_margin
    circle_count = max(0, math.floor((available + x_gap) / (main_diameter + x_gap) + 1e-9))
    main_run_width = circle_count * main_diameter + max(0, circle_count - 1) * x_gap
    main_end = left_margin + main_run_width
    right_margin = usable_width - main_end

    segments = []
    x = 0.0

    # --- leading margin: fill with the largest filler diameter that fits ---
    fill_d = best_fit_diameter(diameter_options, left_margin)
    if fill_d:
        waste = left_margin - fill_d
        if waste > 1e-9:
            segments.append(("straight", x, x + waste))
            x += waste
        segments.append(("circle", x, x + fill_d, fill_d))
        x += fill_d
    else:
        segments.append(("straight", x, x + left_margin))
        x += left_margin

    # --- main circles, with an x_gap-wide straight cut between neighbours ---
    for i in range(circle_count):
        segments.append(("circle", x, x + main_diameter, main_diameter))
        x += main_diameter
        if x_gap > 1e-9 and i < circle_count - 1:
            segments.append(("straight", x, x + x_gap))
            x += x_gap

    # --- trailing margin: fill with the largest filler diameter that fits ---
    fill_d = best_fit_diameter(diameter_options, right_margin)
    if fill_d:
        segments.append(("circle", x, x + fill_d, fill_d))
        x += fill_d
        waste = usable_width - x
        if waste > 1e-9:
            segments.append(("straight", x, x + waste))
    else:
        segments.append(("straight", x, usable_width))

    return segments


def shift_segments(segments, squish_room):
    """Shift a row planned on the usable width into real block X coordinates."""
    shifted = []
    for seg in segments:
        if seg[0] == "straight":
            shifted.append(("straight", seg[1] + squish_room, seg[2] + squish_room))
        else:
            _, x_start, x_end, d = seg
            shifted.append(("circle", x_start + squish_room, x_end + squish_room, d))

    return shifted


def row_has_circles(segments):
    return any(seg[0] == "circle" for seg in segments)


def build_window(block_width, rows_per_window, squish_room, circle_diameter,
                 diameter_options, x_gap=0.0, y_gap=0.0, start_offset=0, is_first_window=False):
    """
    Build one window: the repeating block of rows that gets cut between
    feeder pushes. Returns [(row_y, segments), ...].

    is_first_window applies the one-off SQUISH_ROOM inset in Y, so the
    very first row of the job doesn't sit right on the leading edge of
    the stock. start_offset is the hex parity carried over from the
    previous window.
    """
    usable_width = block_width - 2 * squish_room
    if usable_width <= 0:
        raise ValueError(
            "SQUISH_ROOM is too large for the given BLOCK_WIDTH - there's "
            "no usable width left to place circles in."
        )

    y_start = squish_room if is_first_window else 0.0
    rows = compute_rows(rows_per_window, circle_diameter, y_gap, start_offset, y_start)

    window = []
    for row_y, is_offset in rows:
        segments = compute_row_segments(usable_width, circle_diameter, is_offset,
                                        diameter_options, x_gap)
        if not row_has_circles(segments):
            # Dropping a row here would silently desync the feed push and
            # the hex parity, so treat it as a configuration error instead.
            raise ValueError(
                "A row ended up with no circles at all - BLOCK_WIDTH is too "
                "small for CIRCLE_DIAMETER/SQUISH_ROOM/X_GAP."
            )
        window.append((row_y, shift_segments(segments, squish_room)))

    return window


# ---------------- G-CODE EMITTERS ----------------

def burn_off_coating(lines):
    """
    The coating burn-off heat/cool cycle. The wire is meant to sit still
    for the whole thing, so nothing else may be spliced in between these
    moves. Called from four places: the once-per-row right-side clean,
    the once-per-row left-side clean, and the two periodic cleans inside
    cut_lower_half() / cut_upper_half().
    """
    lines.append(f"M101 P{COOL_DOWN_TIME_FROM_CUT_TEMP} R0 ; cool down the wire")
    lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
    lines.append(f"M101 P{COOL_DOWN_TIME} R0 ; cool down the wire")


def precut_upper_arc(lines, row_y, x_start, d, angle):
    """
    Cut `angle` degrees of a circle's UPPER arc, starting from its left
    point and going up over the top, then arc straight back down to the
    left point at travel rate. Relieves the material before the long
    lower-half cut that follows.

    Nothing is skipped because of this: the full upper half is still cut
    during the reverse sweep, simply re-cutting this small arc through an
    already-open kerf.

    I/J are relative to the arc's OWN start point, not the circle center,
    which is the convention used everywhere in this file.
    """
    r = d / 2
    cx = x_start + r  # circle center, plane-local (no ORIGIN offset)
    abs_y = ORIGIN_Y + row_y

    precut_angle_rad = math.radians(180.0 - angle)
    precut_x = cx + r * math.cos(precut_angle_rad)
    precut_y = row_y + r * math.sin(precut_angle_rad)

    lines.append(
        f"G2 X{ORIGIN_X + precut_x:.3f} Y{ORIGIN_Y + precut_y:.3f} I{r:.3f} J0.000 "
        f"F{FEED_RATE} ; pre-cut {angle:g} of 180 deg of upper half from the left point"
    )
    lines.append(
        f"G3 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} "
        f"I{cx - precut_x:.3f} J{row_y - precut_y:.3f} F{TRAVEL_RATE} "
        f"; return from pre-cut back to the left point"
    )


def cut_lower_half(lines, row_y, x_start, x_end, d, row_arc_stop_angle, waste_cut_length,
                   safety_y, do_periodic_clean):
    """
    Cut one circle's bottom 180 degree arc, split in two by the
    waste-severing detour:

      left point --arc--> stop point --straight--> out into the waste
      --straight--> back onto the arc ARC_OVERLAP_ANGLE degrees early
      --arc--> right point

    The overlap means the second arc re-cuts a small already-open sliver
    before reaching new material, which guarantees the two arc pieces
    actually meet instead of leaving a witness nub.

    do_periodic_clean splices a cleaning stop in at the far end of the
    detour: the wire keeps going down to safety_y (still cutting - it may
    be passing through material on the way), burns off, reheats, and then
    heads for the exact same return point the plain path would have gone
    to, so the cut geometry is identical either way.

    Assumes the wire is already sitting at this circle's left point
    (x_start, row_y) - i.e. the previous move ended there.
    """
    abs_y = ORIGIN_Y + row_y
    r = d / 2
    cx = x_start + r  # circle center, plane-local (no ORIGIN offset)

    # Bottom arc, part 1: left point -> stop point.
    stop_angle_rad = math.radians(180.0 + row_arc_stop_angle)
    stop_x = cx + r * math.cos(stop_angle_rad)
    stop_y = row_y + r * math.sin(stop_angle_rad)
    lines.append(
        f"G3 X{ORIGIN_X + stop_x:.3f} Y{ORIGIN_Y + stop_y:.3f} I{r:.3f} J0.000 "
        f"F{FEED_RATE} ; cut {row_arc_stop_angle:g} of 180 deg of lower half, d={d:g}"
    )

    # Waste-severing detour: straight cut out into the waste, toward the
    # front-right (+X, -Y) quadrant.
    detour_angle_below_horizontal = 180.0 - row_arc_stop_angle
    diag_rad = math.radians(-detour_angle_below_horizontal)
    diag_x = stop_x + waste_cut_length * math.cos(diag_rad)
    diag_y = stop_y + waste_cut_length * math.sin(diag_rad)
    lines.append(
        f"G1 X{ORIGIN_X + diag_x:.3f} Y{ORIGIN_Y + diag_y:.3f} F{FEED_RATE} "
        f"; cut waste-severing detour, fixed {waste_cut_length:g}mm at "
        f"{detour_angle_below_horizontal:g} deg below horizontal"
    )

    if do_periodic_clean:
        lines.append(
            f"G1 X{ORIGIN_X + diag_x:.3f} Y{safety_y:.3f} F{FEED_RATE} "
            f"; periodic clean ({CIRCLES_PER_CLEAN:g}-circle interval): "
            f"drop to safety Y from the waste-severing detour"
        )
        burn_off_coating(lines)
        lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")

    # Come back onto the arc ARC_OVERLAP_ANGLE degrees EARLIER than the
    # stop point (back toward the left point, into already-cut material).
    # This move cuts rather than travels, since it crosses the waste.
    return_angle = row_arc_stop_angle - ARC_OVERLAP_ANGLE
    return_angle_rad = math.radians(180.0 + return_angle)
    return_x = cx + r * math.cos(return_angle_rad)
    return_y = row_y + r * math.sin(return_angle_rad)
    lines.append(
        f"G1 X{ORIGIN_X + return_x:.3f} Y{ORIGIN_Y + return_y:.3f} F{FEED_RATE} "
        f"; return from detour {ARC_OVERLAP_ANGLE:g} deg before the original stop point (overlap)"
    )

    # Bottom arc, part 2: overlap point -> right point, in one move.
    lines.append(
        f"G3 X{ORIGIN_X + x_end:.3f} Y{abs_y:.3f} "
        f"I{cx - return_x:.3f} J{row_y - return_y:.3f} F{FEED_RATE} "
        f"; finish remaining {180.0 - return_angle:g} of 180 deg of lower half "
        f"(includes {ARC_OVERLAP_ANGLE:g} deg of overlap re-cut)"
    )


def cut_upper_half(lines, abs_y, x_start, d, safety_y, do_periodic_clean):
    """
    Cut one circle's upper 180 degree arc (right point -> left point),
    then the M102 "360 knock" to free the piece.

    If SEVER_DISTANCE > 0, a short cut straight down off the row line is
    made first, to get through anything still hanging on, and the wire
    comes back up to the row line afterwards. At SEVER_DISTANCE = 0 both
    of those moves would be zero-length no-ops, so they're skipped
    entirely rather than emitted.

    do_periodic_clean mirrors cut_lower_half(): instead of coming back up
    immediately (or staying put, with no severing cut), the wire carries
    on down to safety_y, burns off, reheats, and then returns to the row
    line. That return is needed whether or not there was a severing cut.

    Assumes the wire is already sitting at this circle's right point.
    """
    r = d / 2
    lines.append(
        f"G3 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} I{-r:.3f} J0.000 F{FEED_RATE} "
        f"; cut upper half of circle d={d:g}"
    )

    severed = SEVER_DISTANCE > 1e-9
    if severed:
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{(abs_y - SEVER_DISTANCE):.3f} F{FEED_RATE} "
            f"; sever the potentially still connected circle"
        )

    lines.append("M102 ; do the 360 knock")

    if do_periodic_clean:
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{safety_y:.3f} F{FEED_RATE} "
            f"; periodic clean ({CIRCLES_PER_CLEAN:g}-circle interval): "
            f"drop to safety Y at the left point of the upper half"
        )
        burn_off_coating(lines)
        lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
            f"; return from periodic clean"
        )
    elif severed:
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
            f"; going back from the severing cut"
        )


def emit_row(lines, row_y, segments, is_first_row=False):
    """
    Append the G-code for one full row: forward sweep (lower halves +
    straights), right-side clean, reverse sweep (upper halves), left-side
    clean, and the optional pop-out pass.

    is_first_row selects the gentler first-row detour settings
    (ARC_STOP_ANGLE_FIRST_ROW / WASTE_CUT_LENGTH_FIRST_ROW), since on the
    very first row of the job there is no already-cut material behind the
    wire to sever into.
    """
    abs_y = ORIGIN_Y + row_y
    waste_cut_length = WASTE_CUT_LENGTH_FIRST_ROW if is_first_row else WASTE_CUT_LENGTH
    row_arc_stop_angle = ARC_STOP_ANGLE_FIRST_ROW if is_first_row else ARC_STOP_ANGLE

    # Parking spot for every burn-off in this row: clear of the largest
    # circle's bottom by SAFETY_BURN_OFF_Y_DISTANCE. Must stay positive or
    # the gantry would drive into the frame.
    safety_y = abs_y - CIRCLE_DIAMETER / 2 - SAFETY_BURN_OFF_Y_DISTANCE
    if safety_y <= 0:
        raise ValueError(
            "SAFETY_BURN_OFF_Y_DISTANCE causes the machine to go into negative Y, "
            "that would hit the frame"
        )

    # Travel to the left edge, X0. A G-code move only specifies a target,
    # not a start, so the row's first cutting move runs all the way from
    # X0 and clears the left edge on its own - no overcut math needed.
    lines.append(f"M101 R{CUTTING_TEMP} P{TEMP_SET_TIME} ; heat wire to cutting temp")
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge, X0")

    # ---- forward sweep: cut every segment's lower half / straight, left to right ----
    last_index = len(segments) - 1
    first_circle_index = next(i for i, seg in enumerate(segments) if seg[0] == "circle")
    lower_clean_counter = 0  # forward sweep only, resets every row

    for i, seg in enumerate(segments):
        if seg[0] == "straight":
            x_end = ORIGIN_X + seg[2]
            if i == last_index:
                # Final cut of the row runs past the end of the pattern so
                # the whole strip comes free.
                x_end += CUT_OFF_MARGIN
            lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{FEED_RATE} ; cut straight (margin/gap)")

            if i == last_index:
                # Near end of the fresh right-edge cut - the track the
                # rub-clean passes below run back and forth along.
                seg_left = ORIGIN_X + seg[1]

                # Once-per-row right-side burn-off.
                lines.append(f"G1 X{(SAFETY_BURN_OFF_X_DISTANCE):.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
                             f"; move to burn off coating")
                burn_off_coating(lines)

                if RIGHT_CLEAN_REPEATS != 0:
                    lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; come back from burn-off spot")
                for _ in range(RIGHT_CLEAN_REPEATS):
                    lines.append(f"G1 X{seg_left:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                                 f"; rub clean along existing right-edge cut")
                    lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                                 f"; rub clean along existing right-edge cut")

                lines.append(f"G1 X{(SAFETY_BURN_OFF_X_DISTANCE):.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
                             f"; move to heat up")
                lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
                lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; come back from cleaning")

        else:
            _, x_start, x_end, d = seg

            precut_angle = (FIRST_CIRCLE_PRECUT_ANGLE if i == first_circle_index
                            else CIRCLE_PRECUT_ANGLE)
            if precut_angle > 0:
                precut_upper_arc(lines, row_y, x_start, d, precut_angle)

            lower_clean_counter += 1
            do_clean = (CIRCLES_PER_CLEAN > 0) and (lower_clean_counter % CIRCLES_PER_CLEAN == 0)
            cut_lower_half(lines, row_y, x_start, x_end, d, row_arc_stop_angle, waste_cut_length,
                           safety_y, do_clean)

    # ---- reverse sweep: travel back over straights, cut upper half of every circle ----
    # X of the leftmost circle's left point, i.e. the far end of the
    # already-cut kerf the left-side rub-clean retraces.
    leftmost_cut_x = None
    upper_clean_counter = 0  # reverse sweep only, resets every row

    for seg in reversed(segments):
        if seg[0] == "straight":
            lines.append(f"G1 X{ORIGIN_X + seg[1]:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                         f"; travel back over margin/gap")
        else:
            _, x_start, x_end, d = seg
            upper_clean_counter += 1
            do_clean = (CIRCLES_PER_CLEAN > 0) and (upper_clean_counter % CIRCLES_PER_CLEAN == 0)
            cut_upper_half(lines, abs_y, x_start, d, safety_y, do_clean)
            leftmost_cut_x = ORIGIN_X + x_start

    # Normalize back to X0 - also the transition move into the next row or
    # the next window's return-home.
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge (X0)")

    # Once-per-row left-side burn-off. No reheat afterwards: the wire is
    # deliberately left cold until the next row heats it again.
    lines.append(f"G1 X{0:.3f} Y{safety_y:.3f} F{TRAVEL_RATE} ; move to a safe spot, burn off coating")
    burn_off_coating(lines)

    # Left-side mechanical rub-clean, along an already-cut kerf.
    for _ in range(LEFT_CLEAN_REPEATS):
        lines.append(f"G1 X{leftmost_cut_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                     f"; rub clean along existing left-edge cut")
        lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                     f"; rub clean along existing left-edge cut")

    # Pop-out pass: one more forward sweep. Straights are only travelled
    # over. Each circle's upper arc is retraced clockwise from its left
    # point for POP_OUT_STOP_ANGLE degrees (already-cut kerf), then the
    # wire leaves the arc early and crosses straight to the right point,
    # nudging the now fully-separated piece out of the way.
    if GENERATE_POP_OUT:
        for seg in segments:
            if seg[0] == "straight":
                lines.append(f"G1 X{ORIGIN_X + seg[2]:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                             f"; travel over margin/gap")
            else:
                _, x_start, x_end, d = seg
                r = d / 2
                cx = x_start + r  # circle center, plane-local (no ORIGIN offset)

                pop_stop_angle_rad = math.radians(180.0 - POP_OUT_STOP_ANGLE)
                pop_stop_x = cx + r * math.cos(pop_stop_angle_rad)
                pop_stop_y = row_y + r * math.sin(pop_stop_angle_rad)

                lines.append(
                    f"G2 X{ORIGIN_X + pop_stop_x:.3f} Y{ORIGIN_Y + pop_stop_y:.3f} I{r:.3f} J0.000 "
                    f"F{TRAVEL_RATE} ; retrace upper half, {POP_OUT_STOP_ANGLE:g} of 180 deg, d={d:g}"
                )
                lines.append(
                    f"G1 X{ORIGIN_X + x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                    f"; move straight to end of half circle, pop out piece"
                )


def emit_home(lines, axes):
    """
    Return the given axes (e.g. "XY" or "XYZ") to nominal zero with a
    plain G1 move, wire cold. Positions are tracked in software the whole
    job, so no mechanical homing is involved.
    """
    coords = " ".join(f"{axis}0.000" for axis in axes)
    lines.append(f"M101 R0 P{TEMP_SET_TIME} ; kill unecessary heat")
    lines.append(f"G1 {coords} F{TRAVEL_RATE} ; move to nominal {axes} zero")


# ---------------- TOP LEVEL ----------------

def validate_settings():
    """Range-check the settings that would otherwise fail in confusing ways."""
    if not (0.0 < ARC_STOP_ANGLE < 180.0):
        raise ValueError(
            "ARC_STOP_ANGLE must be strictly between 0 and 180 degrees - it "
            "splits the bottom 180 degree arc into two pieces around the "
            "waste-severing detour, so 0 or 180 would leave one piece with "
            "nothing to cut."
        )
    if not (0.0 < ARC_STOP_ANGLE_FIRST_ROW < 180.0):
        raise ValueError(
            "ARC_STOP_ANGLE_FIRST_ROW must be strictly between 0 and 180 "
            "degrees - same reason as ARC_STOP_ANGLE, just for the first "
            "row of the first window."
        )
    if not (isinstance(CIRCLES_PER_CLEAN, int) and CIRCLES_PER_CLEAN >= 0):
        raise ValueError("CIRCLES_PER_CLEAN must be a non-negative integer (0 disables periodic cleaning).")
    for name, angle in (("FIRST_CIRCLE_PRECUT_ANGLE", FIRST_CIRCLE_PRECUT_ANGLE),
                        ("CIRCLE_PRECUT_ANGLE", CIRCLE_PRECUT_ANGLE)):
        if not (0.0 <= angle < 180.0):
            raise ValueError(
                f"{name} must be 0 (disabled) or more, and strictly less than "
                "180 degrees - it's a piece of the upper 180 degree arc, so "
                "180 would try to pre-cut the entire thing."
            )
    if not (isinstance(ROWS_PER_WINDOW, int) and ROWS_PER_WINDOW >= 1):
        raise ValueError("ROWS_PER_WINDOW must be an integer of at least 1.")

    # The topmost row of a window has to stay inside the machine's Y travel.
    pitch = row_pitch(CIRCLE_DIAMETER, Y_GAP)
    top_of_window = (ORIGIN_Y + SQUISH_ROOM + (ROWS_PER_WINDOW - 1) * pitch
                     + CIRCLE_DIAMETER)
    if top_of_window > Y_AXIS_MAX_LIMIT + 1e-9:
        raise ValueError(
            f"ROWS_PER_WINDOW={ROWS_PER_WINDOW} needs Y up to {top_of_window:.3f}mm, "
            f"past Y_AXIS_MAX_LIMIT={Y_AXIS_MAX_LIMIT}mm - reduce ROWS_PER_WINDOW, "
            f"CIRCLE_DIAMETER, Y_GAP or ORIGIN_Y."
        )


def generate_gcode():
    validate_settings()

    pitch = row_pitch(CIRCLE_DIAMETER, Y_GAP)
    # One feed push = one window's worth of rows, plus a little extra slack
    # at the seam.
    window_push = ROWS_PER_WINDOW * pitch + Y_GAP_WINDOW

    lines = []
    lines.append("; Circle-packed cutting pattern with margin-filling + feeder logic + periodic cleaning")
    lines.append(f"; 2D hot-wire cutting, X/Y only - hex layout, full row-sweep cut order, "
                 f"clean every {CIRCLES_PER_CLEAN:g} circles per sweep")
    lines.append(f"; window = {ROWS_PER_WINDOW} row(s) per push, main diameter {CIRCLE_DIAMETER}mm, "
                 f"block width {BLOCK_WIDTH}mm, X_GAP={X_GAP}mm Y_GAP={Y_GAP}mm "
                 f"Y_GAP_WINDOW={Y_GAP_WINDOW}mm CUT_OFF_MARGIN={CUT_OFF_MARGIN}mm")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")
    lines.append("G17 ; XY plane for arcs")

    total_circles = 0
    total_windows = 0

    if SINGLE_WINDOW_ONLY:
        # No feeder involved at all - cut one window and stop.
        window = build_window(
            BLOCK_WIDTH, ROWS_PER_WINDOW, SQUISH_ROOM, CIRCLE_DIAMETER,
            DIAMETER_OPTIONS, X_GAP, Y_GAP, start_offset=0, is_first_window=True
        )

        lines.append("; SINGLE_WINDOW_ONLY = True: feeder/homing-between-windows logic skipped")
        emit_home(lines, "XY")

        for row_index, (row_y, segments) in enumerate(window):
            emit_row(lines, row_y, segments, is_first_row=(row_index == 0))
            total_circles += sum(1 for seg in segments if seg[0] == "circle")
        total_windows = 1

        lines.append("M2 ; end of program")

        stats = {
            "total_circles": total_circles,
            "total_windows": total_windows,
            "rows_per_window": ROWS_PER_WINDOW,
            "single_window_only": True,
        }
        return "\n".join(lines), stats

    # ---- normal feeder-driven full-block behaviour below ----
    rail_gap = RAIL_LENGTH - MATERIAL_LENGTH
    unusable_space = rail_gap - Y_AXIS_MAX_LIMIT
    initial_push = rail_gap - SAFETY_DISTANCE

    if initial_push < 0:
        raise ValueError(
            "MATERIAL_LENGTH/RAIL_LENGTH/SAFETY_DISTANCE combination implies "
            "the stock already sits past the safety distance with zero push "
            "- check those variables."
        )

    lines.append(f"; RAIL_LENGTH={RAIL_LENGTH}mm MATERIAL_LENGTH={MATERIAL_LENGTH}mm "
                 f"Y_AXIS_MAX_LIMIT={Y_AXIS_MAX_LIMIT}mm -> unusable dead space at load "
                 f"= {unusable_space:.3f}mm (informational only, not a cutting limit)")
    lines.append(f"; initial feed push = {initial_push:.3f}mm, "
                 f"per-window feed push = {window_push:.3f}mm (constant every seam)")

    # Initial push: close the dead rail gap and park the material's leading
    # edge SAFETY_DISTANCE from the wire.
    lines.append(
        f"G1 Z{initial_push:.3f} F{Z_FEED_RATE} ; feed material in, ledge parked "
        f"{SAFETY_DISTANCE:.3f}mm from the wire"
    )

    z_pos = initial_push
    offset_parity = 0  # hex row-offset alternation, carried across window seams
    max_Z_push = RAIL_LENGTH - Y_AXIS_MAX_LIMIT

    while True:
        is_first_window = (total_windows == 0)
        window = build_window(
            BLOCK_WIDTH, ROWS_PER_WINDOW, SQUISH_ROOM, CIRCLE_DIAMETER,
            DIAMETER_OPTIONS, X_GAP, Y_GAP,
            start_offset=offset_parity, is_first_window=is_first_window
        )

        lines.append(f"; --- window {total_windows + 1} (Z={z_pos:.3f}, "
                     f"row-offset parity={offset_parity}) ---")

        for row_index, (row_y, segments) in enumerate(window):
            is_first_row = is_first_window and (row_index == 0)
            emit_row(lines, row_y, segments, is_first_row=is_first_row)
            total_circles += sum(1 for seg in segments if seg[0] == "circle")
        total_windows += 1
        offset_parity = (offset_parity + ROWS_PER_WINDOW) % 2

        # Clear X/Y so the next push has room to feed material in.
        emit_home(lines, "XY")

        if z_pos > max_Z_push:
            raise ValueError("the Z axis push would hit the metal frame and exceed expected number of cutting rows")

        # Is there enough stock left behind the feed point for another window?
        remaining = max_Z_push - LEAVE_UNCUT - z_pos
        if remaining < window_push + 1e-6:
            break

        z_pos += window_push
        lines.append(f"G1 Z{z_pos:.3f} F{Z_FEED_RATE} ; feed {window_push:.3f}mm more material in")

    lines.append("M2 ; end of program")

    stats = {
        "total_circles": total_circles,
        "total_windows": total_windows,
        "rows_per_window": ROWS_PER_WINDOW,
        "unusable_space": unusable_space,
        "initial_push": initial_push,
        "window_push": window_push,
        "leftover": max_Z_push - z_pos,
        "single_window_only": False,
    }
    return "\n".join(lines), stats


if __name__ == "__main__":
    gcode, stats = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"hex layout: {stats['total_circles']} circles across {stats['total_windows']} "
          f"windows ({stats['rows_per_window']} rows/window), main diameter {CIRCLE_DIAMETER}mm, "
          f"block width {BLOCK_WIDTH}mm, X_GAP={X_GAP}mm, Y_GAP={Y_GAP}mm, "
          f"Y_GAP_WINDOW={Y_GAP_WINDOW}mm, CIRCLES_PER_CLEAN={CIRCLES_PER_CLEAN}")
    print(f"Diameter options checked for margins: {DIAMETER_OPTIONS}")

    if stats["single_window_only"]:
        print("SINGLE_WINDOW_ONLY = True: feeder logic skipped, generated exactly one window.")
    else:
        print(f"Rail: {RAIL_LENGTH}mm, material: {MATERIAL_LENGTH}mm, "
              f"unusable dead space at load: {stats['unusable_space']:.3f}mm")
        print(f"Initial feed push: {stats['initial_push']:.3f}mm, "
              f"per-window feed push: {stats['window_push']:.3f}mm (constant every seam)")
        print(f"Leftover unused material at end of job: {stats['leftover']:.3f}mm")