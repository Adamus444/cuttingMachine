"""
Derived from circleGenFeeder4_3.py

Generate a G-code file for a hot-wire (2D, X/Y only) cutter that cuts
circles out of a rectangular window of material, using a grid or hex
layout of a main circle size, filling row-end margins with a smaller
filler circle where possible (see circleGenSquish.py for the full
explanation of DIAMETER_OPTIONS / SQUISH_ROOM row-segment logic - that
part is copied over unchanged from circleGenFeeder4_3.py, as is all of
the feeder/homing/window-push machinery below - see that file's
docstring for FEED-IN-BIT-BY-BIT, CUTTING WINDOW, PUSH BETWEEN WINDOWS,
SQUISH_ROOM ON Y / CUT_OFF_MARGIN, ROW-COUNT PARITY and HOMING; none of
that changed here).

WHAT'S NEW HERE (the fundamental change from circleGenFeeder4_3.py):

  circleGenFeeder4_3.py cut an entire row's worth of circles' LOWER
  halves first (the whole forward sweep), then came back and cut the
  entire row's worth of UPPER halves (the whole reverse sweep), with a
  single burn-off stop at each end of that one long sweep. In practice
  that leaves a whole row of circles sitting half-cut/half-connected to
  the waste for the whole sweep, and that's a physical problem, not
  just a cosmetic one: nothing pops free until the entire row is done,
  so anything that shifts, sags, or catches partway through takes the
  automation down with it.

  This file replaces that with SERIES-BASED CUTTING: instead of one big
  forward sweep + one big reverse sweep per row, the row's circles are
  chopped into small series of SERIES_SIZE circles each (1, 2, 3, ... -
  see the SERIES_SIZE variable below), and EVERY series is carried all
  the way from "still solid material" to "fully cut, popped out, and
  physically out of the way" before the wire ever moves on to the next
  series. So a row with 8 circles and SERIES_SIZE=2 runs the sequence
  below FOUR times, not once.

SERIES-BASED CUTTING (per series, i.e. per small batch of circles)
  For each series (see split_into_series() / emit_series()):
    1. Forward pass: cut the LOWER half of every circle in the series
       (with the waste-severing detour spliced in - see ARC OVERLAP
       below for what changed there), plus any straight margin/gap cuts
       that fall inside the series' span, left to right. This is
       exactly circleGenFeeder4_3.py's forward sweep, just scoped down
       to a handful of circles instead of the whole row.
    2. Drop straight down in Y, SAFETY_BURN_OFF_Y_DISTANCE below the
       row, from wherever the forward pass just finished (batch_end_x)
       - and run the coating burn-off heat/cool cycle (now factored out
       into burn_off_coating(), see DUPLICATED BURN-OFF HEAT/COOL CYCLE
       below), then reheat to CUTTING_TEMP and come back, ready to cut
       upper halves. Unlike circleGenFeeder4_3.py, this move no longer
       travels all the way out to the fixed SAFETY_BURN_OFF_X_DISTANCE
       parking spot first - it drops down at F{FEED_RATE}, in place, at
       whatever X the forward pass ended on. SAFETY_BURN_OFF_X_DISTANCE
       is now only used as the (optional) reheat spot for the
       RIGHT_CLEAN_REPEATS rub-clean detour, not for every series.
    3. Reverse pass: cut the UPPER half of every circle in the series,
       right to left, with the SEVER_DISTANCE severing cut after each
       one - exactly as circleGenFeeder4_3.py's reverse sweep did,
       again just scoped to this series.
    4. Drop straight down in Y again, SAFETY_BURN_OFF_Y_DISTANCE below
       the row - but this time from the LEFTMOST CIRCLE's own left
       edge, not wherever the reverse pass happened to stop and not
       X0. The wire is still hot at this point, so this move cuts
       through whatever it passes over; the leftmost circle's edge is
       guaranteed to already be an open, fully-cut hole (both halves
       done), while the reverse pass's own stopping point can still be
       solid material - most visibly on an offset (hex) row whose left
       margin is wider than every DIAMETER_OPTIONS filler, so it's cut
       as one plain straight instead of a filler circle: the reverse
       pass used to stop at the start of that straight, which is still
       solid above/below the row's cutting line, not at the first
       circle's edge. To keep the wire from detouring out to that
       straight's start and back for no reason, the reverse pass now
       skips travelling to the batch's own leftmost segment at all when
       it's a straight (a cheap trick - see the i == 0 branch in the
       reverse-pass loop in emit_series()): that straight was already
       fully cut going forward, and it's harmlessly re-traversed once
       more during the pop-out pass below anyway, so skipping this one
       redundant visit costs nothing. The wire is then already sitting
       at the leftmost circle's own edge once the reverse pass ends, so
       this burn-off drop is a clean single-axis move, not a detour.
       Run the same burn-off heat/cool cycle, but this time do NOT
       reheat - the wire is left cold, exactly like the end-of-row
       cleaning in circleGenFeeder4_3.py.
    5. Pop-out pass (if GENERATE_POP_OUT): sweep forward across the
       series one more time, retracing the first POP_OUT_STOP_ANGLE
       degrees of each circle's upper arc and then jumping straight to
       its right point, physically nudging each now fully-separated
       circle out of the way - same mechanism as
       circleGenFeeder4_3.py's row-level pop-out pass, scoped to this
       series. Each circle's retrace starts with an explicit "move to
       pop out" travel to that circle's own left point (x_start) before
       the retrace arc, instead of relying on the wire already
       happening to be sitting there from whatever the previous
       segment's move left behind - except when that circle is the
       batch's own leftmost segment and the segment right before it is
       the batch's leftmost straight, in which case the straight's own
       travel is skipped (same cheap trick as step 4) since it would
       land on the exact same point the circle's own "move to pop out"
       line is about to move to anyway.
    6. Move away from the foam - to the middle of the last circle just
       cut in this series (an open hole by now, clear of material) -
       and heat back up to CUTTING_TEMP, ready for the next series.
    7. Travel (cold-free, already hot) back to the right-hand edge of
       this series, which is exactly where the NEXT series' forward
       pass needs to start from. If this was the LAST series in the
       row, the row then does its own final "move to X0" transition
       (same as circleGenFeeder4_3.py did) to get ready for the next
       row / next window's home.

  Straight margin/gap segments that fall inside a series' span are cut
  once (forward pass only) and simply travelled back over (non-cutting)
  on the reverse pass, exactly as circleGenFeeder4_3.py always did for
  every straight segment - grouping circles into series doesn't change
  how straights are handled, only how many circles worth of arcs sit
  between one burn-off/pop-out cycle and the next.

  CUT_OFF_MARGIN (the right-edge overcut extension) only ever applies
  to the very last straight segment of the very last series of a row -
  i.e. the true right edge of the row - never at a series boundary in
  the middle of a row. Series boundaries in the middle of a row are not
  material edges, just where this pass happens to pause for a burn-off/
  pop-out cycle, so nothing needs to be overcut there.

  This supersedes circleGenFeeder4_3.py's FIRST CIRCLE OF EVERY ROW
  special case (cutting the very first circle of a row fully, both
  halves, before the rest of the row) - that was a one-off exception to
  cope with exactly the same physical problem series-based cutting now
  solves for EVERY circle, not just the first one. There is no separate
  first-circle special case here any more; SERIES_SIZE=1 reproduces
  that same "every circle fully cut and popped before moving on"
  behaviour for the whole row, and SERIES_SIZE>1 relaxes it to a small
  batch at a time instead of strictly one at a time.

ARC OVERLAP (waste-severing detour return point)
  circleGenFeeder4_3.py's waste-severing detour (still here, unchanged
  in where it splits and how long/which angle it cuts - see
  ARC_STOP_ANGLE / ARC_STOP_ANGLE_FIRST_ROW / WASTE_CUT_LENGTH /
  WASTE_CUT_LENGTH_FIRST_ROW below) used to travel straight back
  (non-cutting) to the EXACT point the arc left off at before resuming
  the remaining part of the 180 degree sweep. Resuming exactly there,
  though, risks leaving a tiny uncut witness nub right at that join if
  the travel-back isn't perfectly precise.

  Now the straight-line move back lands ARC_OVERLAP_ANGLE degrees
  EARLIER along the arc than the original stop point (i.e. back toward
  the circle's left point, into territory the first arc piece already
  cut) instead of exactly at it - and this move itself now CUTS
  (F{FEED_RATE}, not the old non-cutting F{TRAVEL_RATE}), so it's an
  active straight-line cut back across the detour before the arc even
  resumes. The arc is then resumed from the overlap point, all the way
  through to the circle's right point, in one G3 move. That move
  necessarily re-cuts that small ARC_OVERLAP_ANGLE-degree sliver of
  already-open kerf first (harmless - it's already cut, twice over now)
  before going on to cut the genuinely new remaining material out to
  the right point - guaranteeing a clean, fully-severed join with no
  nub, at the cost of a few extra degrees of arc travel.
  ARC_OVERLAP_ANGLE must be strictly less than whichever arc-stop-angle
  applies to the row (ARC_STOP_ANGLE or ARC_STOP_ANGLE_FIRST_ROW), or
  the "3 degrees back" point would fall before the arc even started.

Everything else - PLANE_WIDTH/PLANE_HEIGHT/SQUISH_ROOM, the grid/hex
row & margin-filler layout, the feeder/push-between-windows math, the
SQUISH_ROOM-ON-Y first-window special case, row-offset parity across
windows, homing, and SINGLE_WINDOW_ONLY - is inherited from
circleGenFeeder4_3.py unchanged. See that file's docstring for the full
explanation of any of those if needed.

Adjust the VARIABLES section below.

Run:
    python circleGenFeederSeries.py
Output:
    circles.gcode
"""

