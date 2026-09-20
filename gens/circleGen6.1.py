"""
Derived from circleGenFeeder4_3.py (cut path) and circleGenFeeder5_1.py
(code organization / readability).

Generate a G-code file for a hot-wire (2D, X/Y only) cutter that cuts
circles out of a rectangular window of material, using a grid or hex
layout of a main circle size, filling row-end margins with a smaller
filler circle where possible (see circleGenSquish.py / circleGenFeeder4_3.py
for the full explanation of DIAMETER_OPTIONS / SQUISH_ROOM row-segment
logic - that part is copied over unchanged, as is all of the
feeder/homing/window-push machinery below - see circleGenFeeder4_3.py's
docstring for FEED-IN-BIT-BY-BIT, CUTTING WINDOW, PUSH BETWEEN WINDOWS,
SQUISH_ROOM ON Y / CUT_OFF_MARGIN, ROW-COUNT PARITY and HOMING; none of
that changed here).

WHY THIS FILE EXISTS (the story so far)

  circleGenFeeder4_3.py cut an entire row's worth of circles' LOWER
  halves first (one long forward sweep), then came back and cut the
  entire row's worth of UPPER halves (one long reverse sweep), with a
  single coating burn-off stop at each end of that sweep.

  circleGenFeeder5_1.py tried fixing the "whole row sits half-cut for
  the entire sweep" problem by chopping each row into small SERIES of
  circles, fully finishing (cut + pop out) each series before moving on
  to the next. In testing, that series restructuring turned out to
  actually hurt the cut quality - it wasn't needed. What WAS actually
  needed was simply more frequent coating burn-off/cleaning.

  So this file goes back to circleGenFeeder4_3.py's cut path exactly -
  one full forward sweep of lower halves, then one full reverse sweep
  of upper halves, per row, same arc-splitting/waste-severing-detour/
  sever-cut geometry, no series, no batching, no pop-out-per-batch -
  and just adds PERIODIC CLEANING (see below) on top of it. The nicer,
  more organised code layout from circleGenFeeder5_1.py (small helper
  functions instead of one giant emit_row) is kept, since that part was
  liked independently of the series-cutting idea it was introduced for.

PERIODIC CLEANING (the actual change from circleGenFeeder4_3.py)

  Both sweeps already pass through one natural "detour" point per
  circle where the wire is briefly off in the waste/kerf, not deep in
  solid material:

    - Forward sweep (lower halves): the waste-severing detour already
      sends the wire off the arc into the waste for WASTE_CUT_LENGTH
      (see cut_lower_half()). That detour point is now ALSO where a
      periodic clean can be spliced in.
    - Reverse sweep (upper halves): there's no detour, but the
      SEVER_DISTANCE severing cut (see cut_upper_half()) already sends
      the wire a short way down off the row line before it normally
      comes straight back up. That severing point is now ALSO where a
      periodic clean can be spliced in.

  CIRCLES_PER_CLEAN configures how often that clean actually happens:
  every CIRCLES_PER_CLEAN-th circle in a sweep, instead of the wire
  immediately returning to resume cutting, it continues on down to
  safety_y (SAFETY_BURN_OFF_Y_DISTANCE below the row - the same safe
  spot used for the full end-of-sweep burn-offs), runs the coating
  burn-off heat/cool cycle (burn_off_coating(), same routine as
  circleGenFeeder5_1.py factored out), reheats to CUTTING_TEMP, then
  comes straight back and continues exactly as if nothing had happened
  - resuming the arc for the forward sweep, or continuing the reverse
  sweep for the upper half. On every OTHER circle (not a multiple of
  CIRCLES_PER_CLEAN), the sweep behaves exactly like
  circleGenFeeder4_3.py, with no extra stop at all.

  The two sweeps count independently (a lower_clean_counter for the
  forward sweep, an upper_clean_counter for the reverse sweep), and
  both reset to 0 at the start of every row - so CIRCLES_PER_CLEAN=2
  means "clean after every 2nd circle of the forward sweep, and
  separately after every 2nd circle of the reverse sweep", not
  "clean after every 2nd circle overall". Set CIRCLES_PER_CLEAN=0 to
  disable this entirely and get exactly circleGenFeeder4_3.py's old
  behaviour (only the once-per-sweep end cleans below still run).

  This is on top of, not instead of, the existing once-per-row cleans:
  the right-side burn-off (+ optional RIGHT_CLEAN_REPEATS rub-clean)
  after the forward sweep reaches the row's right edge, and the
  left-side burn-off (+ optional LEFT_CLEAN_REPEATS rub-clean) after
  the reverse sweep gets back to the row's left edge. Those are
  unchanged from circleGenFeeder4_3.py (see emit_row()). Note that if
  CIRCLES_PER_CLEAN happens to land exactly on the LAST circle of a
  sweep, the periodic clean and the sweep's own end-of-row clean will
  both fire back to back - harmless, just a few redundant seconds.

  One small, deliberate fix carried over from circleGenFeeder5_1.py:
  circleGenFeeder4_3.py's left-side (end-of-reverse-sweep) burn-off move
  computed its target Y as `abs_y - safety_y` (which works out to just
  SAFETY_BURN_OFF_Y_DISTANCE as an absolute coordinate - i.e. it didn't
  actually reach the intended safe Y at all). That target is now the
  correct absolute `safety_y`, same as circleGenFeeder5_1.py already
  fixed it to be.

Everything else - PLANE_WIDTH/PLANE_HEIGHT/SQUISH_ROOM, the grid/hex
row & margin-filler layout, the feeder/push-between-windows math, the
SQUISH_ROOM-ON-Y first-window special case, row-offset parity across
windows, homing, SINGLE_WINDOW_ONLY, and the once-per-row pop-out pass
- is inherited from circleGenFeeder4_3.py unchanged. See that file's
docstring for the full explanation of any of those if needed.

Adjust the VARIABLES section below.

Run:
    python circleGenFeederPeriodicClean.py
Output:
    circles.gcode
"""

