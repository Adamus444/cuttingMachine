"""
Derived from circleGenSquish.py

Generate a G-code file for a hot-wire (2D, X/Y only) cutter that cuts
circles out of a rectangular window of material, using a grid or hex
layout of a main circle size, filling row-end margins with a smaller
filler circle where possible (see circleGenSquish.py for the full
explanation of DIAMETER_OPTIONS / SQUISH_ROOM row-segment logic - that
part is copied over unchanged).

WHAT'S NEW HERE: the physical machine only has a limited cutting window,
and the actual stock is much longer than that window, so it has to be
fed in bit by bit. This file adds that feeder/homing layer on top.

MACHINE LAYOUT
  - X/Y home to mechanical switches at the left-front corner of the
    cutting area (X0, Y0).
  - Z is a feeder axis, mechanically in line with Y, but living on the
    OPPOSITE end of the same rail: Y0 and Z0 are the two ends, and both
    Y+ and Z+ count up TOWARDS THE MIDDLE of that rail. So a physical
    point that is Y=y from the Y0 end is also Z=(RAIL_LENGTH - y) from
    the Z0 end, and vice-versa.
  - The feeder (Z) is what actually pushes the material stock into the
    cutting area; X/Y then do the cutting.

        Y0                                                   Z0
        |                                                     |
        | Y+  -->            (RAIL_LENGTH between them)  <--  Z+
        |                                                     |

LOADING / THE "UNUSABLE" GAP
  The stock is loaded so that at Z=0 (feeder home) its leading edge sits
  MATERIAL_LENGTH away from the Z0 end, i.e. at (RAIL_LENGTH -
  MATERIAL_LENGTH) measured from the Y0 end. Y itself can only travel up
  to Y_AXIS_MAX_LIMIT before the gantry physically hits something - and
  that limit is normally well short of where the material's leading edge
  starts out. That gap (rail_gap - Y_AXIS_MAX_LIMIT) is dead space: pure
  travel the feeder has to cover before the wire could reach the material
  at all, let alone cut it. It is NOT the cutting limit (PLANE_HEIGHT/
  ORIGIN_Y define that, same as before) - it's just reported for
  visibility, and is always computed from RAIL_LENGTH/MATERIAL_LENGTH/
  Y_AXIS_MAX_LIMIT rather than hard-coded, since RAIL_LENGTH can change.

INITIAL PUSH (first push only, happens once, before any cutting)
  The feeder pushes the material past that dead gap AND past the row
  margin, until the material's leading edge lines up with where the wire
  would be sitting at Y=SAFETY_DISTANCE (tied to ORIGIN_Y - the same
  clearance the row layout already keeps at the front edge). That target
  Z is:
      initial_push = (RAIL_LENGTH - MATERIAL_LENGTH) - SAFETY_DISTANCE
  (worked example: RAIL_LENGTH=2398.035, MATERIAL_LENGTH=2000,
  SAFETY_DISTANCE=10 -> initial_push = 388.035, matching a Z388.035 move.)

CUTTING WINDOW
  Because the cutting window (PLANE_WIDTH x PLANE_HEIGHT) is far shorter
  than MATERIAL_LENGTH, the row layout computed by compute_rows() for one
  PLANE_HEIGHT-tall pass is treated as a single repeating "window": cut
  every row that fits (in the worked example, that happens to be 2 rows
  for a 200mm-tall window with 90mm circles), return X/Y home, feed more
  material in, and cut the exact same window layout again on fresh stock.
  This repeats until the stock runs out. Nothing about the row count is
  hard-coded - it's whatever compute_rows()/compute_row_segments() decide
  for the configured PLANE_HEIGHT/CIRCLE_DIAMETER/PATTERN.

PUSH BETWEEN WINDOWS (every push after the first)
  Do NOT push a full PLANE_HEIGHT of material forward - that would waste
  the untouched margin above/below the rows (it carries over to become
  the next window's margin instead, for free). Only push far enough to
  bring fresh material in for what the wire will actually cut: the span
  from the front-most point the wire reaches (bottom of the first row's
  circles) to the back-most point it reaches (top of the last row's
  circles). Worked example: front at Y10, back at Y180 -> push 170mm.

HOMING
  At the start of the job, all three axes (X, Y, Z) home. Between every
  window, X and Y return to zero to get out of the way of the next push
  (Z is never re-homed mid-job - its position IS the feed progress).
  Every one of these "return to zero" events can be either a real homing
  action ($HX / $HY / $HZ) or a plain G1 move to the nominal zero
  coordinate - controlled by USE_HARDWARE_HOMING below.

Adjust the VARIABLES section below.

Run:
    python circleGenFeeder.py
Output:
    circles.gcode
"""

import math

