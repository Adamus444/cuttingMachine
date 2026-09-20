; Circle-packed cutting pattern with margin-filling + feeder logic + periodic cleaning
; 2D hot-wire cutting, X/Y only - hex layout, full row-sweep cut order, clean every 4 circles per sweep
; window = 1 row(s) per push, main diameter 90.0mm, block width 1000.0mm, X_GAP=0.0mm Y_GAP=2.0mm Y_GAP_WINDOW=2.0mm CUT_OFF_MARGIN=40.0mm
G21 ; units = mm
G90 ; absolute positioning
G17 ; XY plane for arcs
; RAIL_LENGTH=2131.646mm MATERIAL_LENGTH=475.0mm Y_AXIS_MAX_LIMIT=280.0mm -> unusable dead space at load = 1376.646mm (informational only, not a cutting limit)
; initial feed push = 1496.646mm, per-window feed push = 81.942mm (constant every seam)
G1 Z1496.646 F200 ; feed material in, ledge parked 160.000mm from the wire
; --- window 1 (Z=1496.646, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y207.000 F600 ; travel to left edge, X0
G1 X12.000 Y207.000 F170 ; cut straight (margin/gap)
G2 X57.000 Y252.000 I45.000 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y207.000 I0.000 J-45.000 F600 ; return from pre-cut back to the left point
G3 X57.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X57.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X49.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X102.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X110.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X102.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X147.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X147.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X139.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X192.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X200.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X192.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X237.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X237.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X229.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X282.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X290.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X282.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X327.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X327.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X327.000 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X319.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X372.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X380.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X372.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X417.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X417.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X409.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X462.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X470.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X462.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X507.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X507.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X499.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X552.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X560.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X552.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X597.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X597.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X589.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X642.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X650.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X642.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X687.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X687.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X687.000 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X732.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X740.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X732.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X777.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X777.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X769.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X822.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X830.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X822.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X867.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X867.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X859.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X912.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X920.138 Y232.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X912.000 Y207.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X957.000 Y162.000 I45.000 J0.000 F170 ; cut 90 of 180 deg of lower half, d=90
G1 X957.000 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X949.186 Y162.684 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X1002.000 Y207.000 I7.814 J44.316 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1048.000 Y207.000 F170 ; cut straight (margin/gap)
G1 X1050.000 Y112.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y112.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1048.000 Y207.000 F600 ; come back from cleaning
G1 X1002.000 Y207.000 F600 ; travel back over margin/gap
G3 X912.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X822.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X732.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X642.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X642.000 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X642.000 Y207.000 F600 ; return from periodic clean
G3 X552.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X462.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X372.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X282.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X282.000 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X282.000 Y207.000 F600 ; return from periodic clean
G3 X192.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X102.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X12.000 Y207.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X12.000 Y207.000 F600 ; travel back over margin/gap
G1 X0.000 Y207.000 F600 ; move to left edge (X0)
G1 X0.000 Y112.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1578.588 F200 ; feed 81.942mm more material in
; --- window 2 (Z=1578.588, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y205.000 F600 ; travel to left edge, X0
G1 X57.000 Y205.000 F170 ; cut straight (margin/gap)
G2 X102.000 Y250.000 I45.000 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X57.000 Y205.000 I0.000 J-45.000 F600 ; return from pre-cut back to the left point
G3 X133.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X144.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X127.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X147.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X155.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X147.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X223.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X234.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X217.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X237.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X245.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X237.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X313.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X324.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X307.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X327.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X335.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X327.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X403.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X414.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X414.426 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X397.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X417.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X425.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X417.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X493.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X504.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X487.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X507.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X515.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X507.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X583.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X594.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X577.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X597.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X605.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X597.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X673.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X684.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X667.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X687.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X695.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X687.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X763.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X774.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X774.426 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X757.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X777.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X785.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X777.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X853.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X864.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X847.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X867.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X875.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X867.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X943.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X954.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X937.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X957.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X961.521 Y219.339 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X957.000 Y205.000 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X999.678 Y187.322 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X1010.284 Y176.716 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X996.339 Y184.521 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X1007.000 Y205.000 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1048.000 Y205.000 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1048.000 Y205.000 F600 ; come back from cleaning
G1 X1007.000 Y205.000 F600 ; travel back over margin/gap
G3 X957.000 Y205.000 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X867.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X777.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X687.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X687.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X687.000 Y205.000 F600 ; return from periodic clean
G3 X597.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X507.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X417.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X327.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X327.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X327.000 Y205.000 F600 ; return from periodic clean
G3 X237.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X147.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X57.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X12.000 Y205.000 F600 ; travel back over margin/gap
G1 X0.000 Y205.000 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1660.531 F200 ; feed 81.942mm more material in
; --- window 3 (Z=1660.531, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y205.000 F600 ; travel to left edge, X0
G1 X12.000 Y205.000 F170 ; cut straight (margin/gap)
G2 X57.000 Y250.000 I45.000 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y205.000 I0.000 J-45.000 F600 ; return from pre-cut back to the left point
G3 X88.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X99.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X102.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X110.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X102.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X178.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X189.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X172.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X192.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X200.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X192.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X268.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X279.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X262.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X282.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X290.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X282.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X358.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X369.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X369.426 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X352.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X372.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X380.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X372.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X448.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X459.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X442.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X462.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X470.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X462.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X538.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X549.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X532.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X552.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X560.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X552.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X628.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X639.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X622.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X642.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X650.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X642.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X718.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X729.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X729.426 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X712.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X732.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X740.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X732.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X808.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X819.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X802.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X822.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X830.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X822.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X898.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X909.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X892.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X912.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X920.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X912.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X988.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X999.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X982.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X1002.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1048.000 Y205.000 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1048.000 Y205.000 F600 ; come back from cleaning
G1 X1002.000 Y205.000 F600 ; travel back over margin/gap
G3 X912.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X822.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X732.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X642.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X642.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X642.000 Y205.000 F600 ; return from periodic clean
G3 X552.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X462.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X372.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X282.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X282.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X282.000 Y205.000 F600 ; return from periodic clean
G3 X192.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X102.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X12.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X12.000 Y205.000 F600 ; travel back over margin/gap
G1 X0.000 Y205.000 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1742.473 F200 ; feed 81.942mm more material in
; --- window 4 (Z=1742.473, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y205.000 F600 ; travel to left edge, X0
G1 X57.000 Y205.000 F170 ; cut straight (margin/gap)
G2 X102.000 Y250.000 I45.000 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X57.000 Y205.000 I0.000 J-45.000 F600 ; return from pre-cut back to the left point
G3 X133.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X144.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X127.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X147.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X155.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X147.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X223.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X234.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X217.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X237.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X245.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X237.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X313.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X324.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X307.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X327.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X335.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X327.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X403.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X414.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X414.426 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X397.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X417.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X425.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X417.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X493.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X504.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X487.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X507.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X515.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X507.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X583.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X594.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X577.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X597.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X605.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X597.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X673.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X684.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X667.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X687.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X695.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X687.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X763.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X774.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X774.426 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X757.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X777.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X785.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X777.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X853.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X864.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X847.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X867.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X875.138 Y230.811 I45.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X867.000 Y205.000 I36.862 J-25.811 F600 ; return from pre-cut back to the left point
G3 X943.820 Y173.180 I45.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=90
G1 X954.426 Y162.574 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X937.811 Y168.138 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X957.000 Y205.000 I-25.811 J36.862 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X961.521 Y219.339 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X957.000 Y205.000 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X999.678 Y187.322 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X1010.284 Y176.716 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X996.339 Y184.521 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X1007.000 Y205.000 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1048.000 Y205.000 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1048.000 Y205.000 F600 ; come back from cleaning
G1 X1007.000 Y205.000 F600 ; travel back over margin/gap
G3 X957.000 Y205.000 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X867.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X777.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X687.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X687.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X687.000 Y205.000 F600 ; return from periodic clean
G3 X597.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X507.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X417.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X327.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X327.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X327.000 Y205.000 F600 ; return from periodic clean
G3 X237.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X147.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G3 X57.000 Y205.000 I-45.000 J0.000 F170 ; cut upper half of circle d=90
M102 ; do the 360 knock
G1 X12.000 Y205.000 F600 ; travel back over margin/gap
G1 X0.000 Y205.000 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
M2 ; end of program