import math

# ---------------- CUTTING VARIABLES ----------------
PLANE_WIDTH = 1000.0        # mm, width of one cutting window (X)
PLANE_HEIGHT = 100.0        # mm, height of one cutting window (Y) - NOT the
                             # full stock length, just one repeating window
SQUISH_ROOM = 2.0           # mm, tolerance for material movement.
                             # X: always inset from left/right nominal edges.
                             # Y: only applied to the first row of the first window
                             # (the true leading edge of fresh stock).

CIRCLE_DIAMETER = 90.0      # mm, main circle size for grid/hex layout.

SEVER_DISTANCE = 10.0       # mm, extra cut to fully sever circles from waste.
                             # Also where the reverse sweep's periodic clean
                             # (see CIRCLES_PER_CLEAN) branches off from.

CUT_OFF_MARGIN = 40.0       # mm, extends the final right-edge straight cut.
                             # Increase if a sliver remains uncut.

CIRCLES_PER_CLEAN = 4       # how many circles the wire cuts, in EACH sweep,
                             # before it takes a detour to burn off/clean the
                             # coating - see the PERIODIC CLEANING note in the
                             # module docstring. Counted separately for the
                             # forward (lower-half) sweep and the reverse
                             # (upper-half) sweep, both resetting every row.
                             # Set to 0 to disable (matches
                             # circleGenFeeder4_3.py's old behaviour, only
                             # the once-per-row end cleans still run).

ARC_STOP_ANGLE_FIRST_ROW = 90.0
                             # degrees, where the bottom 180 degree arc splits
                             # for the very first row of the very first window.
                             # At 90 (the default) that's the very bottom of
                             # the arc, so the detour runs straight down -
                             # 90 degrees below horizontal.

WASTE_CUT_LENGTH_FIRST_ROW = 25.0  # mm, straight waste-severing detour length,
                             # used ONLY for the very first row of the very
                             # first window (the true leading edge of fresh
                             # stock - same row SQUISH_ROOM-ON-Y treats
                             # specially). Direction tracks
                             # ARC_STOP_ANGLE_FIRST_ROW; ignores other circles.
ARC_STOP_ANGLE = 135.0      # degrees, where the bottom 180 degree arc splits
                             # for every row OTHER than the first row of the
                             # first window - insert the waste-severing
                             # detour there. At 135 (the default) that's 45
                             # degrees short of the circle's rightmost point,
                             # so the detour runs at 45 degrees below
                             # horizontal.
WASTE_CUT_LENGTH = 8.0     # mm, straight waste-severing detour length,
                             # used for every other row (all rows after the
                             # first, in every window). Fixed 45 deg toward
                             # front-right; ignores other circles.
ARC_OVERLAP_ANGLE = 3.0     # degrees, how far EARLIER than the original arc
                             # stop point the wire travels back to after the
                             # waste-severing detour, before resuming the arc
                             # - see the ARC OVERLAP note in the module
                             # docstring. Must be strictly less than whichever
                             # of ARC_STOP_ANGLE / ARC_STOP_ANGLE_FIRST_ROW
                             # applies to the row.

