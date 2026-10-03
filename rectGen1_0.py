"""
G-code generator for a 2D (X/Y only) hot-wire cutter that cuts RECTANGLES
out of a long block of foam, feeding the block in with a Z-axis feeder.

This is the rectangle sibling of circleGen8: same windows / feeder / homing /
burn-off / squish-room logic, but with a plain grid of rectangles instead of
hex-packed circles (so there is no packing algorithm - every row is the same).

WINDOWS
  A window is ROWS_PER_WINDOW rows tall and BLOCK_WIDTH wide. After a window
  is cut the feeder pushes one window's worth of material past the wire and
  the next window is cut, until the stock runs out (LEAVE_UNCUT left behind).

  SQUISH_ROOM is a per-edge inset: rectangles are planned on
  BLOCK_WIDTH - 2*SQUISH_ROOM and shifted right by SQUISH_ROOM. The same
  inset is applied once in Y at the very start of the job (first window).
  X_GAP / Y_GAP are optional waste strips between rectangles / rows,
  Y_GAP_WINDOW is extra slack at every window seam.

CUT ORDER PER ROW (zigzag weave, then close everything out)

  Rectangle i spans [a_i, b_i] in X, and the row spans [bottom, top] in Y.

  1. FORWARD sweep, left -> right. Starting at X0 on the bottom line, the
     wire weaves: bottom edge of rect 0, then up the right side of rect 0,
     then the TOP edge of rect 1, down its right side, bottom edge of rect 2,
     and so on (a square wave).
  2. At the right end the wire carries on along the current line with
     cutting speed, CUT_OFF_MARGIN past the end of the pattern, so the
     leftover strip on the right is cut away. Coating burn-off (plus
     optional RIGHT_CLEAN_REPEATS rub passes). Then the OTHER line is cut
     across the same leftover strip, back to the last rectangle.
  3. REVERSE sweep, right -> left. Every remaining edge is cut: the
     opposite line of every rectangle. The vertical moves that were already
     cut in the forward sweep are just retraced at TRAVEL_RATE. For
     rectangles that don't share a wall (X_GAP > 0) the left wall is cut
     here and the gap is retraced.
     After each rectangle is fully severed an M102 "knock" is emitted
     (KNOCK_AFTER_RECT).
  4. At the left end the left margin of the second line is cut away too,
     then left-side burn-off (plus LEFT_CLEAN_REPEATS rub passes). Wire is
     left cold.

  Result: when a row is finished, EVERYTHING of that row is cut - both its
  lines across the full width, all vertical walls and both side margins.
  Nothing is left for the next row to do. With Y_GAP = 0 the next row shares
  this row's top line as its bottom line, which has already been cut, so the
  next row retraces it at TRAVEL_RATE instead of cutting it twice. The first
  row of the job (and any row after a gap) cuts its own bottom line.

PERIODIC CLEANING
  Every RECTS_PER_CLEAN-th rectangle (per sweep, counters reset every row)
  the wire, while sitting on a vertical wall at the bottom line, drops down
  that wall to safety_y (SAFETY_BURN_OFF_Y_DISTANCE below the row), burns
  off, reheats, and returns to the same spot. 0 disables it.

FEEDER / HOMING
  Same as circleGen8. One deliberate difference: the first push after window
  1 is window_push + SQUISH_ROOM, because window 1 is shifted up by the Y
  squish inset and window 2 is not. Without the extra SQUISH_ROOM the first
  seam would overlap by SQUISH_ROOM.

Settings: defaults are below; if rectGenConfig.toml exists next to this
script (or one folder above) its values override them. You can copy your
circleGenConfig.toml, rename it, and add RECT_WIDTH / RECT_HEIGHT (and rename
CIRCLES_PER_CLEAN -> RECTS_PER_CLEAN). Unknown ALL_CAPS keys are ignored.

Run:
    python rectGen.py
Output:
    rects.gcode (or whatever OUTPUT_FILE says)
"""

import math
import tomllib
from pathlib import Path


