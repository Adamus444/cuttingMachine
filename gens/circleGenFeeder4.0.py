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
  the untouched margin above/below the rows. Instead, feed exactly the
  center-to-center row pitch (row_pitch() - the same grid/hex spacing
  compute_rows() uses internally, CIRCLE_DIAMETER/PATTERN/Y_GAP driven)
  times the number of rows in a window, plus Y_GAP_WINDOW once per seam:
      window_push = rows_per_window * row_pitch(...) + Y_GAP_WINDOW
  This replaced an earlier version of this file that pushed by the
  window's own front-to-back cut span instead. That was needlessly
  wasteful: the LAST row of one window and the FIRST row of the next
  window are, in row-sequence terms, just consecutive rows - and (see
  ROW-COUNT PARITY below) consecutive rows always alternate hex offset,
  meaning they always nest exactly like any other two adjacent rows in
  a continuous hex sheet would. Pushing by the window's own span instead
  effectively demanded a full CIRCLE_DIAMETER of clearance at every seam
  (safe, but ignoring the nesting the hex pattern already gives you for
  free) - the row_pitch-based push reclaims that wasted material.

SQUISH_ROOM ON Y / CUT_OFF_MARGIN (right-edge overcut)
  SQUISH_ROOM still always insets circles from the left/right nominal
  edges on X (see the variable comment) - that hasn't changed. On Y,
  though, SQUISH_ROOM used to be subtracted from PLANE_HEIGHT on BOTH
  sides of every single window, as if each window were its own little
  isolated block with its own edges to protect. Physically that's wrong
  for every window except the very first: only the very front of window
  1 is a true material edge (fresh stock, needs the squish tolerance);
  every later window's "front" is just wherever the feeder happened to
  stop, on material that's continuous with the row before it. So
  SQUISH_ROOM on Y now ONLY offsets the very first row of the very
  first window (see the is_first_window argument on build_window()) -
  every other window's rows start flush at the mechanical Y limit
  (PLANE_HEIGHT), trusting the feeder's own precision plus Y_GAP/
  Y_GAP_WINDOW to keep rows from colliding at the seam.
  Losing the old per-window right-edge squish overcut also meant the
  straight waste cuts needed a new way to guarantee full separation at
  the edges. The left edge is handled for free: emit_row() always
  starts its forward sweep by traveling to the true machine X0 (not
  ORIGIN_X, not the row's own start) - since a G-code move only has a
  target, not a start, the very next cutting move then runs all the way
  from X0, so the left edge is always fully cleared with no squish math
  needed. The right edge can't use that trick (the sweep reverses
  direction there instead of continuing), so CUT_OFF_MARGIN explicitly
  extends the LAST straight cut of the forward sweep past the nominal
  right edge instead - if the wire ever leaves a sliver un-cut on the
  right, increase CUT_OFF_MARGIN.

SINGLE_WINDOW_ONLY (testing / one-off cuts)
  Sometimes you don't want to feed a whole block, you just want the
  G-code for exactly one window (e.g. to test a new PATTERN/GAP/
  DIAMETER setting on a scrap piece before committing a full block to
  it). Setting SINGLE_WINDOW_ONLY = True below skips ALL of the
  feeder/homing logic in this section entirely: no initial push, no
  Z moves, no re-homing between windows, no feed-in-the-loop - it just
  cuts the one window and ends the program. All of the RAIL_LENGTH /
  MATERIAL_LENGTH / Y_AXIS_MAX_LIMIT / SAFETY_DISTANCE machine
  variables below are simply unused in that mode.

