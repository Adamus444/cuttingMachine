; Rectangle grid - zigzag forward sweep, straight reverse cut with knocks + feeder logic
; 2D hot-wire cutting, X/Y only - clean every 4 rectangles per sweep
; window = 1 row(s) per push, rectangle 200.0x120.0mm, 5 per row, block width 1010.0mm, SQUISH_ROOM=2.0mm CUT_OFF_MARGIN=40.0mm
G21 ; units = mm
G90 ; absolute positioning
; RAIL_LENGTH=2131.646mm MATERIAL_LENGTH=1525.0mm Y_AXIS_MAX_LIMIT=280.0mm -> unusable dead space at load = 326.646mm (informational only, not a cutting limit)
; initial feed push = 476.646mm, per-window feed push = 122.000mm (the first one is 2mm longer, for the first-window Y inset)
G1 Z476.646 F200 ; feed material in, ledge parked 130.000mm from the wire
; --- window 1 (Z=476.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y132.000 F600 ; travel to left edge, X0
G1 X1058.000 Y132.000 F170 ; first row of the job: cut the bottom line across the full width
G1 X1058.000 Y102.000 F600 ; travel back to left edge, X0
G1 X0.000 Y102.000 F600 ; travel back to left edge, X0
G1 X0.000 Y132.000 F600 ; travel back to left edge, X0
G1 X212.000 Y132.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y252.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y252.000 F170 ; rect 2: cut top edge
G1 X412.000 Y132.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y132.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y252.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y252.000 F170 ; rect 4: cut top edge
G1 X812.000 Y132.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y102.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y132.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y132.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y252.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y252.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y102.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y102.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y252.000 F600 ; come back from cleaning
G1 X1012.000 Y252.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y252.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y252.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y252.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y252.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y102.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y252.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y252.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y252.000 F170 ; top line: cut across the left margin
G1 X12.000 Y252.000 F600 ; back to rect 1's left wall
G1 X12.000 Y132.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y132.000 F600 ; move to left edge (X0)
G1 X0.000 Y102.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z600.646 F200 ; feed 124.000mm more material in
; --- window 2 (Z=600.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z722.646 F200 ; feed 122.000mm more material in
; --- window 3 (Z=722.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z844.646 F200 ; feed 122.000mm more material in
; --- window 4 (Z=844.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z966.646 F200 ; feed 122.000mm more material in
; --- window 5 (Z=966.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1088.646 F200 ; feed 122.000mm more material in
; --- window 6 (Z=1088.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1210.646 F200 ; feed 122.000mm more material in
; --- window 7 (Z=1210.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1332.646 F200 ; feed 122.000mm more material in
; --- window 8 (Z=1332.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1454.646 F200 ; feed 122.000mm more material in
; --- window 9 (Z=1454.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1576.646 F200 ; feed 122.000mm more material in
; --- window 10 (Z=1576.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1698.646 F200 ; feed 122.000mm more material in
; --- window 11 (Z=1698.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1820.646 F200 ; feed 122.000mm more material in
; --- window 12 (Z=1820.646) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y130.000 F600 ; travel to left edge, X0
G1 X212.000 Y130.000 F170 ; rect 1: bottom edge (line already cut?)
G1 X212.000 Y250.000 F170 ; rect 1: cut right wall, going up
G1 X412.000 Y250.000 F170 ; rect 2: cut top edge
G1 X412.000 Y130.000 F170 ; rect 2: cut right wall, going down
G1 X612.000 Y130.000 F170 ; rect 3: bottom edge (line already cut?)
G1 X612.000 Y250.000 F170 ; rect 3: cut right wall, going up
G1 X812.000 Y250.000 F170 ; rect 4: cut top edge
G1 X812.000 Y130.000 F170 ; rect 4: cut right wall, going down
G1 X812.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X812.000 Y130.000 F600 ; return up the wall from periodic clean
G1 X1012.000 Y130.000 F170 ; rect 5: bottom edge (line already cut?)
G1 X1012.000 Y250.000 F170 ; rect 5: cut right wall, going up
G1 X1058.000 Y250.000 F170 ; cut off the right side of the row along the top line
G1 X1050.000 Y100.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y100.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1058.000 Y250.000 F600 ; come back from cleaning
G1 X1012.000 Y250.000 F170 ; top line: cut across the right leftover strip
G1 X812.000 Y250.000 F170 ; rect 5: cut top edge, straight line
M102 ; do the 360 knock
G1 X612.000 Y250.000 F170 ; rect 4: cut top edge, straight line
M102 ; do the 360 knock
G1 X412.000 Y250.000 F170 ; rect 3: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y250.000 F170 ; rect 2: cut top edge, straight line
M102 ; do the 360 knock
G1 X212.000 Y100.000 F170 ; periodic clean (4-rect interval): drop down the wall to safety Y
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X212.000 Y250.000 F600 ; return up the wall from periodic clean
G1 X12.000 Y250.000 F170 ; rect 1: cut top edge, straight line
G1 X0.000 Y250.000 F170 ; top line: cut across the left margin
G1 X12.000 Y250.000 F600 ; back to rect 1's left wall
G1 X12.000 Y130.000 F170 ; rect 1: cut left wall, going down
M102 ; do the 360 knock
G1 X0.000 Y130.000 F600 ; move to left edge (X0)
G1 X0.000 Y100.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
M2 ; end of program