# ---------------- DEFAULT SETTINGS (placeholders - override in the toml) ----------------
# Geometry
RECT_WIDTH = 20.0               # mm, X size of one rectangle
RECT_HEIGHT = 15.0              # mm, Y size of one rectangle
BLOCK_WIDTH = 120.0             # mm, full width of the foam block
X_GAP = 0.0                     # mm, waste strip between neighbouring rectangles
Y_GAP = 0.0                     # mm, waste strip between rows
Y_GAP_WINDOW = 0.0              # mm, extra slack at every window seam
SQUISH_ROOM = 2.0               # mm, per-edge inset (X both sides, Y at job start)
ROWS_PER_WINDOW = 3
CUT_OFF_MARGIN = 5.0            # mm, right-end cut runs this far past the pattern end

# Machine
ORIGIN_X = 0.0
ORIGIN_Y = 10.0                 # also the leading-edge parking distance (SAFETY_DISTANCE)
Y_AXIS_MAX_LIMIT = 150.0
FEED_RATE = 300                 # mm/min while cutting
TRAVEL_RATE = 500               # mm/min while retracing already-cut kerf
Z_FEED_RATE = 300               # mm/min for the feeder

# Heat / cleaning
CUTTING_TEMP = 10
TEMP_SET_TIME = 5000
BURN_OFF_TEMP = 100
BURN_OFF_TIME = 5000
COOL_DOWN_TIME = 5000
COOL_DOWN_TIME_FROM_CUT_TEMP = 5000
SAFETY_BURN_OFF_Y_DISTANCE = 5.0
SAFETY_BURN_OFF_X_DISTANCE = 140.0   # absolute machine X of the right-side burn-off spot
RECTS_PER_CLEAN = 0
RIGHT_CLEAN_REPEATS = 0
LEFT_CLEAN_REPEATS = 0
KNOCK_AFTER_RECT = True         # emit M102 after each rectangle is severed

# Feeder
RAIL_LENGTH = 600.0
MATERIAL_LENGTH = 400.0
LEAVE_UNCUT = 20.0
SINGLE_WINDOW_ONLY = True

OUTPUT_FILE = "rects.gcode"


# ---------------- EXTERNAL CONFIGURATION (optional) ----------------
CONFIG_FILE_CANDIDATES = [
    Path(__file__).parent.parent / "rectGenConfig.toml",
    Path(__file__).with_name("rectGenConfig.toml"),
]
CONFIG_FILE = next((p for p in CONFIG_FILE_CANDIDATES if p.is_file()), None)


def _load_config():
    if CONFIG_FILE is None:
        return
    with CONFIG_FILE.open("rb") as f:
        config = tomllib.load(f)
    settings = config.get("settings", config)
    if not isinstance(settings, dict):
        raise ValueError(f"{CONFIG_FILE.name}: expected a [settings] table.")
    for name, value in settings.items():
        if not name.isupper():
            raise ValueError(f"{CONFIG_FILE.name}: invalid setting '{name}' (must be ALL_CAPS).")
        globals()[name] = value


_load_config()

SAFETY_DISTANCE = ORIGIN_Y   # leading edge parked this far from the wire
LEFT_EDGE_X = 0.0            # machine X0 (same convention as circleGen8)
EPS = 1e-6


# ---------------- LAYOUT ----------------

def row_pitch():
    """Bottom-to-bottom distance of consecutive rows."""
    return RECT_HEIGHT + Y_GAP


def compute_columns():
    """[(a, b), ...] X ranges of the rectangles in one row, in block coordinates."""
    usable = BLOCK_WIDTH - 2 * SQUISH_ROOM
    if usable <= 0:
        raise ValueError("SQUISH_ROOM is too large for BLOCK_WIDTH.")
    count = math.floor((usable + X_GAP) / (RECT_WIDTH + X_GAP) + 1e-9)
    if count < 1:
        raise ValueError("BLOCK_WIDTH is too small for even one rectangle (check SQUISH_ROOM / RECT_WIDTH).")
    return [(SQUISH_ROOM + i * (RECT_WIDTH + X_GAP),
             SQUISH_ROOM + i * (RECT_WIDTH + X_GAP) + RECT_WIDTH) for i in range(count)]


