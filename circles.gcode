; Circle-packed cutting pattern with margin-filling + feeder logic + periodic cleaning
; 2D hot-wire cutting, X/Y only - hex layout, full row-sweep cut order, clean every 4 circles per sweep
; window = 1 row(s) per push, main diameter 89.0mm, block width 990.0mm, X_GAP=0.0mm Y_GAP=2.0mm Y_GAP_WINDOW=2.0mm CUT_OFF_MARGIN=40.0mm
G21 ; units = mm
G90 ; absolute positioning
G17 ; XY plane for arcs
; RAIL_LENGTH=2131.646mm MATERIAL_LENGTH=1525.0mm Y_AXIS_MAX_LIMIT=280.0mm -> unusable dead space at load = 326.646mm (informational only, not a cutting limit)
; initial feed push = 446.646mm, per-window feed push = 81.076mm (constant every seam)
G1 Z446.646 F200 ; feed material in, ledge parked 160.000mm from the wire
; --- window 1 (Z=446.646, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y206.500 F600 ; travel to left edge, X0
G1 X12.000 Y206.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y251.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y206.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X56.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X56.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X48.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X145.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X145.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X137.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X234.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X234.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X226.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X323.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X323.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X323.500 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X315.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X412.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X412.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X404.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X501.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X501.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X493.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X590.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X590.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X582.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X679.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X679.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X679.500 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X671.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X768.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X768.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X760.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X857.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X857.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X849.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y232.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y206.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X946.500 Y162.000 I44.500 J0.000 F170 ; cut 90 of 180 deg of lower half, d=89
G1 X946.500 Y137.000 F170 ; cut waste-severing detour, fixed 25mm at 90 deg below horizontal
G1 X938.773 Y162.676 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y206.500 I7.727 J43.824 F170 ; finish remaining 100 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y206.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y112.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y112.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y206.500 F600 ; come back from cleaning
G1 X991.000 Y206.500 F600 ; travel back over margin/gap
G3 X902.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y206.500 F600 ; return from periodic clean
G3 X546.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y112.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y206.500 F600 ; return from periodic clean
G3 X190.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y206.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y206.500 F600 ; travel back over margin/gap
G1 X0.000 Y206.500 F600 ; move to left edge (X0)
G1 X0.000 Y112.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z527.722 F200 ; feed 81.076mm more material in
; --- window 2 (Z=527.722, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z608.799 F200 ; feed 81.076mm more material in
; --- window 3 (Z=608.799, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z689.875 F200 ; feed 81.076mm more material in
; --- window 4 (Z=689.875, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z770.951 F200 ; feed 81.076mm more material in
; --- window 5 (Z=770.951, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z852.027 F200 ; feed 81.076mm more material in
; --- window 6 (Z=852.027, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z933.104 F200 ; feed 81.076mm more material in
; --- window 7 (Z=933.104, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1014.180 F200 ; feed 81.076mm more material in
; --- window 8 (Z=1014.180, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1095.256 F200 ; feed 81.076mm more material in
; --- window 9 (Z=1095.256, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1176.332 F200 ; feed 81.076mm more material in
; --- window 10 (Z=1176.332, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1257.409 F200 ; feed 81.076mm more material in
; --- window 11 (Z=1257.409, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1338.485 F200 ; feed 81.076mm more material in
; --- window 12 (Z=1338.485, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1419.561 F200 ; feed 81.076mm more material in
; --- window 13 (Z=1419.561, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1500.637 F200 ; feed 81.076mm more material in
; --- window 14 (Z=1500.637, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1581.714 F200 ; feed 81.076mm more material in
; --- window 15 (Z=1581.714, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1662.790 F200 ; feed 81.076mm more material in
; --- window 16 (Z=1662.790, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1743.866 F200 ; feed 81.076mm more material in
; --- window 17 (Z=1743.866, row-offset parity=0) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X12.000 Y204.500 F170 ; cut straight (margin/gap)
G2 X56.500 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X12.000 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X87.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X98.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X82.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X101.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X109.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X101.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X176.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X187.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X171.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X190.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X198.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X190.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X265.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X276.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X260.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X279.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X287.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X279.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X354.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X365.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X365.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X349.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X368.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X376.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X368.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X443.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X454.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X438.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X457.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X465.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X457.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X532.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X543.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X527.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X546.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X554.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X546.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X621.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X632.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X616.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X635.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X643.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X635.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X710.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X721.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X721.573 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X705.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X724.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X732.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X724.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X799.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X810.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X794.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X813.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X821.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X813.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X888.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X899.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X883.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X902.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X910.048 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X902.000 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X977.966 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X988.573 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X972.024 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X991.000 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X991.000 Y204.500 F600 ; travel back over margin/gap
G3 X902.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X813.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X724.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X635.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X635.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X635.000 Y204.500 F600 ; return from periodic clean
G3 X546.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X457.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X368.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X279.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X279.000 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X279.000 Y204.500 F600 ; return from periodic clean
G3 X190.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X101.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X12.000 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
G1 Z1824.942 F200 ; feed 81.076mm more material in
; --- window 18 (Z=1824.942, row-offset parity=1) ---
M101 R10 P4 ; heat wire to cutting temp
G1 X0.000 Y204.500 F600 ; travel to left edge, X0
G1 X56.500 Y204.500 F170 ; cut straight (margin/gap)
G2 X101.000 Y249.000 I44.500 J0.000 F170 ; pre-cut 90 of 180 deg of upper half from the left point
G3 X56.500 Y204.500 I0.000 J-44.500 F600 ; return from pre-cut back to the left point
G3 X132.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X143.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X126.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X145.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X153.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X145.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X221.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X232.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X215.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X234.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X242.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X234.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X310.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X321.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X304.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X323.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X331.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X323.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X399.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X410.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X410.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X393.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X412.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X420.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X412.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X488.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X499.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X482.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X501.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X509.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X501.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X577.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X588.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X571.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X590.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X598.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X590.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X666.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X677.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X660.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X679.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X687.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X679.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X755.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X766.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X766.073 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y from the waste-severing detour
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X749.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X768.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X776.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X768.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X844.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X855.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X838.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X857.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X865.548 Y230.024 I44.500 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X857.500 Y204.500 I36.452 J-25.524 F600 ; return from pre-cut back to the left point
G3 X933.466 Y173.034 I44.500 J0.000 F170 ; cut 135 of 180 deg of lower half, d=89
G1 X944.073 Y162.427 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X927.524 Y168.048 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X946.500 Y204.500 I-25.524 J36.452 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G2 X951.021 Y218.839 I25.000 J0.000 F170 ; pre-cut 35 of 180 deg of upper half from the left point
G3 X946.500 Y204.500 I20.479 J-14.339 F600 ; return from pre-cut back to the left point
G3 X989.178 Y186.822 I25.000 J0.000 F170 ; cut 135 of 180 deg of lower half, d=50
G1 X999.784 Y176.216 F170 ; cut waste-severing detour, fixed 15mm at 45 deg below horizontal
G1 X985.839 Y184.021 F170 ; return from detour 10 deg before the original stop point (overlap)
G3 X996.500 Y204.500 I-14.339 J20.479 F170 ; finish remaining 55 of 180 deg of lower half (includes 10 deg of overlap re-cut)
G1 X1038.000 Y204.500 F170 ; cut straight (margin/gap)
G1 X1050.000 Y110.000 F600 ; move to burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
G1 X1050.000 Y110.000 F600 ; move to heat up
M101 P4 R10 ; reheat wire to cutting temp
G1 X1038.000 Y204.500 F600 ; come back from cleaning
G1 X996.500 Y204.500 F600 ; travel back over margin/gap
G3 X946.500 Y204.500 I-25.000 J0.000 F170 ; cut upper half of circle d=50
M102 ; do the 360 knock
G3 X857.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X768.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X679.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X679.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X679.500 Y204.500 F600 ; return from periodic clean
G3 X590.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X501.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X412.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X323.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X323.500 Y110.000 F170 ; periodic clean (4-circle interval): drop to safety Y at the left point of the upper half
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 P4 R10 ; reheat wire to cutting temp
G1 X323.500 Y204.500 F600 ; return from periodic clean
G3 X234.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X145.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G3 X56.500 Y204.500 I-44.500 J0.000 F170 ; cut upper half of circle d=89
M102 ; do the 360 knock
G1 X12.000 Y204.500 F600 ; travel back over margin/gap
G1 X0.000 Y204.500 F600 ; move to left edge (X0)
G1 X0.000 Y110.000 F600 ; move to a safe spot, burn off coating
M101 P4 R0 ; cool down the wire
M101 P10 R26 ; heat up, burn off coating
M101 P8 R0 ; cool down the wire
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
M2 ; end of program