WASTE-SEVERING DIAGONAL CUT (bottom arc only)
  Previously every circle's bottom half was a single, uninterrupted 180
  degree G3 arc (left point -> through the bottom -> right point). That
  left the wedge of waste material between two rows as one big connected
  chunk. Now that same 180 degree arc is still cut in full - the circle
  itself is untouched, still a perfect circle - but it's split into two
  G3 pieces with a straight detour spliced in between them:
    1. G3 for the first ARC_STOP_ANGLE_DEG of the 180 (default 135, i.e.
       stopping 45 degrees short of the circle's rightmost point).
    2. A straight G1 cut of fixed length WASTE_CUT_LENGTH, always at a
       fixed 45 degree angle toward the front-right (increasing X,
       decreasing Y) - no lookup of any other circle's position, just
       always the same direction/length.
    3. A non-cutting G1 travel straight back to the exact point the arc
       left off at (undoing step 2).
    4. A second G3, continuing from that same point through the
       remaining (180 - ARC_STOP_ANGLE_DEG) degrees to the circle's
       rightmost point - i.e. finishing the arc exactly as it would have
       run originally.
  This only touches the bottom/forward-sweep arc. The top/reverse-sweep
  arc and its SEVER_DISTANCE cut are unchanged.

ROW-COUNT PARITY ACROSS WINDOWS (hex pattern only)
  In "hex" PATTERN, every other row is horizontally offset by half a
  circle so it nests into the valley of the row before it (see
  compute_rows()). Within a single window that alternation always
  starts fresh at "not offset" for that window's first row. Naively
  that's harmless as long as each window has an EVEN number of rows
  (row 0 of window N+1 then lines up, in hex terms, exactly where it
  would if the whole job reset there anyway). If a window has an ODD
  number of rows (most simply: just 1 row per window, e.g. because
  PLANE_HEIGHT is small relative to CIRCLE_DIAMETER), every window's
  row 0 resetting to "not offset" would put every physical row along
  the whole stock on the SAME horizontal offset instead of alternating,
  breaking the hex nesting right at the window seam (and, before the
  PUSH BETWEEN WINDOWS fix above, silently forcing a full-diameter
  push there instead of the row-pitch one). To avoid that, the
  row-offset parity is carried across windows: build_window() takes a
  start_offset that continues counting from where the previous window
  left off (advanced by that window's row count each time), so a
  1-row-per-window job still alternates offset/not-offset window to
  window exactly like a single continuous hex sheet would. With an
  even row count per window this parity always returns to 0 between
  windows, so behaviour for the normal 2-row case above is unchanged.
  Because of this, the LAST row of any window and the FIRST row of the
  next ALWAYS end up on alternating offset, no matter rows_per_window's
  parity - which is exactly why the row_pitch-based push above is
  always safe to use, not just for odd row counts.

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

CUT_OFF_MARGIN = 10.0       # mm, extends the final right-edge straight cut.
                             # Increase if a sliver remains uncut.

ARC_STOP_ANGLE_DEG = 135.0  # degrees, stop the bottom 180° arc this far in,
                             # insert the waste-severing detour, then finish it.
                             # 135° = 45° before the rightmost point; circle
                             # remains a complete 180° arc.

WASTE_CUT_LENGTH = 20.0     # mm, straight waste-severing detour length.
                             # Fixed 45° toward front-right; ignores other circles.

X_GAP = 0.0                 # mm, extra straight clearance between main circles
                             # in the same row. Does not affect margin-filler circles.

Y_GAP = 1.0                 # mm, extra row-to-row pitch added to normal
                             # grid/hex spacing. Applies to all rows and seams.

Y_GAP_WINDOW = 0.0          # mm, extra clearance added once at each window seam.
                             # Used for additional feeder repeatability tolerance;
                             # separate from the normal Y_GAP on every row.
PATTERN = "hex"             # "grid" or "hex" - layout used for the main circles

DIAMETER_OPTIONS = [70, 50]
# List of acceptable diameters to check against when a row-end margin has
# leftover space. The script picks the LARGEST one from this list that
# still fits.

FEED_RATE = 170             # mm/min, speed while cutting (X/Y)
TRAVEL_RATE = 170            # mm/min, speed while travelling (X/Y, non-productive)

ORIGIN_X = 10.0              # mm, X offset of the window's bottom-left corner
ORIGIN_Y = 100.0              # mm, Y offset of the window's bottom-left corner

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

MATERIAL_LENGTH = 2000.0
# mm, length of the stock block along the shared Y/Z rail.

Z_FEED_RATE = 150
# mm/min, speed for the feeder (Z axis) pushing material in.

SAFETY_BURN_OFF_X_DISTANCE = 1100.0 
# mm, machine X coord, go there when 
# trying to burn off the coating on the wire
SAFETY_BURN_OFF_Y_DISTANCE = 40.0
# mm, relative -Y, the machine moves this much on Y
# when trying to burn off coating, atop moving the X axis 
CUTTING_TEMP = 25
# %, adjust the temp knob to this when cutting
BURN_OFF_TEMP = 45
# %, adjust the temp knob to this when trying burn the coating off
TEMP_SET_TIME = 10
# seconds, how long to dwell the controller waiting 
# for the temperature to actually, physically get to the desired value
BURN_OFF_TIME = 20
# seconds, how long to dwell the contrller waiting 
# for the coating to physically burn off

LEFT_CLEAN_REPEATS = 3
RIGHT_CLEAN_REPEATS = 3 

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
    windows). See the ROW-COUNT PARITY note in the module docstring for
    why the SAME pitch is correct both within a window and across a
    window seam (consecutive rows always alternate hex offset either way).
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
    plane_height - the raw mechanical Y-cutting window. Unlike X (see
    effective_width in build_window()), this is NOT pre-shrunk by
    SQUISH_ROOM on both sides any more; see the SQUISH_ROOM ON Y note in
    the module docstring.

    y_gap adds extra clearance to the normal grid/hex row pitch (Y_GAP),
    via row_pitch() above.

    start_offset carries the hex offset/not-offset alternation IN from a
    previous window (see the ROW-COUNT PARITY note in the module
    docstring): row i's is_offset is based on (i + start_offset) instead
    of i alone, so a caller stitching multiple windows together end-to-end
    can keep the alternation continuous across the seam even when a
    window has an odd number of rows. start_offset is ignored for
    PATTERN == "grid" since grid rows are never offset.

    y_start is the vertical offset already consumed before row 0's own
    radius is added - this is where SQUISH_ROOM gets applied, and ONLY
    for the very first window of the whole job (see build_window()'s
    is_first_window and the SQUISH_ROOM ON Y note); every other window
    calls this with y_start=0.0.
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

    x_gap reserves extra clearance BETWEEN consecutive main circles (see
    the X_GAP variable comment above) - it does not change how the
    row-end margins/filler circles are sized or placed, only how many
    main circles fit and how far apart their centers land.
    """
    radius = main_diameter / 2
    left_margin = radius if is_offset else 0.0

    available = plane_width - left_margin
    # Each additional main circle after the first also costs one x_gap of
    # space, so n circles + (n-1) gaps must fit in `available`. Solving
    # n*main_diameter + (n-1)*x_gap <= available for n gives the formula
    # below (the "+x_gap" on both sides cancels the -1 gap of the first
    # circle so a plain floor-division still works).
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
    Take row segments planned on the shrunk "effective" width
    (0 .. plane_width - 2*squish_room) and shift them into real window X
    coordinates by squish_room, so every circle stays inset from the
    real left/right edges.

    This used to ALSO stretch the outer straight segments past the
    nominal edges (an extra squish_room of overcut on each side) to
    guarantee full separation. That's been removed - it's handled
    differently now (and better, since it no longer depends on
    SQUISH_ROOM specifically): emit_row() always starts its forward
    sweep by traveling to the true machine X0 first, which naturally
    and fully clears the left edge regardless of squish_room, and
    CUT_OFF_MARGIN explicitly extends the last straight cut past the
    nominal right edge. See the SQUISH_ROOM ON Y / CUT_OFF_MARGIN note
    in the module docstring. Keeping the old overcut here as well would
    just double it up.
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


def emit_row(lines, row_y, segments):
    """
    Append the G-code for one full row sweep (there and back).
 
    Left edge: the forward sweep always starts its travel move at the
    true machine X0 (not ORIGIN_X, not wherever this row's own left
    segment happens to start). A G-code move only specifies a target,
    not a start, so the very next cutting move - for the row's first
    segment - ends up running all the way from X0 to that segment's own
    end. That fully, safely clears the left edge every time with no
    squish-room-based overcut math needed at all.
 
    Right edge: the same trick doesn't work there (the sweep reverses
    direction at the end instead of continuing on), so the LAST straight
    cut of the forward sweep is explicitly extended by CUT_OFF_MARGIN
    past its nominal end instead, to guarantee full separation.
 
    See the SQUISH_ROOM ON Y / CUT_OFF_MARGIN note in the module
    docstring for the full reasoning behind this approach.
 
    Every circle's bottom arc gets a straight waste-severing detour
    spliced into the middle of its 180 degree sweep - see the
    WASTE-SEVERING DIAGONAL CUT note in the module docstring. The circle
    itself still ends up a full, perfect 180 degrees; the detour cuts
    into the waste and comes straight back before resuming the arc.
 
    Wire cleaning, once per row, on both ends of the sweep:
    - Right side (after the last straight cut reaches the right edge):
      the wire travels out to a clear spot (SAFETY_BURN_OFF_X_DISTANCE/
      SAFETY_BURN_OFF_Y_DISTANCE), heats to BURN_OFF_TEMP for
      BURN_OFF_TIME to burn the coating off, cools back down, then
      mechanically rubs itself clean RIGHT_CLEAN_REPEATS times back and
      forth along the straight cut that was just made to reach the right
      edge (already-cut kerf, no new material removed), then reheats to
      CUTTING_TEMP before the reverse sweep starts.
    - Left side (after the reverse sweep finishes, row fully cut): no
      travel out and no reheating needed - the wire instead rubs itself
      clean LEFT_CLEAN_REPEATS times back and forth along the exact path
      it used to cut the upper half of the last circle in this row,
      since that's already-cut kerf too.
    """
    abs_y = ORIGIN_Y + row_y
 
    # make sure to not go into -Y
    safety_y = abs_y - SAFETY_BURN_OFF_Y_DISTANCE
    if safety_y <= 0:
        raise ValueError("SAFETY_BURN_OFF_Y_DISTANCE causes the machine to go into negative Y, that would hit the frame")
    
 
    # Travel to the left edge, X0 - see docstring above for why this is
    # the true machine X0 and not ORIGIN_X or the row's own start.
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; travel to left edge, X0")
 
    # Forward sweep: cut every segment, left to right
    segments_max_index = len(segments) - 1
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
 
                # move far clear of material to burn off the coating on the wire
                lines.append(f"G1 X{(SAFETY_BURN_OFF_X_DISTANCE):.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
                             f"; move to burn off coating")
                lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
                lines.append(f"M101 P{TEMP_SET_TIME} R0 ; cool down the wire")
 
                # Come back and mechanically clean the cool wire by rubbing
                # it RIGHT_CLEAN_REPEATS times back and forth along the
                # straight cut that was just made to reach the right edge -
                # that's already-cut kerf, so this doesn't remove any new
                # material, just scrapes the wire clean on it.
                lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; come back from burn-off spot")
                for _ in range(RIGHT_CLEAN_REPEATS):
                    lines.append(f"G1 X{seg_left:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                                 f"; rub clean along existing right-edge cut")
                    lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                                 f"; rub clean along existing right-edge cut")
 
                # reheat back to cutting temp before the reverse sweep resumes
                lines.append(f"G1 X{(SAFETY_BURN_OFF_X_DISTANCE):.3f} Y{safety_y:.3f} F{TRAVEL_RATE} "
                            f"; move to heat up")
                lines.append(f"M101 P{TEMP_SET_TIME} R{CUTTING_TEMP} ; reheat wire to cutting temp")
                lines.append(f"G1 X{x_end:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; come back from cleaning")
        else:
            _, x_start, x_end, d = seg
            r = d / 2
            cx = x_start + r  # circle center, plane-local (no ORIGIN offset)
 
            # Bottom arc, part 1: the first ARC_STOP_ANGLE_DEG of the
            # planned 180 degree sweep, left point -> stop point. I/J are
            # relative to the arc's start point (x_start, row_y), still
            # pointing at the untouched circle center.
            stop_angle_rad = math.radians(180.0 + ARC_STOP_ANGLE_DEG)
            stop_x = cx + r * math.cos(stop_angle_rad)
            stop_y = row_y + r * math.sin(stop_angle_rad)
            lines.append(
                f"G3 X{ORIGIN_X + stop_x:.3f} Y{ORIGIN_Y + stop_y:.3f} I{r:.3f} J0.000 "
                f"F{FEED_RATE} ; cut {ARC_STOP_ANGLE_DEG:g} of 180 deg of lower half, d={d:g}"
            )
 
            # Waste-severing detour: straight cut of fixed WASTE_CUT_LENGTH
            # at a fixed 45 degree angle toward the front-right (+X, -Y) -
            # not aimed at any other circle - then travel straight back
            # (non-cutting) to the exact point the arc left off at.
            diag_rad = math.radians(-45.0)
            diag_x = stop_x + WASTE_CUT_LENGTH * math.cos(diag_rad)
            diag_y = stop_y + WASTE_CUT_LENGTH * math.sin(diag_rad)
            lines.append(
                f"G1 X{ORIGIN_X + diag_x:.3f} Y{ORIGIN_Y + diag_y:.3f} F{FEED_RATE} "
                f"; cut waste-severing detour, fixed {WASTE_CUT_LENGTH:g}mm at 45 deg"
            )
            lines.append(
                f"G1 X{ORIGIN_X + stop_x:.3f} Y{ORIGIN_Y + stop_y:.3f} F{TRAVEL_RATE} "
                f"; return from detour to resume the arc"
            )
 
            # Bottom arc, part 2: finish the remaining
            # (180 - ARC_STOP_ANGLE_DEG) degrees, stop point -> right
            # point. I/J are relative to THIS arc's start point (the stop
            # point), still pointing at the same untouched circle center,
            # so together with part 1 this still cuts a full, perfect
            # 180 degree bottom half - the detour is spliced in, not
            # subtracted.
            lines.append(
                f"G3 X{ORIGIN_X + x_end:.3f} Y{abs_y:.3f} "
                f"I{cx - stop_x:.3f} J{row_y - stop_y:.3f} F{FEED_RATE} "
                f"; finish remaining {180.0 - ARC_STOP_ANGLE_DEG:g} of 180 deg of lower half"
            )
 
    # Reverse sweep: travel back over straights, cut upper half of every circle
    last_upper_arc = None  # (x_start, x_end, r) of the last circle whose
                            # upper half gets cut in this row - used below
                            # for the left-side rub-clean, since that's an
                            # already-cut kerf the wire can safely retrace.
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
 
            last_upper_arc = (x_start, x_end, r)
 
    # Explicit normalize move back to X0 (also doubles as the transition
    # move before the next row / the next window's return-home).
    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge (X0)")

    # Burn off coating, cool down
    lines.append(f"G1 X{0:.3f} Y{abs_y - safety_y:.3f} F{TRAVEL_RATE} ; heating up, move to a safe spot")

    lines.append(f"M101 P{BURN_OFF_TIME} R{BURN_OFF_TEMP} ; heat up, burn off coating")
    lines.append(f"M101 P{TEMP_SET_TIME} R0 ; cool down the wire")

    lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} ; move to left edge (X0)")

    # additional logic for clearing the wire
    x_start, x_end, r = last_upper_arc
    for _ in range(LEFT_CLEAN_REPEATS):
        lines.append(f"G1 X{x_start:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                    f"; rub clean along existing left-edge cut")
        lines.append(f"G1 X{0:.3f} Y{abs_y:.3f} F{TRAVEL_RATE} "
                    f"; rub clean along existing left-edge cut")

    # Add logic for returning along the upper half circle cuts, stopping at 'a' degrees, and then moving straigth to the next circle



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


def build_window(plane_width, plane_height, squish_room, circle_diameter, pattern,
                  diameter_options, x_gap=0.0, y_gap=0.0, start_offset=0, is_first_window=False):
    """
    Build the single repeating "window" of rows/segments that gets cut
    fresh every time new material is fed in. Returns a list of
    (row_y, segments) - row_y is relative to ORIGIN_Y, exactly what
    emit_row() expects.

    x_gap/y_gap are the extra circle-to-circle / row-to-row clearances
    (X_GAP/Y_GAP). start_offset carries the hex row-offset parity in from
    a previous window - see the ROW-COUNT PARITY note in the module
    docstring and compute_rows().

    is_first_window controls the SQUISH_ROOM-ON-Y behaviour (see the
    SQUISH_ROOM ON Y note in the module docstring): True bumps the very
    first row's starting position by squish_room, protecting the true
    leading edge of the material; every other window passes False and
    gets no Y inset at all. X is unaffected by this and always gets the
    squish_room inset via effective_width below, same as always.
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
    # Build the first window (start_offset=0, is_first_window=True - this
    # is the one window that gets the SQUISH_ROOM-ON-Y leading-edge inset,
    # see the SQUISH_ROOM ON Y note in the module docstring) to validate
    # the settings and, in SINGLE_WINDOW_ONLY mode, to have something to cut.
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
    # Y_GAP_WINDOW once per seam. This is constant across the whole job -
    # see the PUSH BETWEEN WINDOWS note in the module docstring for why a
    # single row_pitch()-based push is always correct here, regardless of
    # rows_per_window's parity or which window we're on.
    window_push = rows_per_window * row_pitch(CIRCLE_DIAMETER, PATTERN, Y_GAP) + Y_GAP_WINDOW

    lines = []
    lines.append("; Circle-packed cutting pattern with margin-filling + feeder logic")
    lines.append(f"; 2D hot-wire cutting, X/Y only - {PATTERN} layout, row-sweep order")
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

        for row_y, segments in first_window:
            emit_row(lines, row_y, segments)
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

    # Home everything at the very start of the job.
    lines.append("$H")

    # Initial push: clear the dead rail gap and park the material's
    # leading edge SAFETY_DISTANCE from the wire.
    lines.append(
        f"G1 Z{initial_push:.3f} F{Z_FEED_RATE} ; feed material in, ledge parked "
        f"{SAFETY_DISTANCE:.3f}mm from the wire"
    )

    z_pos = initial_push
    offset_parity = 0  # hex row-offset alternation, carried across windows - see
                        # the ROW-COUNT PARITY note in the module docstring

    while True:
        # Rebuild the window for THIS pass using the current offset parity
        # (is_first_window=False for every window past the very first one -
        # see the SQUISH_ROOM ON Y note). For an even rows_per_window this
        # always comes back to the same X layout as first_window; for an
        # odd rows_per_window (e.g. a single-row window) it alternates so
        # the hex pattern stays continuous across the window seam instead
        # of resetting.
        is_first_window = (total_windows == 0)
        window = build_window(
            PLANE_WIDTH, PLANE_HEIGHT, SQUISH_ROOM, CIRCLE_DIAMETER, PATTERN,
            DIAMETER_OPTIONS, X_GAP, Y_GAP, start_offset=offset_parity, is_first_window=is_first_window
        )

        lines.append(f"; --- window {total_windows + 1} (Z={z_pos:.3f}, "
                     f"row-offset parity={offset_parity}) ---")

        for row_y, segments in window:
            emit_row(lines, row_y, segments)
            total_circles += sum(1 for seg in segments if seg[0] == "circle")
        total_windows += 1
        offset_parity = (offset_parity + len(window)) % 2

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
          f"Y_GAP_WINDOW={Y_GAP_WINDOW}mm")
    print(f"Diameter options checked for margins: {DIAMETER_OPTIONS}")

    if stats["single_window_only"]:
        print("SINGLE_WINDOW_ONLY = True: feeder logic skipped, generated exactly one window.")
    else:
        print(f"Rail: {RAIL_LENGTH}mm, material: {MATERIAL_LENGTH}mm, "
              f"unusable dead space at load: {stats['unusable_space']:.3f}mm")
        print(f"Initial feed push: {stats['initial_push']:.3f}mm, "
              f"per-window feed push: {stats['window_push']:.3f}mm (constant every seam)")
        print(f"Leftover unused material at end of job: {stats['leftover']:.3f}mm")