def compute_rows(is_first_window):
    """Plane-local bottom Y of every row in one window."""
    y_start = SQUISH_ROOM if is_first_window else 0.0
    return [y_start + i * row_pitch() for i in range(ROWS_PER_WINDOW)]


def bottom_line_precut(row_index, is_first_window):
    """
    True when this row's bottom line was already cut by the previous row's
    top line (zero gaps), so it only needs retracing.
    """
    if row_index > 0:
        return Y_GAP < EPS
    if is_first_window:
        return False
    return Y_GAP < EPS and Y_GAP_WINDOW < EPS


# ---------------- G-CODE EMITTERS ----------------

def burn_off_coating(lines):
    """Coating burn-off heat/cool cycle. Wire must sit still for all of it."""
    lines.append(f"M101 P{COOL_DOWN_TIME_FROM_CUT_TEMP} R0 ; cool down the wire")
    lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
    lines.append(f"M101 P{COOL_DOWN_TIME} R0 ; cool down the wire")


class RowWriter:
    """Tracks the wire position while emitting one row."""

    def __init__(self, lines, abs_bottom, abs_top, safety_y):
        self.lines = lines
        self.bottom = abs_bottom
        self.top = abs_top
        self.safety_y = safety_y
        self.x = None
        self.y = None

    def ly(self, is_bottom):
        return self.bottom if is_bottom else self.top

    def goto(self, x, y, rate, comment=""):
        if self.x is not None and abs(x - self.x) < 1e-9 and abs(y - self.y) < 1e-9:
            return  # zero-length move
        tail = f" ; {comment}" if comment else ""
        self.lines.append(f"G1 X{x:.3f} Y{y:.3f} F{rate}{tail}")
        self.x, self.y = x, y

    def clean_drop(self, x):
        """Periodic clean: down the wall at x to safety_y, burn off, reheat, back up."""
        self.goto(x, self.safety_y, FEED_RATE,
                  f"periodic clean ({RECTS_PER_CLEAN}-rect interval): drop to safety Y")
        burn_off_coating(self.lines)
        self.lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
        self.goto(x, self.bottom, TRAVEL_RATE, "return from periodic clean")

    def vertical(self, x, to_y, already_cut, clean, knock=False, comment=""):
        """Vertical wall move; optional periodic clean at the bottom end, optional knock."""
        rate = TRAVEL_RATE if already_cut else FEED_RATE
        from_bottom = abs(self.y - self.bottom) < 1e-9
        to_bottom = abs(to_y - self.bottom) < 1e-9
        if clean and from_bottom:
            self.clean_drop(x)
        self.goto(x, to_y, rate, comment + (" (already cut, retrace)" if already_cut else ""))
        if knock:
            self.lines.append("M102 ; do the 360 knock")
        if clean and to_bottom:
            self.clean_drop(x)