import math

# ---------------- CUTTING VARIABLES ----------------
PLANE_WIDTH = 990.0        # mm, width of one cutting window (X)
PLANE_HEIGHT = 100.0        # mm, height of one cutting window (Y) - NOT the
                             # full stock length, just one repeating window
SQUISH_ROOM = 2.0           # mm, tolerance for material movement.
                             # X: always inset from left/right nominal edges.
                             # Y: only applied to the first row of the first window
                             # (the true leading edge of fresh stock).

CIRCLE_DIAMETER = 70.0      # mm, main circle size for grid/hex layout.

SEVER_DISTANCE = 10.0       # mm, extra cut to fully sever circles from waste.

CUT_OFF_MARGIN = 40.0       # mm, extends the final right-edge straight cut of
                             # the LAST series in a row (the true right edge
                             # of the row). Increase if a sliver remains uncut.

SERIES_SIZE = 4              # how many circles get cut lower-half -> burn off
                             # -> upper-half -> burn off -> pop-out, as one
                             # uninterrupted batch, before the wire moves on
                             # to the next batch. 1, 2, 3... - see the
                             # SERIES-BASED CUTTING note in the module
                             # docstring. Smaller = slower but frees material
                             # more often; larger = faster but leaves more
                             # circles half-cut at once.

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
WASTE_CUT_LENGTH = 4.0     # mm, straight waste-severing detour length,
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
GENERATE_POP_OUT = True     # series-based cutting relies on circles actually
                             # being nudged out of the way between series, so
                             # this normally wants to stay True here - see the
                             # SERIES-BASED CUTTING note in the module
                             # docstring. Set False to skip it anyway (e.g.
                             # picking pieces out by hand instead).

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

