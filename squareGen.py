"""
Generate a G-code file for a hot-wire (2D, X/Y only) cutter that cuts a
grid of squares using a zigzag/serpentine path (not per-square loops, and
not the separate horizontal-lines-then-vertical-lines approach - this is
the weaving pattern where the cut oscillates between a row's bottom edge
and top edge as it crosses each column).

PATTERN LOGIC (derived from the reference example):
- Rows alternate direction: row 0 goes left->right, row 1 right->left,
  row 2 left->right, and so on (serpentine).
- Within a row, the cut alternates which edge (bottom or top) it follows
  for each column, connected by a vertical segment at each column
  boundary. Two adjacent rows use opposite starting edges, so together
  they cover every column's shared boundary line exactly once (never
  double cut).
- Whether a column does [horizontal edge, then vertical] or [vertical,
  then horizontal edge] flips every row too, so the path stays one
  continuous weave with no lifts.
- The move connecting the end of one row to the start of the next is
  always a vertical segment. The script checks whether that exact
  segment was already cut earlier in the row (it sometimes is, because
  of how the weave lines up) - if so, it's just a retrace (fast travel,
  no need to cut it again); if not, it's a genuine new cut (closing the
  last column's remaining edge) and gets cut at the normal feed rate.
  Either way, no interior edge is ever cut twice.

Adjust the VARIABLES section below.

Run:
    python square_zigzag_gcode.py
Output:
    squares.gcode
"""

# ---------------- VARIABLES ----------------
PLANE_WIDTH = 120.0        # mm, width of the material to cut from
PLANE_HEIGHT = 80.0       # mm, height of the material to cut from
SQUARE_SIZE = 20.0        # mm, size of each square (squares always touch, no spacing)

FEED_RATE = 300           # mm/min, speed while cutting
TRAVEL_RATE = 500         # mm/min, speed while travelling (retracing already-cut material)

ORIGIN_X = 0.0            # mm, X offset of the plane's bottom-left corner
ORIGIN_Y = 0.0            # mm, Y offset of the plane's bottom-left corner

OUTPUT_FILE = "squares.gcode"
# --------------------------------------------


def generate_gcode():
    cols = int(PLANE_WIDTH // SQUARE_SIZE)
    rows = int(PLANE_HEIGHT // SQUARE_SIZE)

    if cols < 1 or rows < 1:
        raise ValueError("PLANE_WIDTH/PLANE_HEIGHT too small for even one SQUARE_SIZE square")

    lines = []
    lines.append("; Square grid - zigzag cutting pattern")
    lines.append("; 2D hot-wire cutting, X/Y only")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")
    lines.append(f"G1 X{ORIGIN_X:.3f} Y{ORIGIN_Y:.3f} F{TRAVEL_RATE} ; move to the starting point")
    lines.append("; cut the square zigzag pattern")

    cut_vertical_segments = set()  # (x_rounded, y_low_rounded) -> that column-height segment is cut

    current_x, current_y = ORIGIN_X, ORIGIN_Y

    for r in range(rows):
        y_bottom = ORIGIN_Y + r * SQUARE_SIZE
        y_top = y_bottom + SQUARE_SIZE
        row_even = (r % 2 == 0)
        col_order = range(cols) if row_even else range(cols - 1, -1, -1)
        direction = 1 if row_even else -1
        horiz_first = row_even
        edge_is_bottom = row_even  # starting edge for this row's first column

        for c in col_order:
            x_left = ORIGIN_X + c * SQUARE_SIZE
            x_right = x_left + SQUARE_SIZE
            far_x = x_right if direction == 1 else x_left
            y_edge = y_bottom if edge_is_bottom else y_top
            other_y = y_top if edge_is_bottom else y_bottom

            if horiz_first:
                # cut across the column at y_edge, then cut the vertical column boundary
                lines.append(f"G1 X{far_x:.3f} Y{y_edge:.3f} F{FEED_RATE}")
                current_x, current_y = far_x, y_edge
                lines.append(f"G1 X{far_x:.3f} Y{other_y:.3f} F{FEED_RATE}")
                y_low = min(y_edge, other_y)
                cut_vertical_segments.add((round(far_x, 3), round(y_low, 3)))
                current_x, current_y = far_x, other_y
            else:
                # cut the vertical column boundary first, then across the column at y_edge
                lines.append(f"G1 X{current_x:.3f} Y{y_edge:.3f} F{FEED_RATE}")
                y_low = min(current_y, y_edge)
                cut_vertical_segments.add((round(current_x, 3), round(y_low, 3)))
                current_y = y_edge
                lines.append(f"G1 X{far_x:.3f} Y{y_edge:.3f} F{FEED_RATE}")
                current_x = far_x

            edge_is_bottom = not edge_is_bottom

        if r == rows - 1:
            break  # last row, nothing more to connect to

        lines.append(f"; end of row {r}")

        next_r = r + 1
        next_row_even = (next_r % 2 == 0)
        needed_x = ORIGIN_X + (0.0 if next_row_even else cols * SQUARE_SIZE)
        needed_y = ORIGIN_Y + next_r * SQUARE_SIZE

        # The weave always lines the X up automatically; this guards against
        # an odd column count throwing that off, just in case.
        if abs(current_x - needed_x) > 1e-6:
            lines.append(f"G1 X{needed_x:.3f} Y{current_y:.3f} F{TRAVEL_RATE} ; align to next row")
            current_x = needed_x

        if abs(current_y - needed_y) > 1e-6:
            y_low = min(current_y, needed_y)
            key = (round(current_x, 3), round(y_low, 3))
            if key in cut_vertical_segments:
                lines.append(f"G1 X{needed_x:.3f} Y{needed_y:.3f} F{TRAVEL_RATE} ; move to next row (already cut)")
            else:
                lines.append(f"G1 X{needed_x:.3f} Y{needed_y:.3f} F{FEED_RATE} ; close remaining edge, move to next row")
                cut_vertical_segments.add(key)
            current_y = needed_y

    lines.append("M2 ; end of program")
    return "\n".join(lines), cols, rows


if __name__ == "__main__":
    gcode, cols, rows = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"{cols * rows} squares ({cols} cols x {rows} rows), size {SQUARE_SIZE}mm, "
          f"feed rate {FEED_RATE}mm/min")