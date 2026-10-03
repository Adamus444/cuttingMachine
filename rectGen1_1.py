"""
G-code generator for a 2D (X/Y only) hot-wire cutter that cuts RECTANGLES
out of a long block of foam, feeding the block in with a Z-axis feeder.

Rectangle sibling of circleGen8: same windows / feeder / homing / burn-off /
squish-room logic, but a plain grid of rectangles instead of hex-packed
circles. Rectangles always touch each other (there are no X/Y gaps), so
neighbouring rectangles share their walls and rows share their lines.

WINDOWS
  A window is ROWS_PER_WINDOW rows tall and BLOCK_WIDTH wide. After a window
  is cut, the feeder pushes one window's worth of material past the wire and
  the next window is cut, until the stock runs out (LEAVE_UNCUT left behind).

  SQUISH_ROOM is a per-edge inset in X (both sides). The same inset is
  applied once in Y at the very start of the job (first window only).

CUT ORDER PER ROW

  Names used below: "bottom line" / "top line" are the two horizontal lines
  that bound the row. Rectangle i spans [x_left, x_right].

  0. FIRST ROW OF THE JOB ONLY: the bottom line is cut straight across,
     X0 -> past the right end, then the wire travels back to X0. Every other
     row gets its bottom line for free (see step 3), so this is the only
     row that has to cut one.

  1. FORWARD SWEEP (zigzag, left -> right):
       rect 1: bottom edge, then up its right wall
       rect 2: top edge,    then down its right wall
       rect 3: bottom edge, then up its right wall   ... and so on.
     The bottom edges are already cut (step 0 or step 3 of the row below),
     so they are only retraced at TRAVEL_RATE. Top edges and walls are cut.
     UPDATE: tehy would be if there wasnt Y_GAP_WINDOW.

  2. RIGHT END: the wire keeps going along the line it is on, to
     CUT_OFF_MARGIN past the end of the pattern, at cutting speed, so the
     leftover strip on the right is cut away. Then coating burn-off (plus
     optional RIGHT_CLEAN_REPEATS rub-clean passes) and reheat.

  3. REVERSE SWEEP (straight line, right -> left): the wire goes to the TOP
     line and cuts straight across it back to X0. After each rectangle's
     top edge is cut the rectangle is completely free, so M102 (the "knock")
     is emitted right there. Rectangle 1 additionally has its own LEFT wall
     cut at the end (nothing else cuts it), then M102.
     Because this top line is complete across the whole width, it IS the
     bottom line of the next row - that's why the next row doesn't cut one.

  4. LEFT END: the wire goes back to X0, coating burn-off (plus optional
     LEFT_CLEAN_REPEATS rub-clean passes). The wire is left cold.

PERIODIC CLEANING
  After every RECTS_PER_CLEAN-th rectangle (each sweep counts on its own and
  resets every row) the wire drops straight down the wall it is sitting on
  (an already-cut wall) to safety_y, burns off, reheats, and goes back up to
  the same spot. 0 disables it.

FEEDER / HOMING
  Same as circleGen8, with one difference: the first push after window 1 is
  one SQUISH_ROOM longer than the others. Window 1 is shifted up by the Y
  inset and window 2 is not, so without the extra push the first seam would
  overlap by SQUISH_ROOM.

Settings live in rectGenConfig.toml (nothing is hard coded in this file).
They are loaded into this module's globals at import time, so the front end
can reload() the module and overwrite any ALL_CAPS variable before calling
generate_gcode(), exactly like it does with circleGen.

Run:
    python rectGen.py
Output:
    rects.gcode (or whatever OUTPUT_FILE says)
"""

import math
import tomllib
from pathlib import Path


