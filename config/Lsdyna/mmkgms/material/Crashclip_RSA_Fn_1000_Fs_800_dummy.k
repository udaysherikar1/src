*MAT_NONLINEAR_ELASTIC_DISCRETE_BEAM
$HMNAME MATERIALS         1Crashclip_RSA_Fn_1000_Fs_800_dummy                                                                 
         11.1000E-09       1.0       2.0       2.0       3.0       3.0       3.0
       0.0       0.0       0.0       0.0       0.0       0.0
       0.0       0.0       0.0       0.0       0.0       0.0
       8.0       0.0       0.0       0.0       0.0       0.0
       0.0       0.0       0.0       0.0       0.0       0.0
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         1       4
$HMCURVE     3    1 Crashclip_axial_stiffness                                                      
Crashclip_axial_stiffness                                                           
         1         0       1.0       1.0       0.0       0.0         0          
                 0.0                 0.0
                 4.1               100.0
*DEFINE_CURVE_TITLE
$HWCOLOR CURVES         2       3
$HMCURVE     2    2 Crashclip_shear_stiffness                                                                     
Crashclip_shear_stiffness                                                           
         2         0       1.0       1.0       0.0       0.0         0          
                 0.0                 0.0
                 2.5                 1.0
                 2.6               100.0
*DEFINE_CURVE
$HMNAME CURVES        Crashclip_rotational_stiffness                                                   
$HWCOLOR CURVES         3       7
$HMCURVE     2    3 Crashclip_rotational_stiffness                                                                       
         3         0       1.0       1.0       0.0       0.0         0          
                -1.0          -1000000.0
                 0.0                 0.0
                 1.0           1000000.0
*END
