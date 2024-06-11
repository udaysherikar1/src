*MAT_NONLINEAR_ELASTIC_DISCRETE_BEAM
$HMNAME MATERIALS         1Retainerclip_PSA_Fn_150_Fs_200_dummy                                                                    
         11.1000E-09       1.0       2.0       2.0       3.0       3.0       3.0
       0.0       0.0       0.0       0.0       0.0       0.0
       0.0       0.0       0.0       0.0       0.0       0.0
       0.1       0.2       0.3       0.0       0.0       0.0
       0.0       0.0       0.0       0.0       0.0       0.0
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         1       9
$HMCURVE     3    3 Retainer_axial_stiffness                                                                  
Retainer_axial_stiffness                                                        
         1         0       1.0       1.0       0.0       0.0         0           
                 0.0                 0.0
                 1.0             10000.0
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         2      13
$HMCURVE     1    1 Retainer_shear_stiffness                                                                  
Retainer_shear_stiffness                                                        
         2         0       1.0       1.0       0.0       0.0         0          
                 0.0                 0.0
                 2.0                 1.0
                 3.0             20000.0
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         3       8
$HMCURVE     1    1 Retainer_rotational_stiffness                                                                    
Retainer_rotational_stiffness                                                          
         3         0       1.0       1.0       0.0       0.0         0          
                 0.0                 0.0
                 1.0           1000000.0
*END