POP_OUT_STOP_ANGLE = 30     # degrees, stop at this angle when popping out the foam circles
                             # then go straight to next circle, this should physically move the foam circle
GENERATE_POP_OUT = False    # once-per-row pop-out pass (unchanged from
                             # circleGenFeeder4_3.py - no per-batch pop-out
                             # any more, there are no batches). Set True to
                             # have the wire nudge cut circles out of the way
                             # at the end of every row; False to leave them
                             # (e.g. picking pieces out by hand instead).

X_GAP = 0.0                 # mm, extra straight clearance between main circles
                             # in the same row. Does not affect margin-filler circles.

Y_GAP = 2.0                 # mm, extra row-to-row pitch added to normal
                             # grid/hex spacing. Applies to all rows and seams.

Y_GAP_WINDOW = 2.0          # mm, extra clearance added once at each window seam.
                             # Used for additional feeder repeatability tolerance;
                             # separate from the normal Y_GAP on every row.
PATTERN = "hex"             # "grid" or "hex" - layout used for the main circles

DIAMETER_OPTIONS = [70, 50]
# List of acceptable diameters to check against when a row-end margin has
# leftover space. The script picks the LARGEST one from this list that
# still fits.

FEED_RATE = 170             # mm/min, speed while cutting (X/Y)
TRAVEL_RATE = 400            # mm/min, speed while travelling (X/Y, non-productive)

ORIGIN_X = 10.0              # mm, X offset of the window's bottom-left corner
ORIGIN_Y = 120.0              # mm, Y offset of the window's bottom-left corner

OUTPUT_FILE = "circles.gcode"

# ---------------- MACHINE / FEEDER VARIABLES ----------------
SINGLE_WINDOW_ONLY = False
# True  -> ignore all the feeder/homing machinery below entirely and just
#          generate the G-code for ONE window, then end the program (no
#          initial push, no Z moves, no re-homing between windows, no
#          feed loop). Useful for testing a layout on a scrap piece
#          without committing/threading a full block through the machine.
# False -> normal behaviour: feed the full MATERIAL_LENGTH through in
#          repeating windows, exactly as this file has always done.

RAIL_LENGTH = 2229.0
# mm, distance between the Y-axis home switch (Y0, front of the cutting
# area) and the Z-axis home switch (Z0, feeder home). Y and Z are
# collinear, on opposite ends of the same rail, both counting UP toward
# the middle of the machine.

MATERIAL_LENGTH = 1180.0
# mm, length of the stock block along the shared Y/Z rail.

LEAVE_UNCUT = 300
# mm, dont try to push further if there is only this much material left

Z_FEED_RATE = 150
# mm/min, speed for the feeder (Z axis) pushing material in.

SAFETY_BURN_OFF_X_DISTANCE = 1050.0
# mm, machine X coord. Used as the parking/reheat spot for the once-per-row
# right-side burn-off + optional RIGHT_CLEAN_REPEATS rub-clean, exactly as
# in circleGenFeeder4_3.py. The new mid-sweep periodic cleans (see
# CIRCLES_PER_CLEAN) do NOT use this spot - they happen in place, straight
# down from wherever the wire already is (the waste-severing detour point,
# or the severing-cut point), same idea as circleGenFeeder5_1.py's
# in-place series burn-offs.
SAFETY_BURN_OFF_Y_DISTANCE = 40.0
# mm, relative -Y, the machine moves this much on Y
# when trying to burn off coating, atop moving the X axis
CUTTING_TEMP = 10
# %, adjust the temp knob to this when cutting
BURN_OFF_TEMP = 24
# %, adjust the temp knob to this when trying burn the coating off
TEMP_SET_TIME = 4
# seconds, how long to dwell the controller waiting
# for the temperature to actually, physically get to the desired value
BURN_OFF_TIME = 10
# seconds, how long to dwell the contrller waiting
# for the coating to physically burn off
COOL_DOWN_TIME = 8
COOL_DOWN_TIME_FROM_CUT_TEMP = 4

LEFT_CLEAN_REPEATS = 0
RIGHT_CLEAN_REPEATS = 0

# ---------------- RARELY CHANGED ----------------

Y_AXIS_MAX_LIMIT = 280.0
# mm, absolute mechanical travel limit of the Y axis - the point past
# which the gantry would physically hit something. This is NOT a cutting
# limit (the wire should never actually go anywhere near it - real
# cutting stays within PLANE_HEIGHT/ORIGIN_Y). It's only used to report
# how much of the rail is dead/unusable space before the wire can even
# reach the freshly-loaded stock.