MATERIAL_LENGTH = 1130.0
# mm, length of the stock block along the shared Y/Z rail.

LEAVE_UNCUT = 300
# mm, dont try to push further if there is only this much material left

Z_FEED_RATE = 150
# mm/min, speed for the feeder (Z axis) pushing material in.

SAFETY_BURN_OFF_X_DISTANCE = 1040.0
# mm, machine X coord. Every series' own burn-off drop (both the
# post-forward-pass one and the post-reverse-pass one) now happens in
# place - straight down at whatever X the wire already ended up at
# (batch_end_x / the leftmost circle's edge, see emit_series()) - not
# out here any more. This X is now ONLY used as the reheat spot for the
# optional RIGHT_CLEAN_REPEATS rub-clean detour after the forward pass.
SAFETY_BURN_OFF_Y_DISTANCE = 60.0
# mm, relative -Y, the machine moves this much on Y
# when trying to burn off coating, atop moving the X axis
CUTTING_TEMP = 10
# %, adjust the temp knob to this when cutting
BURN_OFF_TEMP = 25
# %, adjust the temp knob to this when trying burn the coating off
TEMP_SET_TIME = 3
# seconds, how long to dwell the controller waiting
# for the temperature to actually, physically get to the desired value
BURN_OFF_TIME = 10
# seconds, how long to dwell the contrller waiting
# for the coating to physically burn off
COOL_DOWN_TIME = 8

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


