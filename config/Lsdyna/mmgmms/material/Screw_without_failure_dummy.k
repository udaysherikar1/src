*MAT_GENERAL_SPRING_DISCRETE_BEAM
$HMNAME MATERIALS         5Screw_without_failure_dummy                                                                  
         57.8500E-03
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
$HMNAME CURVES         1Screw_axial_stiffness_curve                                            
$HWCOLOR CURVES         1      11
$HMCURVE     1    0 Screw_axial_stiffness_curve                                                    
         1                 1.0       1.0                              
                 0.0                 0.0
                 1.0               100.0
*DEFINE_CURVE
$HMNAME CURVES         2Screw_shear_stiffness_curve                                            
$HWCOLOR CURVES         2      11
$HMCURVE     1    0 Screw_shear_stiffness_curve                                                    
         2                 1.0       1.0                              
                 0.0                 0.0
                 1.0                10.0
*DEFINE_CURVE
$HMNAME CURVES         3Screw_Torsional_stiffness_curve                                        
$HWCOLOR CURVES         3      11
$HMCURVE     1    0 Screw_Torsional_stiffness_curve                                                
         3                 1.0       1.0                              
                 0.0                 0.0
                 1.0               100.0
*DEFINE_CURVE
$HMNAME CURVES         4Screw_rotational_stiffness_curve                                       
$HWCOLOR CURVES         4      11
$HMCURVE     1    0 Screw_rotational_stiffness_curve                                               
         4                 1.0       1.0                              
                 0.0                 0.0
                 1.0              1000.0
*END