SAFETY_DISTANCE = ORIGIN_Y
# mm, clearance to leave between the wire's home position and the
# material's leading edge once it's been pushed in - i.e. the material's
# ledge parks where the wire would be if it were sitting at
# Y=SAFETY_DISTANCE. Tied to ORIGIN_Y since that's already the clearance
# the row layout keeps at the front edge; change ORIGIN_Y to change both.

USE_HARDWARE_HOMING = False
# NOTE: setting it to true results in trying to home while still in motion
#       just use the normal G1, no need to try real homing
# True  -> use dedicated homing commands ($HX / $HY / $HZ) every time an
#          axis needs to return to zero.
# False -> just issue a plain G1 move to the nominal zero coordinate.

# --------------------------------------------


def best_fit_diameter(diameters, available):
    """Largest diameter from the list that fits within `available` space."""
    candidates = [d for d in diameters if d <= available + 1e-9]
    if not candidates:
        return None
    return max(candidates)


def row_pitch(diameter, pattern, y_gap=0.0):
    """
    Center-to-center vertical distance between two consecutive rows -
    shared by compute_rows() (to place rows within a window) and the
    feeder's window_push calculation (to know how far to feed between
    windows). See the ROW-COUNT PARITY note in circleGenFeeder4_3.py's
    docstring for why the SAME pitch is correct both within a window and
    across a window seam (consecutive rows always alternate hex offset
    either way).
    """
    if pattern == "grid":
        return diameter + y_gap
    elif pattern == "hex":
        return diameter * math.sqrt(3) / 2 + y_gap
    else:
        raise ValueError("PATTERN must be 'grid' or 'hex'")


def compute_rows(plane_height, diameter, pattern, y_gap=0.0, start_offset=0, y_start=0.0):
    """
    Return a list of (row_y, is_offset) for every row that fits within
    plane_height. See circleGenFeeder4_3.py's docstring for the full
    explanation of start_offset (hex parity across windows) and y_start
    (SQUISH_ROOM-on-Y, first window only) - unchanged here.
    """
    radius = diameter / 2
    row_height = row_pitch(diameter, pattern, y_gap)

    rows = []
    i = 0
    while True:
        y = y_start + radius + i * row_height
        if y + radius > plane_height + 1e-9:
            break
        is_offset = (pattern == "hex" and (i + start_offset) % 2 == 1)
        rows.append((y, is_offset))
        i += 1

    return rows


def compute_row_segments(plane_width, main_diameter, is_offset, diameter_options, x_gap=0.0):
    """
    Build the left-to-right list of segments for one row.
    Each segment is a tuple:
      ("straight", x_start, x_end)
      ("circle",   x_start, x_end, diameter)

    Unchanged from circleGenFeeder4_3.py.
    """
    radius = main_diameter / 2
    left_margin = radius if is_offset else 0.0

    available = plane_width - left_margin
    circle_count = max(0, math.floor((available + x_gap) / (main_diameter + x_gap) + 1e-9))
    main_run_width = circle_count * main_diameter + max(0, circle_count - 1) * x_gap
    main_end = left_margin + main_run_width
    right_margin = plane_width - main_end

    segments = []
    x = 0.0

    # --- leading margin: try to fill with the largest diameter that fits ---
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

    # --- trailing margin: try to fill with the largest diameter that fits ---
    fill_d = best_fit_diameter(diameter_options, right_margin)
    if fill_d:
        segments.append(("circle", x, x + fill_d, fill_d))
        x += fill_d
        waste = plane_width - x
        if waste > 1e-9:
            segments.append(("straight", x, x + waste))
            x = plane_width
    else:
        segments.append(("straight", x, plane_width))
        x = plane_width

    return segments


def place_segments_in_plane(segments, plane_width, squish_room):
    """
    Shift segments planned on the shrunk "effective" width into real
    window X coordinates by squish_room. Unchanged from
    circleGenFeeder4_3.py.
    """
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


def burn_off_coating(lines):
    """
    The coating burn-off heat/cool cycle: cool, heat to BURN_OFF_TEMP,
    cool, heat again, cool - run twice back to back with nothing else
    spliced in between, since the wire is meant to sit still through the
    whole thing. Factored out (same as circleGenFeeder5_1.py) since it
    now gets called from four different spots: the once-per-row
    right-side clean, the once-per-row left-side clean, and the two new
    per-circle periodic cleans (see cut_lower_half() / cut_upper_half()).
    """
    lines.append(f"M101 P{COOL_DOWN_TIME_FROM_CUT_TEMP} R0 ; cool down the wire")
    lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
    lines.append(f"M101 P{COOL_DOWN_TIME} R0 ; cool down the wire")