def emit_row(lines, row_y, cols, bottom_precut):
    """Append the G-code for one full row (see module docstring)."""
    abs_bottom = ORIGIN_Y + row_y
    abs_top = abs_bottom + RECT_HEIGHT

    safety_y = abs_bottom - SAFETY_BURN_OFF_Y_DISTANCE
    if safety_y <= 0:
        raise ValueError(
            "SAFETY_BURN_OFF_Y_DISTANCE causes the machine to go into negative Y, "
            "that would hit the frame"
        )

    w = RowWriter(lines, abs_bottom, abs_top, safety_y)
    xs = [(ORIGIN_X + a, ORIGIN_X + b) for a, b in cols]
    n = len(xs)
    x_end = ORIGIN_X + BLOCK_WIDTH - SQUISH_ROOM + CUT_OFF_MARGIN

    cut_verticals = set()  # rounded X of every wall cut so far in this row

    def fwd_is_bottom(i):          # forward-sweep edge of rect i
        return i % 2 == 0

    def hrate(is_bottom):          # horizontal line: retrace if the row below already cut it
        return TRAVEL_RATE if (is_bottom and bottom_precut) else FEED_RATE

    def name(is_bottom):
        return "bottom" if is_bottom else "top"

    def want_clean(counter):
        return RECTS_PER_CLEAN > 0 and counter % RECTS_PER_CLEAN == 0

    lines.append(f"M101 R{CUTTING_TEMP} P{TEMP_SET_TIME} ; heat wire to cutting temp")
    w.goto(0.0, w.ly(True), TRAVEL_RATE, "travel to left edge, X0")

    # ---- forward sweep: weave left -> right ----
    fwd_counter = 0
    for i, (a, b) in enumerate(xs):
        eb = fwd_is_bottom(i)
        w.goto(b, w.ly(eb), hrate(eb), f"rect {i + 1}: cut {name(eb)} edge")
        fwd_counter += 1
        w.vertical(b, w.ly(not eb), already_cut=False, clean=want_clean(fwd_counter),
                   comment=f"rect {i + 1}: cut right wall")
        cut_verticals.add(round(b, 3))

    # ---- right end: cut the leftover strip away, burn off ----
    last_eb = fwd_is_bottom(n - 1)
    cur_is_bottom = not last_eb       # line the wire is on after the last wall
    b_last = xs[-1][1]
    cur_y = w.ly(cur_is_bottom)

    w.goto(x_end, cur_y, hrate(cur_is_bottom), "cut off right side of the row")

    w.goto(SAFETY_BURN_OFF_X_DISTANCE, safety_y, TRAVEL_RATE, "move to burn off coating")
    burn_off_coating(lines)
    if RIGHT_CLEAN_REPEATS != 0:
        w.goto(x_end, cur_y, TRAVEL_RATE, "come back from burn-off spot")
    for _ in range(RIGHT_CLEAN_REPEATS):
        w.goto(b_last, cur_y, TRAVEL_RATE, "rub clean along existing right-edge cut")
        w.goto(x_end, cur_y, TRAVEL_RATE, "rub clean along existing right-edge cut")
    w.goto(SAFETY_BURN_OFF_X_DISTANCE, safety_y, TRAVEL_RATE, "move to heat up")
    lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
    w.goto(x_end, cur_y, TRAVEL_RATE, "come back from cleaning")

    # the other line across the same leftover strip, then back onto the weave
    if x_end - b_last > EPS:
        w.goto(x_end, w.ly(last_eb), TRAVEL_RATE, "switch line outside the material")
        w.goto(b_last, w.ly(last_eb), hrate(last_eb),
               f"cut {name(last_eb)} line across right leftover strip")
        w.goto(b_last, cur_y, TRAVEL_RATE, "back along existing wall to the weave line")

    # ---- reverse sweep: right -> left, cut every remaining edge ----
    rev_counter = 0
    for i in range(n - 1, -1, -1):
        a, b = xs[i]
        eb = fwd_is_bottom(i)
        rb = not eb                                   # this rect's remaining edge
        w.goto(a, w.ly(rb), hrate(rb), f"rect {i + 1}: cut {name(rb)} edge")

        if i == 0 and a - LEFT_EDGE_X > EPS:
            w.goto(LEFT_EDGE_X, w.ly(rb), hrate(rb), f"cut {name(rb)} line across left margin")
            w.goto(a, w.ly(rb), TRAVEL_RATE, "back to rect 1's left wall")

        rev_counter += 1
        already = round(a, 3) in cut_verticals
        w.vertical(a, w.ly(eb), already_cut=already, clean=want_clean(rev_counter),
                   knock=KNOCK_AFTER_RECT, comment=f"rect {i + 1}: left wall")
        cut_verticals.add(round(a, 3))

        if i > 0:
            prev_b = xs[i - 1][1]
            if prev_b < a - EPS:
                w.goto(prev_b, w.ly(eb), TRAVEL_RATE, "travel back over gap")

    # ---- left end ----
    leftmost_x = xs[0][0]
    w.goto(LEFT_EDGE_X, w.ly(True), TRAVEL_RATE, "move to left edge (X0)")
    w.goto(LEFT_EDGE_X, safety_y, TRAVEL_RATE, "move to a safe spot, burn off coating")
    burn_off_coating(lines)

    if LEFT_CLEAN_REPEATS > 0 and leftmost_x - LEFT_EDGE_X > EPS:
        w.goto(LEFT_EDGE_X, w.ly(True), TRAVEL_RATE, "back up to the row line")
        for _ in range(LEFT_CLEAN_REPEATS):
            w.goto(leftmost_x, w.ly(True), TRAVEL_RATE, "rub clean along existing left-edge cut")
            w.goto(LEFT_EDGE_X, w.ly(True), TRAVEL_RATE, "rub clean along existing left-edge cut")


