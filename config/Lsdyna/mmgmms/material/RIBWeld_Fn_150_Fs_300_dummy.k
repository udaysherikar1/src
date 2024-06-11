*MAT_GENERAL_SPRING_DISCRETE_BEAM
$HMNAME MATERIALS         5RIBWeld_Fn_150_Fs_300_dummy                                                                  
         11.1000E-03
         1         0       0.0       0.0       0.0      0.03
         1         0       0.0       0.0       0.0         0
         2         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
         3         0       0.0       0.0       0.0       0.0
         2         0       0.0       0.0       0.0         0
         4         0       0.0       0.0       0.0       0.0
         3         0       0.0       0.0       0.0         0
         5         0       0.0       0.0       0.0       0.0
         4         0       0.0       0.0       0.0         0
         6         0       0.0       0.0       0.0       0.0
         4         0       0.0       0.0       0.0         0
*DEFINE_CURVE
$HMNAME CURVES         1RIBWeld_axial_stiffness_curve                                            
$HWCOLOR CURVES         1      11
$HMCURVE     1    0 RIBWeld_axial_stiffness_curve                                                    
         1                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 5.0
*DEFINE_CURVE
$HMNAME CURVES         2RIBWeld_shear_stiffness_curve                                            
$HWCOLOR CURVES         2      11
$HMCURVE     1    0 RIBWeld_shear_stiffness_curve                                                    
         2                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 4.0
*DEFINE_CURVE
$HMNAME CURVES         3RIBWeld_Torsional_stiffness_curve                                        
$HWCOLOR CURVES         3      11
$HMCURVE     1    0 RIBWeld_Torsional_stiffness_curve                                                
         3                 1.0       1.0                              
                 0.0                 0.0
                 1.0               100.0
*DEFINE_CURVE
$HMNAME CURVES         4RIBWeld_rotational_stiffness_curve                                       
$HWCOLOR CURVES         4      11
$HMCURVE     1    0 RIBWeld_rotational_stiffness_curve                                               
         4                 1.0       1.0                              
                 0.0                 0.0
                 1.0                 1.0
*END