def cut_lower_half(lines, row_y, x_start, x_end, d, row_arc_stop_angle, waste_cut_length,
                    safety_y, do_periodic_clean):
    """
    Cut one circle's bottom 180 degree arc, split by the waste-severing
    detour, exactly as circleGenFeeder4_3.py did - the arc geometry
    itself (where it splits, how long/which angle the detour runs, and
    the plain non-cutting travel back to the exact stop point before
    resuming) is unchanged.

    The only new behaviour is do_periodic_clean: when True, instead of
    travelling straight back from the detour to resume the arc, the wire
    continues on down to safety_y (cutting - it may still be passing
    through some material on the way down, same reasoning as
    circleGenFeeder5_1.py's in-place series burn-off drops), runs the
    coating burn-off cycle, reheats, and THEN travels back to the same
    exact stop point the plain path would have gone to - so the arc
    resumes from the same place either way, just with a clean detour
    spliced in first. See the PERIODIC CLEANING note in the module
    docstring for when do_periodic_clean is actually set.

    Assumes the wire is already sitting at this circle's own left point
    (x_start, row_y) when called - i.e. the previous G-code move already
    ended there (row start travel, or the previous segment's own cut).
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

    # Waste-severing detour: straight cut into the waste, toward the
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
        # Periodic clean: from the detour point, continue on down to the
        # safe Y instead of heading straight back to the stop point, burn
        # off the coating there, reheat, then travel to the stop point -
        # same destination the plain path below would have gone to.
        lines.append(
            f"G1 X{ORIGIN_X + diag_x:.3f} Y{safety_y:.3f} F{FEED_RATE} "
            f"; periodic clean ({CIRCLES_PER_CLEAN:g}-circle interval): "
            f"drop to safety Y from the waste-severing detour"
        )
        burn_off_coating(lines)
        lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
        
    
    # Return from the detour to a point ARC_OVERLAP_ANGLE degrees EARLIER
    # along the arc than the original stop point (i.e. back toward the
    # left point, into already-cut territory) instead of exactly at it -
    # this straight move itself now cuts (F{FEED_RATE}), not just travels
    # - see the ARC OVERLAP note in the module docstring.
    return_angle = row_arc_stop_angle - ARC_OVERLAP_ANGLE
    return_angle_rad = math.radians(180.0 + return_angle)
    return_x = cx + r * math.cos(return_angle_rad)
    return_y = row_y + r * math.sin(return_angle_rad)
    lines.append(
        f"G1 X{ORIGIN_X + return_x:.3f} Y{ORIGIN_Y + return_y:.3f} F{FEED_RATE} "
        f"; return from detour {ARC_OVERLAP_ANGLE:g} deg before the original stop point (overlap)"
    )

    # Bottom arc, part 2: resume from the overlap point all the way to
    # the circle's right point in one move. This re-cuts the small
    # ARC_OVERLAP_ANGLE-degree sliver back to the original stop point
    # (already-open kerf, harmless) before going on to cut the genuinely
    # remaining material out to the right point - guaranteeing a clean,
    # fully-severed join with no witness nub.
    lines.append(
        f"G3 X{ORIGIN_X + x_end:.3f} Y{abs_y:.3f} "
        f"I{cx - return_x:.3f} J{row_y - return_y:.3f} F{FEED_RATE} "
        f"; finish remaining {180.0 - return_angle:g} of 180 deg of lower half "
        f"(includes {ARC_OVERLAP_ANGLE:g} deg of overlap re-cut)"
    )


def cut_upper_half(lines, abs_y, x_start, d, safety_y, do_periodic_clean):
    """
    Cut one circle's upper 180 degree arc plus the SEVER_DISTANCE
    severing cut, exactly as circleGenFeeder4_3.py did. Assumes the wire
    is already sitting at this circle's own right point (x_end, abs_y)
    when called.

    do_periodic_clean mirrors cut_lower_half(): when True, instead of
    immediately travelling back up from the severing cut to resume the
    reverse sweep, the wire continues on down to safety_y, burns off the
    coating, reheats, and THEN comes back up to abs_y - same destination
    the plain path below would have gone to either way.
    """
    r = d / 2
    lines.append(
        f"G3 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} I{-r:.3f} J0.000 F{FEED_RATE} "
        f"; cut upper half of circle d={d:g}"
    )
    lines.append(
        f"G1 X{ORIGIN_X + x_start:.3f} Y{(abs_y - SEVER_DISTANCE):.3f} F{FEED_RATE} "
        f"; sever the potentially still connected circle"
    )

    if do_periodic_clean:
        # Periodic clean: from the severing cut, continue on down to the
        # safe Y instead of heading straight back up, burn off the
        # coating there, reheat, then travel back up to abs_y - same
        # destination the plain path below would have gone to.
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{safety_y:.3f} F{FEED_RATE} "
            f"; periodic clean ({CIRCLES_PER_CLEAN:g}-circle interval): "
            f"continue down to safety Y from the severing cut"
        )
        burn_off_coating(lines)
        lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
            f"; return from periodic clean"
        )
    else:
        lines.append(
            f"G1 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
            f"; going back from the severing cut"
        )
    lines.append("M102 ; do the 360 knock")


def emit_row(lines, row_y, segments, is_first_row=False):
    """
    Append the G-code for one full row sweep (there and back) - exactly
    circleGenFeeder4_3.py's cut path: one full forward sweep cutting
    every circle's lower half (left to right), then one full reverse
    sweep cutting every circle's upper half (right to left), with a
    once-per-row burn-off/clean at each end of that sweep. See
    cut_lower_half() / cut_upper_half() for the per-circle geometry, and
    the PERIODIC CLEANING note in the module docstring for the
    CIRCLES_PER_CLEAN mid-sweep stops spliced into both passes below.

    is_first_row selects ARC_STOP_ANGLE_FIRST_ROW/WASTE_CUT_LENGTH_FIRST_ROW
    vs ARC_STOP_ANGLE/WASTE_CUT_LENGTH, same meaning as in
    circleGenFeeder4_3.py.
    """
    abs_y = ORIGIN_Y + row_y
    waste_cut_length = WASTE_CUT_LENGTH_FIRST_ROW if is_first_row else WASTE_CUT_LENGTH
    row_arc_stop_angle = ARC_STOP_ANGLE_FIRST_ROW if is_first_row else ARC_STOP_ANGLE

    # make sure to not go into -Y
    safety_y = abs_y - CIRCLE_DIAMETER/2 - SAFETY_BURN_OFF_Y_DISTANCE
    if safety_y <= 0:
        raise ValueError("SAFETY_BURN_OFF_Y_DISTANCE causes the machine to go into negative Y, that would hit the frame")

    # Travel to the left edge, X0 - the forward sweep starts from here.
    # A G-code move only specifies a target, not a start, so the very
    # next cutting move - for the row's first segment - ends up running
    # all the way from X0, fully clearing the left edge with no
    # squish-room-based overcut math needed (same as circleGenFeeder4_3.py).
    lines.append(f"M101 R{CUTTING_TEMP} P{TEMP_SET_TIME}")
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge, X0")

    # ---- forward sweep: cut every segment's lower half/straight, left to right ----
    segments_max_index = len(segments) - 1
    lower_clean_counter = 0  # periodic-clean circle counter, forward sweep only, resets every row
    for i, seg in enumerate(segments):
        if seg[0] == "straight":
            x_end = ORIGIN_X + seg[2]
            if i == segments_max_index:
                x_end += CUT_OFF_MARGIN
            lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{FEED_RATE} ; cut straight (margin/gap)")

            if i == segments_max_index:
                seg_left = ORIGIN_X + seg[1]  # start of this straight cut,
                                               # the near end of the track
                                               # we'll rub back and forth on

                # once-per-row right-side burn-off (unchanged from circleGenFeeder4_3.py)
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
            lower_clean_counter += 1
            do_clean = (CIRCLES_PER_CLEAN > 0) and (lower_clean_counter % CIRCLES_PER_CLEAN == 0)
            cut_lower_half(lines, row_y, x_start, x_end, d, row_arc_stop_angle, waste_cut_length,
                           safety_y, do_clean)

    # ---- reverse sweep: travel back over straights, cut upper half of every circle ----
    last_upper_arc = None  # (x_start, x_end, r) of the last circle whose
                            # upper half gets cut in this row - used below
                            # for the left-side rub-clean, since that's an
                            # already-cut kerf the wire can safely retrace.
    upper_clean_counter = 0  # periodic-clean circle counter, reverse sweep only, resets every row
    for i in range(len(segments) - 1, -1, -1):
        seg = segments[i]
        if seg[0] == "straight":
            x_start = ORIGIN_X + seg[1]
            lines.append(f"G1 X{x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel back over margin/gap")
        else:
            _, x_start, x_end, d = seg
            r = d / 2
            upper_clean_counter += 1
            do_clean = (CIRCLES_PER_CLEAN > 0) and (upper_clean_counter % CIRCLES_PER_CLEAN == 0)
            cut_upper_half(lines, abs_y, x_start, d, safety_y, do_clean)
            last_upper_arc = (x_start, x_end, r)

    # Explicit normalize move back to X0 (also doubles as the transition
    # move before the next row / the next window's return-home).
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge (X0)")

    # once-per-row left-side burn-off (no reheat afterwards - wire is left
    # cold, same as circleGenFeeder4_3.py). Target Y is the correct
    # absolute safety_y here - circleGenFeeder4_3.py had a bug computing
    # this as abs_y - safety_y (which isn't the intended coordinate);
    # fixed the same way circleGenFeeder5_1.py already fixed it.
    lines.append(f"G1 X{0:.3f} Y{safety_y:.3f} F{TRAVEL_RATE} ; move to a safe spot, burn off coating")
    burn_off_coating(lines)

    # left-side mechanical rub-clean (already-cut kerf)
    x_start, x_end, r = last_upper_arc
    for _ in range(LEFT_CLEAN_REPEATS):
        lines.append(f"G1 X{x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                    f"; rub clean along existing left-edge cut")
        lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                    f"; rub clean along existing left-edge cut")

    # Pop-out pass: sweep forward across the row once more. Straights are
    # just travelled over. Each circle's upper-half arc is retraced
    # clockwise from its left point for only the first POP_OUT_STOP_ANGLE
    # degrees of the 180 degree sweep (already-cut kerf), then the wire
    # leaves the arc early and jumps in a straight, non-cutting line to
    # the circle's right point - nudging the now fully-separated piece
    # out of the way. GENERATE_POP_OUT = False skips this pass entirely.
    if GENERATE_POP_OUT:
        for seg in segments:
            if seg[0] == "straight":
                x_end = ORIGIN_X + seg[2]
                lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel over margin/gap")
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
    Return the given axes (e.g. "XY" or "XYZ") to zero.
    USE_HARDWARE_HOMING True  -> one $H<axis> command per axis.
    USE_HARDWARE_HOMING False -> a single G1 move to the nominal zero(s).
    """
    if USE_HARDWARE_HOMING:
        for axis in axes:
            lines.append(f"$H{axis} ; home {axis} axis to its mechanical switch")
    else:
        coords = " ".join(f"{axis}0.000" for axis in axes)
        lines.append(f"M101 R0 P{TEMP_SET_TIME} ; kill unecessary heat")
        lines.append(f"G1 {coords} F{TRAVEL_RATE} ; move to nominal {axes} zero")