def emit_home(lines, axes):
    """Return the given axes to nominal zero, wire cold."""
    coords = " ".join(f"{axis}0.000" for axis in axes)
    lines.append(f"M101 R0 P{TEMP_SET_TIME} ; kill unecessary heat")
    lines.append(f"G1 {coords} F{TRAVEL_RATE} ; move to nominal {axes} zero")


# ---------------- TOP LEVEL ----------------

def validate_settings():
    if not (isinstance(RECTS_PER_CLEAN, int) and RECTS_PER_CLEAN >= 0):
        raise ValueError("RECTS_PER_CLEAN must be a non-negative integer (0 disables periodic cleaning).")
    if not (isinstance(ROWS_PER_WINDOW, int) and ROWS_PER_WINDOW >= 1):
        raise ValueError("ROWS_PER_WINDOW must be an integer of at least 1.")
    if RECT_WIDTH <= 0 or RECT_HEIGHT <= 0:
        raise ValueError("RECT_WIDTH and RECT_HEIGHT must be positive.")

    top_of_window = ORIGIN_Y + SQUISH_ROOM + (ROWS_PER_WINDOW - 1) * row_pitch() + RECT_HEIGHT
    if top_of_window > Y_AXIS_MAX_LIMIT + 1e-9:
        raise ValueError(
            f"ROWS_PER_WINDOW={ROWS_PER_WINDOW} needs Y up to {top_of_window:.3f}mm, "
            f"past Y_AXIS_MAX_LIMIT={Y_AXIS_MAX_LIMIT}mm - reduce ROWS_PER_WINDOW, "
            f"RECT_HEIGHT, Y_GAP or ORIGIN_Y."
        )


