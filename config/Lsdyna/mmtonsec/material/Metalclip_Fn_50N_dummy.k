*KEYWORD
*MAT_GENERAL_SPRING_DISCRETE_BEAM
$HMNAME MATERIALS         5Metalclip_Fn_50N_dummy                                                               
         57.8500E-09
         1         0       0.0       0.0       0.0       0.0
         1         0       0.0       0.0       0.0         0
         2         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
         3         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
*DEFINE_CURVE
$HMNAME CURVES         1Metalclip_axial_stiffness_curve                                         
$HWCOLOR CURVES         1      11
$HMCURVE     1    2 Metalclip_axial_stiffness_curve                                                 
         1                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 1.0
*DEFINE_CURVE
$HMNAME CURVES         2Metalclip_shear_stiffness_curve                                         
$HWCOLOR CURVES         2      11
$HMCURVE     1    3 Metalclip_shear_stiffness_curve                                                 
         2                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 1.0
*END
