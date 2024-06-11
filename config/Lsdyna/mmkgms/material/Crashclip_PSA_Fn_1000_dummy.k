*MAT_NONLINEAR_ELASTIC_DISCRETE_BEAM
$HMNAME MATERIALS         1Crashclip_PSA_Fn_1000_dummy                                                                 
         11.1000E-06       1.0       2.0       2.0       3.0       3.0       3.0
       0.0       0.0       0.0       0.0       0.0       0.0
       0.0       0.0       0.0       0.0       0.0       0.0
       0.1       0.0       0.0       0.0       0.0       0.0
       0.0       0.0       0.0       0.0       0.0       0.0
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         1       4
$HMCURVE     3    1 Crashclip_axial_stiffness                                                      
Crashclip_axial_stiffness                                                           
         1         0       1.0       1.0       0.0       0.0         0          
                 0.0                 0.0
                 1.0               0.088
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         2       3
$HMCURVE     2    2 Crashclip_shear_stiffness                                                                     
Crashclip_shear_stiffness                                                           
         2         0       1.0       1.0       0.0       0.0         0          
                 0.0                 0.0
                 2.0              0.0002
                 3.0               0.005
*DEFINE_CURVE
$HMNAME CURVES        Crashclip_rotational_stiffness                                                   
$HWCOLOR CURVES         3       7
$HMCURVE     2    3 Crashclip_rotational_stiffness                                                                       
         3         0       1.0       1.0       0.0       0.0         0          
                -1.0              -100.0
                 0.0                 0.0
                 1.0               100.0
*END