def generate_gcode():
    validate_settings()

    cols = compute_columns()
    window_push = ROWS_PER_WINDOW * row_pitch() + Y_GAP_WINDOW

    lines = []
    lines.append("; Rectangle grid - zigzag weave, full row-finish cut order + feeder logic")
    lines.append(f"; rect {RECT_WIDTH}x{RECT_HEIGHT}mm, {len(cols)} per row, {ROWS_PER_WINDOW} row(s) per window, "
                 f"block width {BLOCK_WIDTH}mm, X_GAP={X_GAP} Y_GAP={Y_GAP} "
                 f"Y_GAP_WINDOW={Y_GAP_WINDOW} SQUISH_ROOM={SQUISH_ROOM} CUT_OFF_MARGIN={CUT_OFF_MARGIN}")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")

    total_rects = 0
    total_windows = 0

    def emit_window(is_first_window):
        nonlocal total_rects
        for row_index, row_y in enumerate(compute_rows(is_first_window)):
            emit_row(lines, row_y, cols, bottom_line_precut(row_index, is_first_window))
            total_rects += len(cols)

    if SINGLE_WINDOW_ONLY:
        lines.append("; SINGLE_WINDOW_ONLY = True: feeder logic skipped")
        emit_home(lines, "XY")
        emit_window(True)
        total_windows = 1
        lines.append("M2 ; end of program")
        return "\n".join(lines), {
            "total_rects": total_rects, "total_windows": 1, "cols": len(cols),
            "single_window_only": True,
        }

    rail_gap = RAIL_LENGTH - MATERIAL_LENGTH
    unusable_space = rail_gap - Y_AXIS_MAX_LIMIT
    initial_push = rail_gap - SAFETY_DISTANCE
    if initial_push < 0:
        raise ValueError(
            "MATERIAL_LENGTH/RAIL_LENGTH/SAFETY_DISTANCE combination implies the stock already "
            "sits past the safety distance with zero push - check those variables."
        )

    lines.append(f"; RAIL_LENGTH={RAIL_LENGTH}mm MATERIAL_LENGTH={MATERIAL_LENGTH}mm "
                 f"Y_AXIS_MAX_LIMIT={Y_AXIS_MAX_LIMIT}mm -> unusable dead space at load "
                 f"= {unusable_space:.3f}mm (informational only)")
    lines.append(f"; initial feed push = {initial_push:.3f}mm, per-window feed push = {window_push:.3f}mm "
                 f"(first seam +{SQUISH_ROOM:g}mm to account for the first-window Y inset)")
    lines.append(
        f"G1 Z{initial_push:.3f} F{Z_FEED_RATE} ; feed material in, ledge parked "
        f"{SAFETY_DISTANCE:.3f}mm from the wire"
    )

    z_pos = initial_push
    max_Z_push = RAIL_LENGTH - Y_AXIS_MAX_LIMIT

    while True:
        is_first_window = (total_windows == 0)
        lines.append(f"; --- window {total_windows + 1} (Z={z_pos:.3f}) ---")
        emit_window(is_first_window)
        total_windows += 1

        emit_home(lines, "XY")

        if z_pos > max_Z_push:
            raise ValueError("the Z axis push would hit the metal frame and exceed expected number of cutting rows")

        next_push = window_push + (SQUISH_ROOM if total_windows == 1 else 0.0)
        remaining = max_Z_push - LEAVE_UNCUT - z_pos
        if remaining < next_push + 1e-6:
            break

        z_pos += next_push
        lines.append(f"G1 Z{z_pos:.3f} F{Z_FEED_RATE} ; feed {next_push:.3f}mm more material in")

    lines.append("M2 ; end of program")

    return "\n".join(lines), {
        "total_rects": total_rects, "total_windows": total_windows, "cols": len(cols),
        "unusable_space": unusable_space, "initial_push": initial_push,
        "window_push": window_push, "leftover": max_Z_push - z_pos,
        "single_window_only": False,
    }


if __name__ == "__main__":
    gcode, stats = generate_gcode()
    with open(OUTPUT_FILE, "w") as f:
        f.write(gcode)
    print(f"G-code written to {OUTPUT_FILE}")
    print(f"{stats['total_rects']} rectangles ({stats['cols']} per row) across {stats['total_windows']} "
          f"windows ({ROWS_PER_WINDOW} rows/window), {RECT_WIDTH}x{RECT_HEIGHT}mm, "
          f"block width {BLOCK_WIDTH}mm, X_GAP={X_GAP}, Y_GAP={Y_GAP}, Y_GAP_WINDOW={Y_GAP_WINDOW}, "
          f"RECTS_PER_CLEAN={RECTS_PER_CLEAN}")
    if stats["single_window_only"]:
        print("SINGLE_WINDOW_ONLY = True: feeder logic skipped, generated exactly one window.")
    else:
        print(f"Rail: {RAIL_LENGTH}mm, material: {MATERIAL_LENGTH}mm, "
              f"unusable dead space at load: {stats['unusable_space']:.3f}mm")
        print(f"Initial feed push: {stats['initial_push']:.3f}mm, "
              f"per-window feed push: {stats['window_push']:.3f}mm")
        print(f"Leftover unused material at end of job: {stats['leftover']:.3f}mm")