def split_into_series(segments, series_size):
    """
    Group one row's segments (already placed in real window X
    coordinates) into consecutive SERIES-BASED CUTTING batches of up to
    series_size circles each - see the module docstring.

    Every batch is a contiguous slice of `segments`: the first batch
    starts at segment 0, each batch ends right after its series_size-th
    circle, and the LAST batch additionally soaks up every trailing
    segment after its last circle (e.g. the row's trailing margin
    straight) so nothing gets left over as its own circle-less batch.

    Returns a list of segment-lists. Empty if the row has no circles at
    all (row_has_circles() should already have filtered those rows out
    upstream, same as circleGenFeeder4_3.py did).
    """
    circle_indices = [i for i, seg in enumerate(segments) if seg[0] == "circle"]
    if not circle_indices:
        return []

    chunks = [circle_indices[i:i + series_size] for i in range(0, len(circle_indices), series_size)]

    batches = []
    prev_end = 0
    last_chunk_index = len(chunks) - 1
    for chunk_index, chunk in enumerate(chunks):
        last_circle_idx = chunk[-1]
        end = len(segments) if chunk_index == last_chunk_index else last_circle_idx + 1
        batches.append(segments[prev_end:end])
        prev_end = end

    return batches


def cut_lower_half(lines, row_y, x_start, x_end, d, row_arc_stop_angle, waste_cut_length):
    """
    Cut one circle's bottom 180 degree arc, split by the waste-severing
    detour exactly as circleGenFeeder4_3.py did - but the straight-line
    move back from the detour is now aimed at (and cuts, at FEED_RATE -
    it's no longer a non-cutting travel) a point ARC_OVERLAP_ANGLE
    degrees EARLIER along the arc than the original stop point, instead
    of exactly at it, and the arc is then resumed from there. See the
    ARC OVERLAP note in the module docstring for why.

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
    # front-right (+X, -Y) quadrant, then a straight cut back - but to
    # the OVERLAP point below, not the exact stop point.
    detour_angle_below_horizontal = 180.0 - row_arc_stop_angle
    diag_rad = math.radians(-detour_angle_below_horizontal)
    diag_x = stop_x + waste_cut_length * math.cos(diag_rad)
    diag_y = stop_y + waste_cut_length * math.sin(diag_rad)
    lines.append(
        f"G1 X{ORIGIN_X + diag_x:.3f} Y{ORIGIN_Y + diag_y:.3f} F{FEED_RATE} "
        f"; cut waste-severing detour, fixed {waste_cut_length:g}mm at "
        f"{detour_angle_below_horizontal:g} deg below horizontal"
    )

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


def cut_upper_half(lines, abs_y, x_start, d):
    """
    Cut one circle's upper 180 degree arc plus the SEVER_DISTANCE
    severing cut, exactly as circleGenFeeder4_3.py did. Assumes the wire
    is already sitting at this circle's own right point (x_end, abs_y)
    when called.
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
    lines.append(
        f"G1 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
        f"; going back from the severing cut"
    )

def burn_off_coating(lines):
    """
    The DUPLICATED BURN-OFF HEAT/COOL CYCLE (see module docstring): cool,
    heat to BURN_OFF_TEMP, cool, heat again, cool - run twice back to
    back with nothing else spliced in between, since the wire is meant
    to sit still through the whole thing. Factored out here since
    emit_series() now calls this same five-line cycle at two different
    points (post-forward and post-reverse) instead of repeating it
    inline both times.
    """
    lines.append(f"M101 P{COOL_DOWN_TIME} R0 ; cool down the wire")
    lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
    lines.append(f"M101 P{COOL_DOWN_TIME} R0 ; cool down the wire")


