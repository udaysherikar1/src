*KEYWORD
*MAT_GENERAL_SPRING_DISCRETE_BEAM
$HMNAME MATERIALS         5Plasticclip_Fn_15N_dummy                                                               
         11.1000E-09
         1         0       0.0       0.0       0.0      0.01
         1         0       0.0       0.0       0.0         0
         2         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
         3         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
*DEFINE_CURVE
$HMNAME CURVES         1Plasticclip_axial_stiffness_curve                                         
$HWCOLOR CURVES         1      11
$HMCURVE     1    2 Plasticclip_axial_stiffness_curve                                                 
         1                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 0.5
*DEFINE_CURVE
$HMNAME CURVES         2Plasticclip_shear_stiffness_curve                                         
$HWCOLOR CURVES         2      11
$HMCURVE     1    3 Plasticclip_shear_stiffness_curve                                                 
         2                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 2.0
*END
