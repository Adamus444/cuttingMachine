; Circle-packed cutting pattern with margin-filling + feeder logic + periodic cleaning
; 2D hot-wire cutting, X/Y only - hex layout, full row-sweep cut order, clean every 4 circles per sweep
; window = 1 row(s) per push, main diameter 89.0mm, block width 990.0mm, X_GAP=0.0mm Y_GAP=2.0mm Y_GAP_WINDOW=2.0mm CUT_OFF_MARGIN=40.0mm
G21 ; units = mm
G90 ; absolute positioning
G17 ; XY plane for arcs
; SINGLE_WINDOW_ONLY = True: feeder/homing-between-windows logic skipped
M101 R0 P4 ; kill unecessary heat
G1 X0.000 Y0.000 F600 ; move to nominal XY zero
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
M2 ; end of program