# ---------------- EXTERNAL CONFIGURATION ----------------
# All generator settings live in rectGenConfig.toml instead of this source
# file. The config is loaded at import time, which also means the adapter
# gets a fresh set of config values after reload().
CONFIG_FILE_CANDIDATES = [
    Path(__file__).parent.parent / "rectGenConfig.toml",
    Path(__file__).with_name("rectGenConfig.toml"),
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
# is exactly where row Y coordinates are measured from.
SAFETY_DISTANCE = ORIGIN_Y

# Machine X0. Same convention as circleGen: "go to the left edge" always
# means the literal machine X0, not ORIGIN_X.
LEFT_EDGE_X = 0.0

# Tolerance for "is this distance really greater than zero".
SMALL = 1e-6


# ---------------- LAYOUT ----------------

def compute_rect_columns():
    """
    Return [(x_left, x_right), ...] for the rectangles of ONE row, left to
    right, in machine X coordinates. Every row is identical.

    The row is planned on BLOCK_WIDTH minus the squish inset on both sides.
    Whatever width doesn't fit a whole rectangle is simply left over on the
    right and gets cut away by the cut-off move.
    """
    usable_width = BLOCK_WIDTH - 2 * SQUISH_ROOM
    if usable_width <= 0:
        raise ValueError("SQUISH_ROOM is too large for the given BLOCK_WIDTH.")

    rect_count = math.floor(usable_width / RECT_WIDTH + 1e-9)
    if rect_count < 1:
        raise ValueError(
            "BLOCK_WIDTH is too small for even one rectangle "
            "(check RECT_WIDTH and SQUISH_ROOM)."
        )

    rect_columns = []
    for index in range(rect_count):
        x_left = ORIGIN_X + SQUISH_ROOM + index * RECT_WIDTH
        x_right = x_left + RECT_WIDTH
        rect_columns.append((x_left, x_right))

    return rect_columns


def compute_row_bottoms(is_first_window):
    """
    Return the plane-local Y of the bottom line of every row in one window
    (ORIGIN_Y is added at emit time). Rows touch, so the pitch is exactly
    RECT_HEIGHT. Only the first window of the job has the Y squish inset.
    """
    y_start = SQUISH_ROOM if is_first_window else 0.0

    row_bottoms = []
    for row_number in range(ROWS_PER_WINDOW):
        row_bottoms.append(y_start + row_number * RECT_HEIGHT)

    return row_bottoms


# ---------------- G-CODE EMITTERS ----------------

def burn_off_coating(lines):
    """
    The coating burn-off heat/cool cycle. The wire is meant to sit still for
    the whole thing, so nothing else may be spliced in between these moves.
    """
    lines.append(f"M101 P{COOL_DOWN_TIME_FROM_CUT_TEMP} R0 ; cool down the wire")
    lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
    lines.append(f"M101 P{COOL_DOWN_TIME} R0 ; cool down the wire")


def periodic_clean(lines, wall_x, return_y, safety_y):
    """
    Periodic cleaning stop. The wire is sitting on an already-cut wall at
    (wall_x, return_y). It drops down that wall to safety_y, burns off,
    reheats, and comes back up to exactly where it was.
    """
    lines.append(
        f"G1 X{wall_x:.3f} Y{safety_y:.3f} F{FEED_RATE} "
        f"; periodic clean ({RECTS_PER_CLEAN}-rect interval): drop down the wall to safety Y"
    )
    burn_off_coating(lines)
    lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
    lines.append(
        f"G1 X{wall_x:.3f} Y{return_y:.3f} F{TRAVEL_RATE} "
        f"; return up the wall from periodic clean"
    )


def emit_first_row_bottom_cut(lines, bottom_y, cut_off_x):
    """
    First row of the job only: cut the bottom line straight across the whole
    width, then travel back to X0. Without this, every second rectangle of
    the first row would stay attached on its bottom edge, because the zigzag
    only cuts the bottom edge of every other rectangle.
    """
    lines.append(
        f"G1 X{cut_off_x:.3f} Y{bottom_y:.3f} F{FEED_RATE} "
        f"; first row of the job: cut the bottom line across the full width"
    )
    lines.append(
            f"G1 X{cut_off_x:.3f} Y{bottom_y - SAFETY_BURN_OFF_Y_DISTANCE:.3f} F{TRAVEL_RATE} "
            f"; travel back to left edge, X0"
        )
    lines.append(
        f"G1 X{LEFT_EDGE_X:.3f} Y{bottom_y - SAFETY_BURN_OFF_Y_DISTANCE:.3f} F{TRAVEL_RATE} "
        f"; travel back to left edge, X0"
    )
    lines.append(
        f"G1 X{LEFT_EDGE_X:.3f} Y{bottom_y:.3f} F{TRAVEL_RATE} "
        f"; travel back to left edge, X0"
    )


def emit_forward_sweep(lines, rect_columns, bottom_y, top_y, safety_y):
    """
    The zigzag, left -> right. Assumes the wire is at X0 on the bottom line.

    Rectangles are numbered from 1 in the comments. Odd rectangles (1, 3, ..)
    cut their bottom edge and then go UP their right wall. Even rectangles
    (2, 4, ..) cut their top edge and then go DOWN their right wall.
    """
    for index, (x_left, x_right) in enumerate(rect_columns):
        rect_number = index + 1
        goes_along_bottom = (index % 2 == 0)

        if goes_along_bottom:
            # Bottom line is already cut, so this is only a retrace.
            lines.append(
                f"G1 X{x_right:.3f} Y{bottom_y:.3f} F{FEED_RATE} "
                f"; rect {rect_number}: bottom edge (line already cut?)"
            )
            lines.append(
                f"G1 X{x_right:.3f} Y{top_y:.3f} F{FEED_RATE} "
                f"; rect {rect_number}: cut right wall, going up"
            )
            wire_y_after_wall = top_y
        else:
            lines.append(
                f"G1 X{x_right:.3f} Y{top_y:.3f} F{FEED_RATE} "
                f"; rect {rect_number}: cut top edge"
            )
            lines.append(
                f"G1 X{x_right:.3f} Y{bottom_y:.3f} F{FEED_RATE} "
                f"; rect {rect_number}: cut right wall, going down"
            )
            wire_y_after_wall = bottom_y

        # Periodic clean, from the wall we just cut.
        if RECTS_PER_CLEAN > 0 and rect_number % RECTS_PER_CLEAN == 0:
            periodic_clean(lines, x_right, wire_y_after_wall, safety_y)


def emit_right_end(lines, rect_columns, bottom_y, top_y, safety_y, cut_off_x):
    """
    Cut away the leftover strip on the right, burn off, reheat, and finish
    with the wire standing on the TOP line at cut_off_x, ready for the
    reverse sweep. Assumes the forward sweep just finished.
    """
    rect_count = len(rect_columns)
    last_right = rect_columns[-1][1]

    # The zigzag ends on the top line if the last rectangle is odd-numbered
    # (it went up its wall), otherwise on the bottom line.
    last_rect_went_up = ((rect_count - 1) % 2 == 0)
    if last_rect_went_up:
        end_y = top_y
        end_line_name = "top"
    else:
        end_y = bottom_y
        end_line_name = "bottom"

    # Keep going along the same line at cutting speed, past the end of the
    # pattern, so the leftover strip comes free.
    lines.append(
        f"G1 X{cut_off_x:.3f} Y{end_y:.3f} F{FEED_RATE} "
        f"; cut off the right side of the row along the {end_line_name} line"
    )

    # Burn off at the right-side spot.
    lines.append(
        f"G1 X{SAFETY_BURN_OFF_X_DISTANCE:.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
        f"; move to burn off coating"
    )
    burn_off_coating(lines)

    # Optional rub-clean passes along the fresh right-edge cut.
    if RIGHT_CLEAN_REPEATS != 0:
        lines.append(
            f"G1 X{cut_off_x:.3f} Y{end_y:.3f} F{TRAVEL_RATE} "
            f"; come back from burn-off spot"
        )
    for _ in range(RIGHT_CLEAN_REPEATS):
        lines.append(
            f"G1 X{last_right:.3f} Y{end_y:.3f} F{TRAVEL_RATE} "
            f"; rub clean along existing right-edge cut"
        )
        lines.append(
            f"G1 X{cut_off_x:.3f} Y{end_y:.3f} F{TRAVEL_RATE} "
            f"; rub clean along existing right-edge cut"
        )

    # Reheat, then come back to the row.
    lines.append(
        f"G1 X{SAFETY_BURN_OFF_X_DISTANCE:.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
        f"; move to heat up"
    )
    lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
    lines.append(
        f"G1 X{cut_off_x:.3f} Y{end_y:.3f} F{TRAVEL_RATE} "
        f"; come back from cleaning"
    )

    # Get onto the top line. If the wire is on the bottom line this move is
    # outside the material, so it is a plain travel.
    if end_y != top_y:
        lines.append(
            f"G1 X{cut_off_x:.3f} Y{top_y:.3f} F{TRAVEL_RATE} "
            f"; move up to the top line, outside the material"
        )


def emit_reverse_sweep(lines, rect_columns, bottom_y, top_y, safety_y, cut_off_x):
    """
    The straight cut along the TOP line, right -> left, with an M102 knock
    after every rectangle. Assumes the wire is at (cut_off_x, top_y).

    Returns the Y the wire is at when the sweep is over (it is at rect 1's
    left wall, either at the top or - if the wall had to be cut - at the
    bottom).
    """
    rect_count = len(rect_columns)
    last_right = rect_columns[-1][1]
    first_left = rect_columns[0][0]

    # Cut the leftover strip's part of the top line, up to the last rectangle.
    # (If the zigzag already ended on the top line this retraces it.)
    if cut_off_x - last_right > SMALL:
        lines.append(
            f"G1 X{last_right:.3f} Y{top_y:.3f} F{FEED_RATE} "
            f"; top line: cut across the right leftover strip"
        )

    wire_y = top_y

    # Go through the rectangles from the last one to the first one.
    for index in range(rect_count - 1, -1, -1):
        x_left = rect_columns[index][0]
        rect_number = index + 1
        reverse_number = rect_count - index   # 1 for the rightmost rectangle

        lines.append(
            f"G1 X{x_left:.3f} Y{top_y:.3f} F{FEED_RATE} "
            f"; rect {rect_number}: cut top edge, straight line"
        )
        wire_y = top_y

        if index == 0 and first_left - LEFT_EDGE_X > SMALL:
            # Rect 1 has a squish margin on its left. Cut the top line
            # through the margin, come back, and cut rect 1's left wall -
            # nothing else cuts that wall.
            lines.append(
                f"G1 X{LEFT_EDGE_X:.3f} Y{top_y:.3f} F{FEED_RATE} "
                f"; top line: cut across the left margin"
            )
            lines.append(
                f"G1 X{first_left:.3f} Y{top_y:.3f} F{TRAVEL_RATE} "
                f"; back to rect 1's left wall"
            )
            lines.append(
                f"G1 X{first_left:.3f} Y{bottom_y:.3f} F{FEED_RATE} "
                f"; rect 1: cut left wall, going down"
            )
            wire_y = bottom_y

        lines.append("M102 ; do the 360 knock")

        if RECTS_PER_CLEAN > 0 and reverse_number % RECTS_PER_CLEAN == 0:
            periodic_clean(lines, x_left, wire_y, safety_y)

    return wire_y


def emit_left_end(lines, rect_columns, bottom_y, safety_y, wire_y):
    """
    Back to X0, burn off, optional rub-clean passes. The wire is left cold
    (the next row heats it again). wire_y is where the reverse sweep ended.
    """
    first_left = rect_columns[0][0]

    lines.append(
        f"G1 X{LEFT_EDGE_X:.3f} Y{wire_y:.3f} F{TRAVEL_RATE} "
        f"; move to left edge (X0)"
    )
    lines.append(
        f"G1 X{LEFT_EDGE_X:.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
        f"; move to a safe spot, burn off coating"
    )
    burn_off_coating(lines)

    # Rub-clean along the already-cut part of the bottom line in the margin.
    # Only possible when there is a margin.
    if LEFT_CLEAN_REPEATS > 0 and first_left - LEFT_EDGE_X > SMALL:
        lines.append(
            f"G1 X{LEFT_EDGE_X:.3f} Y{bottom_y:.3f} F{TRAVEL_RATE} "
            f"; back up to the bottom line"
        )
        for _ in range(LEFT_CLEAN_REPEATS):
            lines.append(
                f"G1 X{first_left:.3f} Y{bottom_y:.3f} F{TRAVEL_RATE} "
                f"; rub clean along existing left-edge cut"
            )
            lines.append(
                f"G1 X{LEFT_EDGE_X:.3f} Y{bottom_y:.3f} F{TRAVEL_RATE} "
                f"; rub clean along existing left-edge cut"
            )


def emit_row(lines, row_y, rect_columns, is_first_row):
    """Append the G-code for one full row, in the order described at the top of this file."""
    bottom_y = ORIGIN_Y + row_y
    top_y = bottom_y + RECT_HEIGHT

    # Parking spot for every burn-off in this row. Must stay positive or the
    # gantry would drive into the frame.
    safety_y = bottom_y - SAFETY_BURN_OFF_Y_DISTANCE
    if safety_y <= 0:
        raise ValueError(
            "SAFETY_BURN_OFF_Y_DISTANCE causes the machine to go into negative Y, "
            "that would hit the frame"
        )

    # Where the right-end cut stops: CUT_OFF_MARGIN past the end of the pattern.
    cut_off_x = ORIGIN_X + BLOCK_WIDTH - SQUISH_ROOM + CUT_OFF_MARGIN

    # Heat up and travel to the left edge, X0, on the bottom line.
    lines.append(f"M101 R{CUTTING_TEMP} P{TEMP_SET_TIME} ; heat wire to cutting temp")
    lines.append(
        f"G1 X{LEFT_EDGE_X:.3f} Y{bottom_y:.3f} F{TRAVEL_RATE} "
        f"; travel to left edge, X0"
    )

    if is_first_row:
        emit_first_row_bottom_cut(lines, bottom_y, cut_off_x)

    emit_forward_sweep(lines, rect_columns, bottom_y, top_y, safety_y)
    emit_right_end(lines, rect_columns, bottom_y, top_y, safety_y, cut_off_x)
    wire_y = emit_reverse_sweep(lines, rect_columns, bottom_y, top_y, safety_y, cut_off_x)
    emit_left_end(lines, rect_columns, bottom_y, safety_y, wire_y)


def emit_home(lines, axes):
    """
    Return the given axes (e.g. "XY" or "XYZ") to nominal zero with a plain
    G1 move, wire cold. Positions are tracked in software the whole job, so
    no mechanical homing is involved.
    """
    coords = " ".join(f"{axis}0.000" for axis in axes)
    lines.append(f"M101 R0 P{TEMP_SET_TIME} ; kill unecessary heat")
    lines.append(f"G1 {coords} F{TRAVEL_RATE} ; move to nominal {axes} zero")


# ---------------- TOP LEVEL ----------------

def validate_settings():
    """Range-check the settings that would otherwise fail in confusing ways."""
    if RECT_WIDTH <= 0 or RECT_HEIGHT <= 0:
        raise ValueError("RECT_WIDTH and RECT_HEIGHT must be positive.")
    if not (isinstance(RECTS_PER_CLEAN, int) and RECTS_PER_CLEAN >= 0):
        raise ValueError("RECTS_PER_CLEAN must be a non-negative integer (0 disables periodic cleaning).")
    if not (isinstance(ROWS_PER_WINDOW, int) and ROWS_PER_WINDOW >= 1):
        raise ValueError("ROWS_PER_WINDOW must be an integer of at least 1.")

    # The topmost row of a window has to stay inside the machine's Y travel.
    top_of_window = ORIGIN_Y + SQUISH_ROOM + ROWS_PER_WINDOW * RECT_HEIGHT
    if top_of_window > Y_AXIS_MAX_LIMIT + 1e-9:
        raise ValueError(
            f"ROWS_PER_WINDOW={ROWS_PER_WINDOW} needs Y up to {top_of_window:.3f}mm, "
            f"past Y_AXIS_MAX_LIMIT={Y_AXIS_MAX_LIMIT}mm - reduce ROWS_PER_WINDOW, "
            f"RECT_HEIGHT or ORIGIN_Y."
        )


def emit_window(lines, rect_columns, is_first_window):
    """Append every row of one window. Returns how many rectangles were cut."""
    row_bottoms = compute_row_bottoms(is_first_window)

    for row_index, row_y in enumerate(row_bottoms):
        is_first_row = is_first_window and (row_index == 0)
        emit_row(lines, row_y, rect_columns, is_first_row)

    return len(row_bottoms) * len(rect_columns)


def generate_gcode():
    validate_settings()

    rect_columns = compute_rect_columns()

    # One feed push = one window's worth of rows. Rows touch, so there is no
    # slack to add.
    window_push = ROWS_PER_WINDOW * RECT_HEIGHT + Y_GAP_WINDOW

    lines = []
    lines.append("; Rectangle grid - zigzag forward sweep, straight reverse cut with knocks + feeder logic")
    lines.append(f"; 2D hot-wire cutting, X/Y only - clean every {RECTS_PER_CLEAN:g} rectangles per sweep")
    lines.append(f"; window = {ROWS_PER_WINDOW} row(s) per push, rectangle {RECT_WIDTH}x{RECT_HEIGHT}mm, "
                 f"{len(rect_columns)} per row, block width {BLOCK_WIDTH}mm, "
                 f"SQUISH_ROOM={SQUISH_ROOM}mm CUT_OFF_MARGIN={CUT_OFF_MARGIN}mm")
    lines.append("G21 ; units = mm")
    lines.append("G90 ; absolute positioning")

    total_rects = 0
    total_windows = 0

    if SINGLE_WINDOW_ONLY:
        # No feeder involved at all - cut one window and stop.
        lines.append("; SINGLE_WINDOW_ONLY = True: feeder/homing-between-windows logic skipped")
        emit_home(lines, "XY")

        total_rects += emit_window(lines, rect_columns, is_first_window=True)
        total_windows = 1

        lines.append("M2 ; end of program")

        stats = {
            "total_rects": total_rects,
            "total_windows": total_windows,
            "rects_per_row": len(rect_columns),
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
                 f"per-window feed push = {window_push:.3f}mm "
                 f"(the first one is {SQUISH_ROOM:g}mm longer, for the first-window Y inset)")

    # Initial push: close the dead rail gap and park the material's leading
    # edge SAFETY_DISTANCE from the wire.
    lines.append(
        f"G1 Z{initial_push:.3f} F{Z_FEED_RATE} ; feed material in, ledge parked "
        f"{SAFETY_DISTANCE:.3f}mm from the wire"
    )

    z_pos = initial_push
    max_Z_push = RAIL_LENGTH - Y_AXIS_MAX_LIMIT

    while True:
        is_first_window = (total_windows == 0)

        lines.append(f"; --- window {total_windows + 1} (Z={z_pos:.3f}) ---")
        total_rects += emit_window(lines, rect_columns, is_first_window)
        total_windows += 1

        # Clear X/Y so the next push has room to feed material in.
        emit_home(lines, "XY")

        if z_pos > max_Z_push:
            raise ValueError("the Z axis push would hit the metal frame and exceed expected number of cutting rows")

        # The push that follows this window. After window 1 it is one
        # SQUISH_ROOM longer, because window 1 was shifted up by the Y inset.
        next_push = window_push
        if total_windows == 1:
            next_push += SQUISH_ROOM

        # Is there enough stock left behind the feed point for another window?
        remaining = max_Z_push - LEAVE_UNCUT - z_pos
        if remaining < next_push + 1e-6:
            break

        z_pos += next_push
        lines.append(f"G1 Z{z_pos:.3f} F{Z_FEED_RATE} ; feed {next_push:.3f}mm more material in")

    lines.append("M2 ; end of program")

    stats = {
        "total_rects": total_rects,
        "total_windows": total_windows,
        "rects_per_row": len(rect_columns),
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
    print(f"{stats['total_rects']} rectangles ({stats['rects_per_row']} per row) across "
          f"{stats['total_windows']} windows ({stats['rows_per_window']} rows/window), "
          f"{RECT_WIDTH}x{RECT_HEIGHT}mm, block width {BLOCK_WIDTH}mm, "
          f"RECTS_PER_CLEAN={RECTS_PER_CLEAN}")

    if stats["single_window_only"]:
        print("SINGLE_WINDOW_ONLY = True: feeder logic skipped, generated exactly one window.")
    else:
        print(f"Rail: {RAIL_LENGTH}mm, material: {MATERIAL_LENGTH}mm, "
              f"unusable dead space at load: {stats['unusable_space']:.3f}mm")
        print(f"Initial feed push: {stats['initial_push']:.3f}mm, "
              f"per-window feed push: {stats['window_push']:.3f}mm")
        print(f"Leftover unused material at end of job: {stats['leftover']:.3f}mm")