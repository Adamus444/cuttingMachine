"""
Generate a G-code file for a hot-wire (2D, X/Y only) cutter that cuts
circles out of a fixed-size rectangular plane, using either a plain grid
or a hexagonal (offset-row) layout - your choice.

CUTTING STRATEGY (matches the hand-written reference example):
Each row is cut as ONE continuous sweep instead of closing each circle
individually:

  1. Travel to the left edge of the plane at this row's height.
  2. Cut across whatever solid margin sits before the first circle.
  3. Cut the LOWER half-arc of every circle in the row, left to right,
     going straight across the gaps between circles (there are none,
     since spacing is always 0 - circles touch - but the logic supports
     it generally).
  4. Cut straight across from the last circle to the right edge of the
     plane (the trailing margin).
  5. Travel back (retracing the same already-cut line, so nothing new
     gets cut) to the last circle's right edge.
  6. Cut the UPPER half-arc of every circle, right to left, back to
     where the row started. Combined with step 3, every circle is now
     a complete circle.

Rows are stacked either as a plain grid (every row starts flush with
the left edge) or hex-packed (every other row is shifted right by one
radius, giving denser packing - see the comment in the code for why
this needs checking per row, per your earlier question about grid vs
hex being better only in certain size ranges).

Spacing between circles is always 0 (they touch) - that's fixed, not a
variable, per your requirement.

Adjust the VARIABLES section below.

Run:
    python circle_sweep_gcode.py
Output:
    circles.gcode
"""

import math

# ---------------- VARIABLES ----------------
PLANE_WIDTH = 1200.0        # mm, width of the material to cut from
PLANE_HEIGHT = 300.0        # mm, height of the material to cut from
CIRCLE_DIAMETER = 70.0     # mm

PATTERN = "hex"           # "grid" or "hex" - you choose which layout to use

FEED_RATE = 300            # mm/min, speed while cutting
TRAVEL_RATE = 500          # mm/min, speed while travelling (non-productive moves)

ORIGIN_X = 0.0             # mm, X offset of the plane's bottom-left corner
ORIGIN_Y = 0.0             # mm, Y offset of the plane's bottom-left corner

OUTPUT_FILE = "circles.gcode"
# --------------------------------------------


def compute_rows(plane_height, diameter, pattern):
    """
    Return a list of (row_y, is_offset) for every row that fits vertically.
    row_y is relative to the plane's bottom edge (0 = bottom).
    """
    radius = diameter / 2

    if pattern == "grid":
        row_height = diameter  # rows touch vertically, no offset ever
    elif pattern == "hex":
        row_height = diameter * math.sqrt(3) / 2  # tighter vertical stacking
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


def compute_row_circles(plane_width, diameter, is_offset):
    """
    Return (left_margin, circle_count, right_margin) for one row.
    left_margin = solid material before the first circle
    right_margin = solid material after the last circle
    """
    radius = diameter / 2
    left_margin = radius if is_offset else 0.0

    available = plane_width - left_margin
    circle_count = max(0, math.floor(available / diameter + 1e-9))

    used_width = left_margin + circle_count * diameter
    right_margin = plane_width - used_width

    return left_margin, circle_count, right_margin


def emit_row(lines, row_y, left_margin, circle_count, diameter, plane_width):
    """Append the G-code for one full row sweep (there and back)."""
    radius = diameter / 2
    abs_y = ORIGIN_Y + row_y

    # 1. Travel to the left edge of the plane at this row's height
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge of row")

    # 2. Cut across the leading margin (0 if the first circle starts flush with the edge)
    x = ORIGIN_X + left_margin
    lines.append(f"G1 X{x:.3f} Y{abs_y:.3f} F{FEED_RATE} ; cut leading margin")

    # 3. Cut the lower half-arc of every circle, left to right
    for i in range(circle_count):
        x_end = x + diameter
        lines.append(
            f"G3 X{x_end:.3f} Y{abs_y:.3f} I{radius:.3f} J0.000 F{FEED_RATE} "
            f"; cut lower half of circle {i}"
        )
        x = x_end

    # 4. Cut straight across the trailing margin to the plane's right edge
    right_edge = ORIGIN_X + plane_width
    lines.append(f"G1 X{right_edge:.3f} Y{abs_y:.3f} F{FEED_RATE} ; cut trailing margin to plane edge")

    # 5. Travel back to the last circle's right edge (retraces the cut just made)
    lines.append(f"G1 X{x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel back")

    # 6. Cut the upper half-arc of every circle, right to left
    for i in reversed(range(circle_count)):
        x_start = ORIGIN_X + left_margin + (i + 1) * diameter
        x_end = ORIGIN_X + left_margin + i * diameter
        lines.append(
            f"G3 X{x_end:.3f} Y{abs_y:.3f} I{-radius:.3f} J0.000 F{FEED_RATE} "
            f"; cut upper half of circle {i}"
        )

    # Row ends at x = left_margin (NOTE: already cut, there is a need to retrace as to not cut the good circle above)
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; test, move the cutting part at 90 degrees to the next row")


def generate_gcode():
    rows = compute_rows(PLANE_HEIGHT, CIRCLE_DIAMETER, PATTERN)

    lines = []
    lines.append("; Circle-packed cutting pattern")
    lines.append(f"; 2D hot-wire cutting, X/Y only - {PATTERN} layout, row-sweep order")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")
    lines.append("G17 ; XY plane for arcs")
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{ORIGIN_Y:.3f} F{TRAVEL_RATE} ; move to the starting point")

    total_circles = 0
    skipped_rows = 0

    for row_y, is_offset in rows:
        left_margin, circle_count, right_margin = compute_row_circles(
            PLANE_WIDTH, CIRCLE_DIAMETER, is_offset
        )
        if circle_count <= 0:
            skipped_rows += 1
            continue  # no room for a circle in this row - skip it entirely

        emit_row(lines, row_y, left_margin, circle_count, CIRCLE_DIAMETER, PLANE_WIDTH)
        total_circles += circle_count

    lines.append("M2 ; end of program")

    return "\n".join(lines), total_circles, len(rows) - skipped_rows


if __name__ == "__main__":
    gcode, total_circles, used_rows = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"{PATTERN} layout: {total_circles} circles across {used_rows} rows, "
          f"diameter {CIRCLE_DIAMETER}mm, plane {PLANE_WIDTH}x{PLANE_HEIGHT}mm")