# ---------------- CUTTING VARIABLES (same as circleGenSquish.py) ----------------
PLANE_WIDTH = 1200.0        # mm, width of one cutting window (X)
PLANE_HEIGHT = 150.0        # mm, height of one cutting window (Y) - NOT the
                             # full stock length, just one repeating window
SQUISH_ROOM = 2.0           # mm, material can squish/stretch/shift a little.
                             # Circles are inset SQUISH_ROOM from every nominal
                             # window edge so they're never partial. Straight
                             # waste cuts at the left/right edges are driven
                             # SQUISH_ROOM past the nominal edge so they fully
                             # separate the block regardless.
CIRCLE_DIAMETER = 70.0      # mm, main circle size used for the grid/hex layout
SEVER_DISTANCE = 2.0        # mm, extra cut to make sure a circle is fully
                             # severed and doesn't stay hanging by a sliver

PATTERN = "hex"             # "grid" or "hex" - layout used for the main circles

DIAMETER_OPTIONS = [50.0, 30.0]
# List of acceptable diameters to check against when a row-end margin has
# leftover space. The script picks the LARGEST one from this list that
# still fits.

FEED_RATE = 300             # mm/min, speed while cutting (X/Y)
TRAVEL_RATE = 500            # mm/min, speed while travelling (X/Y, non-productive)

ORIGIN_X = 10.0              # mm, X offset of the window's bottom-left corner
ORIGIN_Y = 10.0              # mm, Y offset of the window's bottom-left corner

OUTPUT_FILE = "circles.gcode"

# ---------------- MACHINE / FEEDER VARIABLES ----------------
RAIL_LENGTH = 2229.0
# mm, distance between the Y-axis home switch (Y0, front of the cutting
# area) and the Z-axis home switch (Z0, feeder home). Y and Z are
# collinear, on opposite ends of the same rail, both counting UP toward
# the middle of the machine.

MATERIAL_LENGTH = 2000.0
# mm, length of the stock block along the shared Y/Z rail.

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

USE_HARDWARE_HOMING = True
# True  -> use dedicated homing commands ($HX / $HY / $HZ) every time an
#          axis needs to return to zero.
# False -> just issue a plain G1 move to the nominal zero coordinate.

Z_FEED_RATE = 150
# mm/min, speed for the feeder (Z axis) pushing material in.
# --------------------------------------------


def best_fit_diameter(diameters, available):
    """Largest diameter from the list that fits within `available` space."""
    candidates = [d for d in diameters if d <= available + 1e-9]
    if not candidates:
        return None
    return max(candidates)


def compute_rows(plane_height, diameter, pattern):
    """Return a list of (row_y, is_offset) for every row that fits vertically."""
    radius = diameter / 2

    if pattern == "grid":
        row_height = diameter
    elif pattern == "hex":
        row_height = diameter * math.sqrt(3) / 2
    else:
        raise ValueError("PATTERN must be 'grid' or 'hex'")

    rows = []
    i = 0
    while True:
        y = radius + i * row_height
        if y + radius > plane_height + 1e-9:
            break
        is_offset = (pattern == "hex" and i % 2 == 1)
        rows.append((y, is_offset))
        i += 1

    return rows