def build_window(plane_width, plane_height, squish_room, circle_diameter, pattern,
                  diameter_options, x_gap=0.0, y_gap=0.0, start_offset=0, is_first_window=False):
    """
    Build the single repeating "window" of rows/segments that gets cut
    fresh every time new material is fed in. Unchanged from
    circleGenFeeder4_3.py - see that file's docstring (SQUISH_ROOM ON Y,
    ROW-COUNT PARITY) for the full reasoning behind is_first_window /
    start_offset.
    """
    effective_width = plane_width - 2 * squish_room
    if effective_width <= 0:
        raise ValueError(
            "SQUISH_ROOM is too large for the given PLANE_WIDTH - there's "
            "no usable width left to place circles in."
        )

    y_start = squish_room if is_first_window else 0.0
    rows = compute_rows(plane_height, circle_diameter, pattern, y_gap, start_offset, y_start)

    window = []
    for row_y, is_offset in rows:
        segments = compute_row_segments(effective_width, circle_diameter, is_offset, diameter_options, x_gap)
        if not row_has_circles(segments):
            continue
        segments = place_segments_in_plane(segments, plane_width, squish_room)
        window.append((row_y, segments))

    return window


def generate_gcode():
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

    # Build the first window (start_offset=0, is_first_window=True - this
    # is the one window that gets the SQUISH_ROOM-ON-Y leading-edge inset)
    # to validate the settings and, in SINGLE_WINDOW_ONLY mode, to have
    # something to cut.
    first_window = build_window(
        PLANE_WIDTH, PLANE_HEIGHT, SQUISH_ROOM, CIRCLE_DIAMETER, PATTERN,
        DIAMETER_OPTIONS, X_GAP, Y_GAP, start_offset=0, is_first_window=True
    )
    if not first_window:
        raise ValueError(
            "No circles fit in a single window with the given PLANE_HEIGHT/"
            "CIRCLE_DIAMETER/PATTERN - nothing to cut."
        )
    rows_per_window = len(first_window)

    # The feed push between windows: rows_per_window row-pitches, plus
    # Y_GAP_WINDOW once per seam. Unchanged from circleGenFeeder4_3.py.
    window_push = rows_per_window * row_pitch(CIRCLE_DIAMETER, PATTERN, Y_GAP) + Y_GAP_WINDOW

    lines = []
    lines.append("; Circle-packed cutting pattern with margin-filling + feeder logic + periodic cleaning")
    lines.append(f"; 2D hot-wire cutting, X/Y only - {PATTERN} layout, full row-sweep cut order, "
                 f"clean every {CIRCLES_PER_CLEAN:g} circles per sweep")
    lines.append(f"; window = {rows_per_window} row(s) per push, main diameter {CIRCLE_DIAMETER}mm, "
                 f"window {PLANE_WIDTH}x{PLANE_HEIGHT}mm, X_GAP={X_GAP}mm Y_GAP={Y_GAP}mm "
                 f"Y_GAP_WINDOW={Y_GAP_WINDOW}mm CUT_OFF_MARGIN={CUT_OFF_MARGIN}mm")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")
    lines.append("G17 ; XY plane for arcs")

    total_circles = 0
    total_windows = 0

    if SINGLE_WINDOW_ONLY:
        # No feeder involved at all - just cut the one window and stop.
        lines.append("; SINGLE_WINDOW_ONLY = True: feeder/homing-between-windows logic skipped")
        lines.append("$HX ; home X axis to its mechanical switch")
        lines.append("$HY ; home Y axis to its mechanical switch")

        for row_index, (row_y, segments) in enumerate(first_window):
            emit_row(lines, row_y, segments, is_first_row=(row_index == 0))
            total_circles += sum(1 for seg in segments if seg[0] == "circle")
        total_windows = 1

        lines.append("M2 ; end of program")

        stats = {
            "total_circles": total_circles,
            "total_windows": total_windows,
            "rows_per_window": rows_per_window,
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

    # Initial push: clear the dead rail gap and park the material's
    # leading edge SAFETY_DISTANCE from the wire.
    lines.append(
        f"G1 Z{initial_push:.3f} F{Z_FEED_RATE} ; feed material in, ledge parked "
        f"{SAFETY_DISTANCE:.3f}mm from the wire"
    )

    z_pos = initial_push
    offset_parity = 0  # hex row-offset alternation, carried across windows

    while True:
        is_first_window = (total_windows == 0)
        window = build_window(
            PLANE_WIDTH, PLANE_HEIGHT, SQUISH_ROOM, CIRCLE_DIAMETER, PATTERN,
            DIAMETER_OPTIONS, X_GAP, Y_GAP, start_offset=offset_parity, is_first_window=is_first_window
        )

        lines.append(f"; --- window {total_windows + 1} (Z={z_pos:.3f}, "
                     f"row-offset parity={offset_parity}) ---")

        for row_index, (row_y, segments) in enumerate(window):
            is_first_row = is_first_window and (row_index == 0)
            emit_row(lines, row_y, segments, is_first_row=is_first_row)
            total_circles += sum(1 for seg in segments if seg[0] == "circle")
        total_windows += 1
        offset_parity = (offset_parity + len(window)) % 2

        # Clear X/Y so the next push has room to feed material in.
        emit_home(lines, "XY")

        # Is there enough stock left behind the feed point for another window?
        remaining = RAIL_LENGTH - LEAVE_UNCUT - z_pos
        if remaining < window_push + 1e-6:
            break

        z_pos += window_push
        lines.append(f"G1 Z{z_pos:.3f} F{Z_FEED_RATE} ; feed {window_push:.3f}mm more material in")

    lines.append("M2 ; end of program")

    leftover = RAIL_LENGTH - z_pos
    stats = {
        "total_circles": total_circles,
        "total_windows": total_windows,
        "rows_per_window": rows_per_window,
        "unusable_space": unusable_space,
        "initial_push": initial_push,
        "window_push": window_push,
        "leftover": leftover,
        "single_window_only": False,
    }
    return "\n".join(lines), stats


if __name__ == "__main__":
    gcode, stats = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"{PATTERN} layout: {stats['total_circles']} circles across {stats['total_windows']} "
          f"windows ({stats['rows_per_window']} rows/window), main diameter {CIRCLE_DIAMETER}mm, "
          f"window {PLANE_WIDTH}x{PLANE_HEIGHT}mm, X_GAP={X_GAP}mm, Y_GAP={Y_GAP}mm, "
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