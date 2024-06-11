*MAT_GENERAL_SPRING_DISCRETE_BEAM
$HMNAME MATERIALS         5Grommet_without_failure_dummy                                                                  
         17.8500E-03
         1         0       0.0       0.0       0.0       0.0
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
$HMNAME CURVES         1Grommet_axial_stiffness_curve                                            
$HWCOLOR CURVES         1      11
$HMCURVE     1    0 Grommet_axial_stiffness_curve                                                    
         1                 1.0       1.0                              
                 0.0                 0.0
                 1.0                10.0
*DEFINE_CURVE
$HMNAME CURVES         2Grommet_shear_stiffness_curve                                            
$HWCOLOR CURVES         2      11
$HMCURVE     1    0 Grommet_shear_stiffness_curve                                                    
         2                 1.0       1.0                              
                 0.0                 0.0
                 1.0               100.0
*DEFINE_CURVE
$HMNAME CURVES         3Grommet_Torsional_stiffness_curve                                        
$HWCOLOR CURVES         3      11
$HMCURVE     1    0 Grommet_Torsional_stiffness_curve                                                
         3                 1.0       1.0                              
                 0.0                 0.0
                 1.0               100.0
*DEFINE_CURVE
$HMNAME CURVES         4Grommet_rotational_stiffness_curve                                       
$HWCOLOR CURVES         4      11
$HMCURVE     1    0 Grommet_rotational_stiffness_curve                                               
         4                 1.0       1.0                              
                 0.0                 0.0
                 1.0               100.0
*END