def compute_row_segments(plane_width, main_diameter, is_offset, diameter_options):
    """
    Build the left-to-right list of segments for one row.
    Each segment is a tuple:
      ("straight", x_start, x_end)
      ("circle",   x_start, x_end, diameter)
    """
    radius = main_diameter / 2
    left_margin = radius if is_offset else 0.0

    available = plane_width - left_margin
    circle_count = max(0, math.floor(available / main_diameter + 1e-9))
    main_end = left_margin + circle_count * main_diameter
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

    # --- main circles ---
    for _ in range(circle_count):
        segments.append(("circle", x, x + main_diameter, main_diameter))
        x += main_diameter

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
    Take row segments planned on the shrunk "effective" width
    (0 .. plane_width - 2*squish_room) and place them into real window
    coordinates (0 .. plane_width): shift right by squish_room so every
    circle stays clear of the real edges, then extend whatever straight
    segment borders each outer edge so it overcuts squish_room past the
    nominal edge (inserting one if a filler circle landed flush on it).
    """
    shifted = []
    for seg in segments:
        if seg[0] == "straight":
            shifted.append(("straight", seg[1] + squish_room, seg[2] + squish_room))
        else:
            _, x_start, x_end, d = seg
            shifted.append(("circle", x_start + squish_room, x_end + squish_room, d))

    if not shifted:
        return shifted

    # --- left edge: reach to -squish_room instead of stopping at 0 ---
    left_target = -squish_room
    if shifted[0][0] == "straight":
        shifted[0] = ("straight", left_target, shifted[0][2])
    elif shifted[0][1] > left_target + 1e-9:
        shifted.insert(0, ("straight", left_target, shifted[0][1]))

    # --- right edge: reach to plane_width + squish_room instead of plane_width ---
    right_target = plane_width + squish_room
    if shifted[-1][0] == "straight":
        shifted[-1] = ("straight", shifted[-1][1], right_target)
    elif shifted[-1][2] < right_target - 1e-9:
        shifted.append(("straight", shifted[-1][2], right_target))

    return shifted


def row_has_circles(segments):
    return any(seg[0] == "circle" for seg in segments)


def emit_row(lines, row_y, segments):
    """Append the G-code for one full row sweep (there and back)."""
    abs_y = ORIGIN_Y + row_y
    row_start_x = ORIGIN_X + segments[0][1]  # may be < ORIGIN_X due to left overcut

    # Travel to the (possibly squish-overcut) left edge of the row
    lines.append(f"G1 X{row_start_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge of row")

    # Forward sweep: cut every segment, left to right
    for seg in segments:
        if seg[0] == "straight":
            x_end = ORIGIN_X + seg[2]
            lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{FEED_RATE} ; cut straight (margin/gap)")
        else:
            _, x_start, x_end, d = seg
            r = d / 2
            lines.append(
                f"G3 X{ORIGIN_X + x_end:.3f} Y{abs_y:.3f} I{r:.3f} J0.000 F{FEED_RATE} "
                f"; cut lower half of circle d={d:g}"
            )

    # Reverse sweep: travel back over straights, cut upper half of every circle
    for seg in reversed(segments):
        if seg[0] == "straight":
            x_start = ORIGIN_X + seg[1]
            lines.append(f"G1 X{x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel back over margin/gap")
        else:
            _, x_start, x_end, d = seg
            r = d / 2
            lines.append(
                f"G3 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} I{-r:.3f} J0.000 F{FEED_RATE} "
                f"; cut upper half of circle d={d:g}"
            )

            # make an additional straight cut to fully sever the circle, just in case
            lines.append(
                f"G1 X{ORIGIN_X + x_start:.3f} Y{(abs_y - SEVER_DISTANCE):.3f} F{FEED_RATE} "
                f"; sever the potentially still connected circle"
            )

            # go back from the severing cut
            lines.append(
                f"G1 X{ORIGIN_X + x_start:.3f} Y{(abs_y):.3f} F{TRAVEL_RATE} "
                f"; going back from the severing cut"
            )

    # Explicit normalize move back to the row's start (also doubles as the
    # transition move before the next row / the next window's return-home).
    lines.append(f"G1 X{row_start_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge before next row")


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
        lines.append(f"G1 {coords} F{TRAVEL_RATE} ; move to nominal {axes} zero")


def build_window(plane_width, plane_height, squish_room, circle_diameter, pattern, diameter_options):
    """
    Build the single repeating "window" of rows/segments that gets cut
    fresh every time new material is fed in. Returns a list of
    (actual_row_y, segments) - actual_row_y is relative to ORIGIN_Y,
    exactly what emit_row() expects.
    """
    effective_width = plane_width - 2 * squish_room
    effective_height = plane_height - 2 * squish_room
    if effective_width <= 0 or effective_height <= 0:
        raise ValueError(
            "SQUISH_ROOM is too large for the given PLANE_WIDTH/PLANE_HEIGHT "
            "- there's no usable area left to place circles in."
        )

    rows = compute_rows(effective_height, circle_diameter, pattern)

    window = []
    for row_y, is_offset in rows:
        segments = compute_row_segments(effective_width, circle_diameter, is_offset, diameter_options)
        if not row_has_circles(segments):
            continue
        segments = place_segments_in_plane(segments, plane_width, squish_room)
        actual_row_y = row_y + squish_room
        window.append((actual_row_y, segments))

    return window


def compute_window_span(window):
    """
    The most-front and most-back ABSOLUTE Y the wire physically reaches
    while cutting circles in this window (row centerline +/- that
    circle's own radius) - i.e. the strip of material the wire actually
    touches, and therefore the strip that needs to be advanced clear
    before the next window.
    """
    front_y = None
    back_y = None
    for actual_row_y, segments in window:
        abs_y = ORIGIN_Y + actual_row_y
        for seg in segments:
            if seg[0] != "circle":
                continue
            r = seg[3] / 2
            bottom = abs_y - r
            top = abs_y + r
            if front_y is None or bottom < front_y:
                front_y = bottom
            if back_y is None or top > back_y:
                back_y = top
    return front_y, back_y


def generate_gcode():
    window = build_window(
        PLANE_WIDTH, PLANE_HEIGHT, SQUISH_ROOM, CIRCLE_DIAMETER, PATTERN, DIAMETER_OPTIONS
    )
    if not window:
        raise ValueError(
            "No circles fit in a single window with the given PLANE_HEIGHT/"
            "CIRCLE_DIAMETER/PATTERN - nothing to cut."
        )

    front_y, back_y = compute_window_span(window)
    window_push = back_y - front_y  # mm to feed in between windows (after the first)

    rail_gap = RAIL_LENGTH - MATERIAL_LENGTH
    unusable_space = rail_gap - Y_AXIS_MAX_LIMIT
    initial_push = rail_gap - SAFETY_DISTANCE

    if initial_push < 0:
        raise ValueError(
            "MATERIAL_LENGTH/RAIL_LENGTH/SAFETY_DISTANCE combination implies "
            "the stock already sits past the safety distance with zero push "
            "- check those variables."
        )

    if ORIGIN_X < SQUISH_ROOM:
        print(
            f"WARNING: ORIGIN_X ({ORIGIN_X}) is less than SQUISH_ROOM "
            f"({SQUISH_ROOM}); left-edge overcut moves will go to a negative "
            f"machine X coordinate."
        )

    lines = []
    lines.append("; Circle-packed cutting pattern with margin-filling + feeder logic")
    lines.append(f"; 2D hot-wire cutting, X/Y only - {PATTERN} layout, row-sweep order")
    lines.append(f"; window = {len(window)} row(s) per push, main diameter {CIRCLE_DIAMETER}mm, "
                 f"window {PLANE_WIDTH}x{PLANE_HEIGHT}mm")
    lines.append(f"; RAIL_LENGTH={RAIL_LENGTH}mm MATERIAL_LENGTH={MATERIAL_LENGTH}mm "
                 f"Y_AXIS_MAX_LIMIT={Y_AXIS_MAX_LIMIT}mm -> unusable dead space at load "
                 f"= {unusable_space:.3f}mm (informational only, not a cutting limit)")
    lines.append(f"; initial feed push = {initial_push:.3f}mm, "
                 f"subsequent feed push per window = {window_push:.3f}mm")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")
    lines.append("G17 ; XY plane for arcs")

    # Home everything at the very start of the job.
    lines.append("$H")

    # Initial push: clear the dead rail gap and park the material's
    # leading edge SAFETY_DISTANCE from the wire.
    lines.append(
        f"G1 Z{initial_push:.3f} F{Z_FEED_RATE} ; feed material in, ledge parked "
        f"{SAFETY_DISTANCE:.3f}mm from the wire"
    )

    total_circles = 0
    total_windows = 0
    z_pos = initial_push

    while True:
        lines.append(f"; --- window {total_windows + 1} (Z={z_pos:.3f}) ---")
        #lines.append(f"G1 X{ORIGIN_X:.3f} Y{ORIGIN_Y:.3f} F{TRAVEL_RATE} ; move to the starting point")

        for actual_row_y, segments in window:
            emit_row(lines, actual_row_y, segments)
            total_circles += sum(1 for seg in segments if seg[0] == "circle")
        total_windows += 1

        # Clear X/Y so the next push has room to feed material in.
        emit_home(lines, "XY")

        # Is there enough stock left behind the feed point for another window?
        remaining = MATERIAL_LENGTH - z_pos
        if remaining < window_push + 1e-6:
            break

        z_pos += window_push
        lines.append(f"G1 Z{z_pos:.3f} F{Z_FEED_RATE} ; feed {window_push:.3f}mm more material in")

    lines.append("M2 ; end of program")

    leftover = MATERIAL_LENGTH - z_pos
    stats = {
        "total_circles": total_circles,
        "total_windows": total_windows,
        "rows_per_window": len(window),
        "unusable_space": unusable_space,
        "initial_push": initial_push,
        "window_push": window_push,
        "leftover": leftover,
    }
    return "\n".join(lines), stats


if __name__ == "__main__":
    gcode, stats = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"{PATTERN} layout: {stats['total_circles']} circles across {stats['total_windows']} "
          f"windows ({stats['rows_per_window']} rows/window), main diameter {CIRCLE_DIAMETER}mm, "
          f"window {PLANE_WIDTH}x{PLANE_HEIGHT}mm")
    print(f"Diameter options checked for margins: {DIAMETER_OPTIONS}")
    print(f"Rail: {RAIL_LENGTH}mm, material: {MATERIAL_LENGTH}mm, "
          f"unusable dead space at load: {stats['unusable_space']:.3f}mm")
    print(f"Initial feed push: {stats['initial_push']:.3f}mm, "
          f"per-window feed push: {stats['window_push']:.3f}mm")
    print(f"Leftover unused material at end of job: {stats['leftover']:.3f}mm")
