; Circle-packed cutting pattern with margin-filling + feeder logic + periodic cleaning
; 2D hot-wire cutting, X/Y only - hex layout, full row-sweep cut order, clean every 4 circles per sweep
; window = 1 row(s) per push, main diameter 90.0mm, window 1000.0x100.0mm, X_GAP=0.0mm Y_GAP=2.0mm Y_GAP_WINDOW=2.0mm CUT_OFF_MARGIN=40.0mm
G21 ; units = mm
G90 ; absolute positioning
G17 ; XY plane for arcs
; RAIL_LENGTH=2131.646mm MATERIAL_LENGTH=475.0mm Y_AXIS_MAX_LIMIT=280.0mm -> unusable dead space at load = 1376.646mm (informational only, not a cutting limit)
; initial feed push = 1536.646mm, per-window feed push = 81.942mm (constant every seam)
G1 Z1536.646 F150 ; feed material in, ledge parked 120.000mm from the wire
; --- window 1 (Z=1536.646, row-offset parity=0) ---
M101 R10 P4
G1 X0.000 Y167.000 F600 ; travel to left edge, X0
G1 X12.000 Y167.000 F170 ; cut straight (margin/gap)
G2 X57.000 Y212.000 I45.000 J0.000 F170 ; first circle: pre-cut 90 of upper half from the left point
G3 X12.000 Y167.000 I0.000 J-45.000 F600 ; first circle: return from pre-cut back to the left point
G3 X57.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X57.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X49.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X102.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X108.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X102.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X147.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X147.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X139.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X192.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X192.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X237.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X237.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X229.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X282.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X288.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X282.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X327.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X327.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X327.000 Y72.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X319.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X372.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X378.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X372.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X417.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X417.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X409.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X462.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X468.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X462.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X507.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X507.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X499.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X552.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X558.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X552.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X597.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X597.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X589.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X642.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X648.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X642.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X687.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X687.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X687.000 Y72.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X732.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X738.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X732.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X777.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X777.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X769.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X822.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X828.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X822.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X867.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X867.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X859.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X912.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X918.029 Y189.500 I45.000 J0.000 F170 ; first circle: pre-cut 30 of upper half from the left point
G3 X912.000 Y167.000 I38.971 J-22.500 F600 ; first circle: return from pre-cut back to the left point
G3 X957.000 Y122.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X957.000 Y97.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X949.186 Y122.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X1002.000 Y167.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1048.000 Y167.000 F170 ; cut straight (margin/gap)
G1 X1050.000 Y72.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y72.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1048.000 Y167.000 F600 ; come back from cleaning
G1 X1002.000 Y167.000 F600 ; travel back over margin/gap
G3 X912.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X912.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X912.000 Y167.000 F600 ; going back from the severing cut
G3 X822.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X822.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X822.000 Y167.000 F600 ; going back from the severing cut
G3 X732.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X732.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X732.000 Y167.000 F600 ; going back from the severing cut
G3 X642.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X642.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X642.000 Y72.000 F170 ; periodic clean (4-circle interval): continue down to safety Y from the severing cut
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X642.000 Y167.000 F600 ; return from periodic clean
G3 X552.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X552.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X552.000 Y167.000 F600 ; going back from the severing cut
G3 X462.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X462.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X462.000 Y167.000 F600 ; going back from the severing cut
G3 X372.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X372.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X372.000 Y167.000 F600 ; going back from the severing cut
G3 X282.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X282.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X282.000 Y72.000 F170 ; periodic clean (4-circle interval): continue down to safety Y from the severing cut
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X282.000 Y167.000 F600 ; return from periodic clean
G3 X192.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X192.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X192.000 Y167.000 F600 ; going back from the severing cut
G3 X102.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X102.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X102.000 Y167.000 F600 ; going back from the severing cut
G3 X12.000 Y167.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
G1 X12.000 Y147.000 F170 ; sever the potentially still connected circle
M102 ; do the 360 knock
G1 X12.000 Y167.000 F600 ; going back from the severing cut
G1 X12.000 Y167.000 F600 ; travel back over margin/gap
G1 X0.000 Y167.000 F600 ; move to left edge (X0)
G1 X0.000 Y72.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
M2 ; end of program