def emit_series(lines, row_y, abs_y, safety_y, batch, is_first_row, is_last_batch):
    """
    Cut ONE series - a batch of up to SERIES_SIZE circles, plus whatever
    straight margin/gap segments fall inside that span - all the way
    from solid material to fully cut, popped out, and clear of the
    material, before returning. See the SERIES-BASED CUTTING note in the
    module docstring for the full step-by-step description; this
    function is exactly that sequence.

    is_first_row selects ARC_STOP_ANGLE_FIRST_ROW/WASTE_CUT_LENGTH_FIRST_ROW
    vs ARC_STOP_ANGLE/WASTE_CUT_LENGTH, same meaning as in
    circleGenFeeder4_3.py.

    is_last_batch marks the last series of the row: only then does the
    final straight segment (if any) get CUT_OFF_MARGIN's right-edge
    overcut - series boundaries in the middle of a row are not material
    edges, so nothing gets overcut there.

    Assumes the wire is already at (this batch's own left edge, abs_y)
    and at CUTTING_TEMP when called - true for the first batch of a row
    (emit_row() puts it there before calling this), and true for every
    later batch too (the previous call to this function leaves the wire
    exactly there, reheated, before returning - see step 7/8 below).

    Returns batch_end_x: the absolute machine X coordinate of this
    batch's right-hand edge (CUT_OFF_MARGIN already added in if
    is_last_batch), which is also where the NEXT batch's forward pass
    needs to start from.
    """
    waste_cut_length = WASTE_CUT_LENGTH_FIRST_ROW if is_first_row else WASTE_CUT_LENGTH
    row_arc_stop_angle = ARC_STOP_ANGLE_FIRST_ROW if is_first_row else ARC_STOP_ANGLE

    batch_max_index = len(batch) - 1

    # ---- 1. forward pass: cut lower halves + straights, left to right ----
    last_straight_seg_left = None  # start of the final straight cut, if the
                                    # batch ends on one - used for the
                                    # optional right-side rub-clean below
    batch_end_x = None
    for i, seg in enumerate(batch):
        if seg[0] == "straight":
            x_end = ORIGIN_X + seg[2]
            if i == batch_max_index and is_last_batch:
                x_end += CUT_OFF_MARGIN
            lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{FEED_RATE} ; cut straight (margin/gap)")
            batch_end_x = x_end
            if i == batch_max_index:
                last_straight_seg_left = ORIGIN_X + seg[1]
        else:
            _, x_start, x_end, d = seg
            cut_lower_half(lines, row_y, x_start, x_end, d, row_arc_stop_angle, waste_cut_length)
            batch_end_x = ORIGIN_X + x_end

    # ---- 2. burn off coating (right-style: reheat afterwards) ----
    lines.append(
        f"G1 X{batch_end_x:.3f} Y{safety_y:.3f} F{FEED_RATE} "
        f"; move to burn off coating"
    )
    # Wire sits still through the whole cycle: heat, cool, heat, cool
    # again - see the DUPLICATED BURN-OFF HEAT/COOL CYCLE note in the
    # module docstring.
    burn_off_coating(lines)

    if RIGHT_CLEAN_REPEATS != 0 and last_straight_seg_left is not None:
        lines.append(f"G1 X{batch_end_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; come back from burn-off spot")
        for _ in range(RIGHT_CLEAN_REPEATS):
            lines.append(
                f"G1 X{last_straight_seg_left:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                f"; rub clean along existing right-edge cut"
            )
            lines.append(
                f"G1 X{batch_end_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                f"; rub clean along existing right-edge cut"
            )
        lines.append(
            f"G1 X{SAFETY_BURN_OFF_X_DISTANCE:.3f} Y{safety_y:.3f} F{TRAVEL_RATE} ; move to heat up"
        )

    lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
    lines.append(f"G1 X{batch_end_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; come back from burn-off/cleaning")

    # ---- 3. reverse pass: cut upper halves, right to left ----
    last_upper_arc = None  # (x_start, x_end, r) of the LEFTMOST circle in
                            # this batch - used below for both the burn-off
                            # safe-spot target and the left-side rub-clean
    batch_start_x = None   # X of the batch's own leftmost segment - kept
                            # only for reference/debugging, see below
    for i in range(batch_max_index, -1, -1):
        seg = batch[i]
        if seg[0] == "straight":
            x_start = ORIGIN_X + seg[1]
            batch_start_x = x_start
            if i == 0:
                # Cheap trick: this is the batch's own leftmost segment -
                # a straight (e.g. a hex-offset row's unfilled left
                # margin, or an X_GAP straight). Don't actually travel
                # here: burn-off below is heading straight to
                # last_upper_arc[0] (the leftmost CIRCLE's edge) anyway,
                # not to this straight's start, so parking here first
                # just adds a pointless detour into (and then back out
                # of) this corner before the real burn-off move. This
                # straight is still fully cut (forward pass already did
                # that) and still gets traversed once more, harmlessly,
                # during the pop-out pass below - skipping it here only
                # skips a redundant reverse-pass visit, not a cut.
                pass
            else:
                lines.append(f"G1 X{x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel back over margin/gap")
        else:
            _, x_start, x_end, d = seg
            cut_upper_half(lines, abs_y, x_start, d)
            last_upper_arc = (ORIGIN_X + x_start, ORIGIN_X + x_end, d / 2)
            batch_start_x = ORIGIN_X + x_start

    # ---- 4. burn off coating (left-style: no reheat, wire left cold) ----
    # The wire is still hot here (no cool-down yet), so this move is a real
    # cut wherever it passes through, not a free travel - the X target has
    # to be somewhere already guaranteed open. That's last_upper_arc[0],
    # the LEFTMOST CIRCLE's own left edge (already a fully-cut hole by this
    # point, both halves done) - NOT batch_start_x. batch_start_x can be
    # the start of an offset row's unfilled left-margin straight instead,
    # which is still solid material above/below the row's cutting line, so
    # dropping straight down onto safety_y there would cut straight
    # through the block instead of through an already-open hole. (This is
    # also exactly why the straight-segment skip above exists: with
    # nothing routing the wire out to that straight's start any more, the
    # wire is already sitting at the leftmost circle's own edge by the
    # time we get here, so this move is a clean, single-axis drop instead
    # of a diagonal detour back across the margin and into the circle.)
    leftmost_circle_x = last_upper_arc[0]
    lines.append(
        f"G1 X{leftmost_circle_x:.3f} Y{safety_y:.3f} F{FEED_RATE} ; move to a safe spot, burn off coating"
    )
    burn_off_coating(lines)

    # ---- 5. left-side mechanical rub-clean (already-cut kerf) ----
    x_start, x_end, r = last_upper_arc
    for _ in range(LEFT_CLEAN_REPEATS):
        lines.append(f"G1 X{x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; rub clean along existing left-edge cut")
        lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; rub clean along existing left-edge cut")

    # ---- 6. pop-out pass, this series only ----
    if GENERATE_POP_OUT:
        for i, seg in enumerate(batch):
            if seg[0] == "straight":
                x_end = ORIGIN_X + seg[2]
                if i == 0:
                    # Same cheap trick as the reverse pass above: this is
                    # the batch's own leftmost segment, a straight whose
                    # x_end is always exactly the next circle's own
                    # x_start - so the "move to pop out" line right below,
                    # for that circle, already lands on this same point.
                    # Emitting this line first just adds a redundant
                    # zero-distance line ahead of it.
                    pass
                else:
                    lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel over margin/gap")
            else:
                _, x_start, x_end, d = seg
                r = d / 2
                cx = x_start + r  # circle center, plane-local (no ORIGIN offset)

                pop_stop_angle_rad = math.radians(180.0 - POP_OUT_STOP_ANGLE)
                pop_stop_x = cx + r * math.cos(pop_stop_angle_rad)
                pop_stop_y = row_y + r * math.sin(pop_stop_angle_rad)

                # Explicit X here (this circle's own left point, x_start) -
                # NOT left implicit. Without an X, this line only sets Y and
                # silently keeps whatever X the wire happened to already be
                # at from the previous segment - which is usually this
                # circle's x_start anyway (the preceding straight/circle
                # ends exactly there), but that's a coincidence of ordering,
                # not something this line enforces. The retrace arc right
                # after it starts from (x_start, row_y) by construction (I/J
                # are relative to that start point), so if the wire's real X
                # was ever off from x_start for any reason, the arc below
                # would be cut from the wrong center - naming X explicitly
                # here removes that fragility.
                lines.append(
                    f"G1 X{ORIGIN_X + x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to pop out"
                )
                lines.append(
                    f"G2 X{ORIGIN_X + pop_stop_x:.3f} Y{ORIGIN_Y + pop_stop_y:.3f} I{r:.3f} J0.000 "
                    f"F{TRAVEL_RATE} ; retrace upper half, {POP_OUT_STOP_ANGLE:g} of 180 deg, d={d:g}"
                )
                lines.append(
                    f"G1 X{ORIGIN_X + x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                    f"; move straight to end of half circle, pop out piece"
                )

    # ---- 7. move away from the foam, to the middle of the last circle ----
    # cut in this series (an open hole by now), and heat back up for the
    # next series. Found regardless of GENERATE_POP_OUT, since the wire
    # needs somewhere clear of material to sit while it reheats either way.
    last_circle_cx = None
    for seg in reversed(batch):
        if seg[0] == "circle":
            _, x_start, x_end, d = seg
            last_circle_cx = x_start + d / 2
            break

    lines.append(
        f"G1 X{ORIGIN_X + last_circle_cx:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
        f"; move to middle of last cut circle, clear of foam"
    )
    lines.append(f"M101 R{CUTTING_TEMP} P{TEMP_SET_TIME} ; heat back up to cutting temp for the next series")

    # ---- 8. resume position: this batch's right edge, ready for the ----
    # next series (or the row-end transition, if this was the last one).
    lines.append(f"G1 X{batch_end_x:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; resume position for next series / row end")

    return batch_end_x


