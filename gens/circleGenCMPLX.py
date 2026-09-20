"""
Generate a G-code file for a hot-wire (2D, X/Y only) cutter that cuts
circles out of a fixed-size rectangular plane, using a grid or hex layout
of a main circle size - AND tries to fill the leftover margin at the start
and end of every row with a smaller circle instead of wasting that strip
of material, by checking it against a list of acceptable diameters.

Builds on the previous row-sweep script. The difference is in how each
row is planned: instead of always being [margin, main circles, margin],
a row is now a list of SEGMENTS built left to right, where each segment
is either:
  - a straight cut (leftover material too small for any allowed circle)
  - a circle cut (either a main circle, or a smaller filler circle that
    fit in what would otherwise have been wasted margin)

The forward sweep cuts every segment left to right (straight = G1,
circle = G3 lower half). The reverse sweep then goes back right to left:
straight segments are simply travelled over (already cut, no need to
cut again), circle segments get their G3 upper half, completing them.
This is exactly the same "there and back" idea as before, just applied
to a list of segments instead of a fixed margin/circles/margin structure.

MARGIN-FILLING LOGIC (per margin, independently for left and right):
  - Look at the leftover space in that margin.
  - Among DIAMETER_OPTIONS, find the largest diameter that fits.
  - If one fits: place it flush against the main circles (touching, no
    gap), with any small leftover (too small for even the smallest
    allowed diameter) pushed out to the sheet edge as a straight cut.
  - If none fit: cut the whole margin straight, same as before.

Adjust the VARIABLES section below.

Run:
    python circle_sweep_fill_gcode.py
Output:
    circles.gcode
"""

import math

# ---------------- VARIABLES ----------------
PLANE_WIDTH = 1200.0        # mm, width of the material to cut from
PLANE_HEIGHT = 200.0        # mm, height of the material to cut from
CIRCLE_DIAMETER = 90.0     # mm, main circle size used for the grid/hex layout

PATTERN = "hex"           # "grid" or "hex" - layout used for the main circles

DIAMETER_OPTIONS = [70, 50.0, 30.0]
# List of acceptable diameters to check against when a margin has leftover
# space. The script picks the LARGEST one from this list that still fits.
# Include CIRCLE_DIAMETER in here too if you want it considered for
# margins as well as the main layout (it usually won't fit there, but
# there's no harm including it).

FEED_RATE = 300            # mm/min, speed while cutting
TRAVEL_RATE = 500          # mm/min, speed while travelling (non-productive moves)

ORIGIN_X = 10.0             # mm, X offset of the plane's bottom-left corner
ORIGIN_Y = 10.0             # mm, Y offset of the plane's bottom-left corner

OUTPUT_FILE = "circles.gcode"
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


def row_has_circles(segments):
    return any(seg[0] == "circle" for seg in segments)


def emit_row(lines, row_y, segments):
    """Append the G-code for one full row sweep (there and back)."""
    abs_y = ORIGIN_Y + row_y

    # Travel to the left edge of the plane at this row's height
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge of row")

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

    # Explicit normalize move back to the row's start (row should already be
    # here, but this keeps every row ending at a known, identical position -
    # also doubles as the "turn 90 degrees to the next row" transition move).
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge before next row")


def generate_gcode():
    rows = compute_rows(PLANE_HEIGHT, CIRCLE_DIAMETER, PATTERN)

    lines = []
    lines.append("; Circle-packed cutting pattern with margin-filling")
    lines.append(f"; 2D hot-wire cutting, X/Y only - {PATTERN} layout, row-sweep order")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")
    lines.append("G17 ; XY plane for arcs")
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{ORIGIN_Y:.3f} F{TRAVEL_RATE} ; move to the starting point")

    total_circles = 0
    used_rows = 0

    for row_y, is_offset in rows:
        segments = compute_row_segments(PLANE_WIDTH, CIRCLE_DIAMETER, is_offset, DIAMETER_OPTIONS)
        if not row_has_circles(segments):
            continue  # nothing to cut in this row at all - skip it

        emit_row(lines, row_y, segments)
        total_circles += sum(1 for seg in segments if seg[0] == "circle")
        used_rows += 1


    lines.append("M2 ; end of program")

    return "\n".join(lines), total_circles, used_rows


if __name__ == "__main__":
    gcode, total_circles, used_rows = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"{PATTERN} layout: {total_circles} circles across {used_rows} rows, "
          f"main diameter {CIRCLE_DIAMETER}mm, plane {PLANE_WIDTH}x{PLANE_HEIGHT}mm")
    print(f"Diameter options checked for margins: {DIAMETER_OPTIONS}")
