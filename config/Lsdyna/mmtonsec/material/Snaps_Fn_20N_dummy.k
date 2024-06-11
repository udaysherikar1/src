*KEYWORD
*MAT_GENERAL_SPRING_DISCRETE_BEAM
$HMNAME MATERIALS         5Snaps_Fn_20N_dummy                                                               
         11.1000E-09
         1         0       0.0       0.0       0.0      0.08
         1         0       0.0       0.0       0.0         0
         2         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
         3         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
*DEFINE_CURVE
$HMNAME CURVES         1Snaps_axial_stiffness_curve                                         
$HWCOLOR CURVES         1      11
$HMCURVE     1    2 Snaps_axial_stiffness_curve                                                 
         1                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 0.3
*DEFINE_CURVE
$HMNAME CURVES         2Snaps_shear_stiffness_curve                                         
$HWCOLOR CURVES         2      11
$HMCURVE     1    3 Snaps_shear_stiffness_curve                                                 
         2                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 7.0
*END