def emit_row(lines, row_y, segments, is_first_row=False):
    """
    Append the G-code for one full row, cut in SERIES_SIZE-circle series
    - see the SERIES-BASED CUTTING note in the module docstring.

    is_first_row selects which waste-severing detour length/arc-stop-angle
    is used for every circle in this row (WASTE_CUT_LENGTH_FIRST_ROW /
    ARC_STOP_ANGLE_FIRST_ROW when True, meant for only the very first row
    of the very first window; WASTE_CUT_LENGTH / ARC_STOP_ANGLE
    otherwise) - same meaning as in circleGenFeeder4_3.py, just passed
    through to each series instead of applying to one giant sweep.
    """
    abs_y = ORIGIN_Y + row_y

    # make sure to not go into -Y
    safety_y = abs_y - SAFETY_BURN_OFF_Y_DISTANCE
    if safety_y <= 0:
        raise ValueError("SAFETY_BURN_OFF_Y_DISTANCE causes the machine to go into negative Y, that would hit the frame")

    # Travel to the left edge, X0, and get the wire up to cutting temp -
    # the first series' forward pass starts from here.
    lines.append(f"M101 R{CUTTING_TEMP} P{TEMP_SET_TIME}")
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge, X0")

    batches = split_into_series(segments, SERIES_SIZE)
    for batch_index, batch in enumerate(batches):
        is_last_batch = (batch_index == len(batches) - 1)
        emit_series(lines, row_y, abs_y, safety_y, batch, is_first_row, is_last_batch)

    # Explicit normalize move back to X0 - transition move before the
    # next row / the next window's return-home, same role as in
    # circleGenFeeder4_3.py.
    #lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge (X0), row done")


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
    if not (0.0 <= ARC_OVERLAP_ANGLE < min(ARC_STOP_ANGLE, ARC_STOP_ANGLE_FIRST_ROW)):
        raise ValueError(
            "ARC_OVERLAP_ANGLE must be 0 or more, and strictly less than "
            "both ARC_STOP_ANGLE and ARC_STOP_ANGLE_FIRST_ROW - it steps "
            "back from whichever arc-stop-angle applies to the row, so it "
            "can't be big enough to step back past the start of the arc."
        )
    if not (isinstance(SERIES_SIZE, int) and SERIES_SIZE >= 1):
        raise ValueError("SERIES_SIZE must be a positive integer (1, 2, 3, ...).")

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
    lines.append("; Circle-packed cutting pattern with margin-filling + feeder logic + series-based cutting")
    lines.append(f"; 2D hot-wire cutting, X/Y only - {PATTERN} layout, series-of-{SERIES_SIZE} cutting order")
    lines.append(f"; window = {rows_per_window} row(s) per push, main diameter {CIRCLE_DIAMETER}mm, "
                 f"window {PLANE_WIDTH}x{PLANE_HEIGHT}mm, X_GAP={X_GAP}mm Y_GAP={Y_GAP}mm "
                 f"Y_GAP_WINDOW={Y_GAP_WINDOW}mm CUT_OFF_MARGIN={CUT_OFF_MARGIN}mm "
                 f"ARC_OVERLAP_ANGLE={ARC_OVERLAP_ANGLE}deg")
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
          f"Y_GAP_WINDOW={Y_GAP_WINDOW}mm, SERIES_SIZE={SERIES_SIZE}")
    print(f"Diameter options checked for margins: {DIAMETER_OPTIONS}")

    if stats["single_window_only"]:
        print("SINGLE_WINDOW_ONLY = True: feeder logic skipped, generated exactly one window.")
    else:
        print(f"Rail: {RAIL_LENGTH}mm, material: {MATERIAL_LENGTH}mm, "
              f"unusable dead space at load: {stats['unusable_space']:.3f}mm")
        print(f"Initial feed push: {stats['initial_push']:.3f}mm, "
              f"per-window feed push: {stats['window_push']:.3f}mm (constant every seam)")
        print(f"Leftover unused material at end of job: {stats['leftover']:.3f}mm")