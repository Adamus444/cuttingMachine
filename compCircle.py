"""
Compare square-grid vs hexagonal packing of equal-size circles on a
FINITE sheet, using number of circles fit as the metric (not density).

On an infinite plane hex packing is always denser (~90.7% vs ~78.5% for
square). On a finite sheet that's not guaranteed - edge effects can let a
square grid fit more circles for certain sheet sizes, especially when the
sheet is small relative to the circle size or has an awkward aspect ratio.
This script computes the actual circle count for both patterns (and hex
in both orientations) and tells you which wins for your specific numbers.

Adjust the VARIABLES section below.

Run:
    python compare_packing.py
"""

import math

# ---------------- VARIABLES ----------------
SHEET_WIDTH = 1200.0     # mm
SHEET_HEIGHT = 2000.0    # mm
CIRCLE_DIAMETER = 90.0  # mm
SPACING = 0.0           # mm, required gap between adjacent circles
# --------------------------------------------


def count_square(width, height, diameter, spacing):
    pitch = diameter + spacing
    if pitch > width or diameter > height:
        cols = max(0, math.floor((width - diameter) / pitch) + 1)
    else:
        cols = math.floor((width - diameter) / pitch) + 1
    rows = math.floor((height - diameter) / pitch) + 1
    cols = max(0, cols)
    rows = max(0, rows)
    return cols * rows


def count_hex(width, height, diameter, spacing, rotated=False):
    """
    rotated=False: rows run along width (W), rows offset, stacked in height (H)
    rotated=True:  columns run along height (H), columns offset, stacked in width (W)
    (i.e. the same pattern turned 90 degrees, since a hex packing isn't
    symmetric under swapping which axis the "rows" run along)
    """
    if rotated:
        width, height = height, width

    pitch = diameter + spacing
    row_height = pitch * math.sqrt(3) / 2

    rows = math.floor((height - diameter) / row_height) + 1
    if rows < 0:
        return 0

    total = 0
    for row in range(rows):
        offset_row = (row % 2 == 1)
        if offset_row:
            avail = width - diameter - pitch / 2
        else:
            avail = width - diameter
        cols = math.floor(avail / pitch) + 1 if avail >= 0 else 0
        total += max(0, cols)

    return total


def compare(width, height, diameter, spacing):
    sq = count_square(width, height, diameter, spacing)
    hex_normal = count_hex(width, height, diameter, spacing, rotated=False)
    hex_rotated = count_hex(width, height, diameter, spacing, rotated=True)

    results = {
        "square": sq,
        "hex (rows along width)": hex_normal,
        "hex (rows along height)": hex_rotated,
    }

    best = max(results, key=results.get)
    return results, best


if __name__ == "__main__":
    results, best = compare(SHEET_WIDTH, SHEET_HEIGHT, CIRCLE_DIAMETER, SPACING)

    print(f"Sheet: {SHEET_WIDTH} x {SHEET_HEIGHT} mm")
    print(f"Circle diameter: {CIRCLE_DIAMETER} mm, spacing: {SPACING} mm")
    print("-" * 45)
    for name, count in results.items():
        marker = "  <-- best" if name == best else ""
        print(f"{name:28s}: {count:4d} circles{marker}")