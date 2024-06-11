# %  procomp E:\\aa\\*.tcl
# %  procomp C:\\WorkingDir\\WIP\\Connection_modelling\\package\\*.tcl
# 21 SPRING , 61 ROD ,1 MASS ,57 ICE ,3 WELD ,5 RIGID ,55 RIGIDLINK ,56 RBE3 ,22 JOINT ,60 BAR ,70 GAP ,103 TRIA ,
# 104 QUAD ,106 TRIA6 ,108 QUAD8 ,205 PYRAMID5 ,208 HEX8 ,204 TETRA4 ,210 TETRA10 ,213 PYRAMID13 ,206 PENTA6 ,215 PENTA15 ,220 HEX6 ,2 PLOT
 
package require http

if {[namespace exists ::connector]} {
	namespace delete ::connector
}


namespace eval ::connector {
    	
	set ::connector::scriptDir [file dirname [info script]];
	set ::connector::profile [hm_info templatetype];
		
	if {[file exists [file join $::connector::scriptDir utils.tbc]]} {
		source [file join $::connector::scriptDir utils.tbc];
	} else {
		source [file join $::connector::scriptDir utils.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir contact_pamcrash.tbc]]} {
		source [file join $::connector::scriptDir contact_pamcrash.tbc];
	} else {
		source [file join $::connector::scriptDir contact_pamcrash.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir RP_Ribweld.tbc]]} {
		source [file join $::connector::scriptDir RP_Ribweld.tbc];
	} else {
		source [file join $::connector::scriptDir RP_Ribweld.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir rib.tbc]]} {
		source [file join $::connector::scriptDir rib.tbc];
	} else {
		source [file join $::connector::scriptDir rib.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir License_utils.tbc]]} {
		source [file join $::connector::scriptDir License_utils.tbc];
	} else {
		source [file join $::connector::scriptDir License_utils.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir Help_image.tbc]]} {
		source [file join $::connector::scriptDir Help_image.tbc];
	} else {
		source [file join $::connector::scriptDir Help_image.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir Get_doghouse_nodes.tbc]]} {
		source [file join $::connector::scriptDir Get_doghouse_nodes.tbc];
	} else {
		source [file join $::connector::scriptDir Get_doghouse_nodes.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir surfaceWeld.tbc]]} {
		source [file join $::connector::scriptDir surfaceWeld.tbc];
	} else {
		source [file join $::connector::scriptDir surfaceWeld.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir DeleteConnection.tbc]]} {
		source [file join $::connector::scriptDir DeleteConnection.tbc];
	} else {
		source [file join $::connector::scriptDir DeleteConnection.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir screw.tbc]]} {
		source [file join $::connector::scriptDir screw.tbc];
	} else {
		source [file join $::connector::scriptDir screw.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir clips.tbc]]} {
		source [file join $::connector::scriptDir clips.tbc];
	} else {
		source [file join $::connector::scriptDir clips.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir popup_images.tbc]]} {
		source [file join $::connector::scriptDir popup_images.tbc];
	} else {
		source [file join $::connector::scriptDir popup_images.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir us_weld.tbc]]} {
		source [file join $::connector::scriptDir us_weld.tbc];
	} else {
		source [file join $::connector::scriptDir us_weld.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir retainers.tbc]]} {
		source [file join $::connector::scriptDir retainers.tbc];
	} else {
		source [file join $::connector::scriptDir retainers.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir createDummyMaterial.tbc]]} {
		source [file join $::connector::scriptDir createDummyMaterial.tbc];
	} else {
		source [file join $::connector::scriptDir createDummyMaterial.tcl];
	}
	
	set ::connector::joint_length "5.0";
}


proc ::connector::gui_load {sub_frm1} {
	
	variable duplicateVar_sub_frm1 $sub_frm1;
	
	set ::connector::file_open_start_time [clock seconds];
	set tempSolver [hm_info templatetype];
	
	set note_frm [hwtk::frame $sub_frm1.note_frm ];
	pack $note_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
		
	set separator_frm [hwtk::label $sub_frm1.separator_frm -text "------------------------------------------------------------------------------------------------------------"];
	pack $separator_frm -side top -expand true -fill both -pady 4 -padx 4;	

	set program_frm [hwtk::frame $sub_frm1.program_frm ];
	pack $program_frm -side top -expand true -fill x -pady 4 -padx 4 -anchor nw;
	
	set mat_frm [hwtk::frame $sub_frm1.mat_frm ];
	pack $mat_frm -side top -expand true -fill x -pady 4 -padx 4 -anchor nw;
	
	set connection_frm [hwtk::frame $sub_frm1.connection_frm ];
	pack $connection_frm -side top -expand true -fill x -pady 4 -padx 4 -anchor nw;
	
	# vehilce program Name
	if {![info exists ::connector::vehicle_program_name]} {
		set ::connector::vehicle_program_name "";
	}
	#set ::connector::vehicle_program_name "dummy"
	set programName_frm [hwtk::frame $program_frm.programName_frm ];
	pack $programName_frm -side top -expand false -fill x -pady 4 -padx 4 -anchor nw;
	set programName_label [hwtk::label $programName_frm.programName_label -text "Program Name:" -width 14 -help "Valid vehicle program name"];
	pack $programName_label -side left -expand false -fill x -pady 4 -padx 4;	
	set programName_entry [hwtk::entry $programName_frm.programName_entry -width 4 -help "Valid vehicle program name" -textvariable ::connector::vehicle_program_name];
	pack $programName_entry -side top -expand true -fill x -pady 4 -padx 4 -anchor nw;
	
	# create and assign material 
	set material_frm [hwtk::frame $mat_frm.material_frm ];
	pack $material_frm -side top -expand false -fill x -pady 4 -padx 4 -anchor nw;
	variable label_materialFrm
	set label_materialFrm [hwtk::labelframe $material_frm.label_materialFrm -text "Create and Assigned Dummy Materials" -labelanchor nw -padding 4 \
					-helpcommand ""];
	pack $label_materialFrm -side top -expand false -padx 4 -pady 4 -anchor nw;
	set material_label [hwtk::label $label_materialFrm.material_label -text "Assign Materials" -width 24 ];
	pack $material_label -side left -expand false -fill x -pady 4 -padx 4;	
	set material_btn [hwtk::button $label_materialFrm.material_btn -text "Material" -command "::dummyMaterial::create_Assign_Mats_to_Comp" -width 14\
					-helpcommand "" -help "Create dummy materials and assign to Parts"];
	pack $material_btn -side left -expand false -pady 4 -padx 4 -anchor nw;	
	
	
	variable label_mainFrm	
	set label_mainFrm [hwtk::labelframe $connection_frm.label_mainFrm -text "Create Connections" -labelanchor nw -padding 4 \
					-helpcommand ""];
	pack $label_mainFrm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
			   	   
	set connection_type_level1_frm [hwtk::frame $label_mainFrm.connection_type_level1_frm ];
	pack $connection_type_level1_frm -side top -expand false -pady 4 -padx 12 -anchor nw;	

	set connection_type_level2_frm [hwtk::frame $label_mainFrm.connection_type_level2_frm ];
	pack $connection_type_level2_frm -side top -expand false -pady 4 -padx 12 -anchor nw;	
					
	variable connection_type_level2_2_frm
	set connection_type_level2_2_frm [hwtk::frame $label_mainFrm.connection_type_level2_2_frm ];
	pack $connection_type_level2_2_frm -side top -expand false -pady 4 -padx 4 -anchor nw;	
	
	variable sandwich_frm;
	set sandwich_frm [hwtk::frame $label_mainFrm.sandwich_frm ];
	pack $sandwich_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
				
	#---------------------------------------------------------------------------------------------------
	variable dog_house_color_frm;
	set dog_house_color_frm [frame $connection_type_level1_frm.dog_house_color_frm -background "#F1F1F1"];
	pack $dog_house_color_frm -side left -expand true -fill both -pady 4 -padx 4;
	set retainerBtn [hwtk::button $dog_house_color_frm.retainerBtn -text "Retainer" -command "::connector::createDogHouseOptionGUI $sub_frm1" -width 14\
					-helpcommand "" -state disabled];
	pack $retainerBtn -side left -expand false -pady 4 -padx 4 -anchor nw;	

	variable weld_cir_color_frm;
	set weld_cir_color_frm [frame $connection_type_level1_frm.weld_cir_color_frm -background "#F1F1F1"];
	pack $weld_cir_color_frm -side left -expand true -fill both -pady 4 -padx 4;

	set heatStakeBtn [hwtk::button $weld_cir_color_frm.heatStakeBtn -text "Heatstake" -command "::connector::createWeldOptionGUI $sub_frm1" -width 14 -state disabled];
	pack $heatStakeBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable surf_weld_color_frm;
	set surf_weld_color_frm [frame $connection_type_level1_frm.surf_weld_color_frm -background "#F1F1F1"];
	pack $surf_weld_color_frm -side left -expand true -fill both -pady 4 -padx 4;
	set surfaceWeld_btn [hwtk::button $surf_weld_color_frm.surfaceWeld_btn -text "Surface weld" -command "::connector::createSurfaceWeldOptionGUI $sub_frm1" \
	-width 14 -helpcommand "" -state disabled];
	pack $surfaceWeld_btn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	#---------------------------------------------------------------------------------------------------
	
	variable rib_weld_color_frm;
	set rib_weld_color_frm [frame $connection_type_level2_frm.rib_weld_color_frm -background "#F1F1F1"];
	pack $rib_weld_color_frm -side left -expand true -fill both -pady 4 -padx 4;
	set ribWeldBtn  [hwtk::button $rib_weld_color_frm.ribWeldBtn  -text "Rib weld" -command "::connector::createRibWeldOptionGUI $sub_frm1" -width 14\
					-helpcommand "" -state disabled];
	pack $ribWeldBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable screw_color_frm;
	set screw_color_frm [frame $connection_type_level2_frm.screw_color_frm -background "#F1F1F1"];
	pack $screw_color_frm -side left -expand true -fill both -pady 4 -padx 4;
	set screw_btn  [hwtk::button $screw_color_frm.screw_btn -text "Screw" -command "::connector::createScrewOptionGUI $sub_frm1" -width 14\
					-helpcommand "" -state disabled];
	pack $screw_btn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable clip_color_frm;
	set clip_color_frm [frame $connection_type_level2_frm.clip_color_frm -background "#F1F1F1"];
	pack $clip_color_frm -side left -expand true -fill both -pady 4 -padx 4;
	set clip_btn  [hwtk::button $clip_color_frm.clip_btn -text "Clip" -command "::connector::createClipOptionGUI $sub_frm1" -width 14\
					-helpcommand "" -state disabled];
	pack $clip_btn -side left -expand false -pady 4 -padx 4 -anchor nw;
		
	#---------------------------------------------------------------------------------------------------
	set color_frm [frame $note_frm.f1 -background red];
	pack $color_frm -side left -expand true -fill both -pady 4 -padx 4;
	set notelabel [hwtk::label $color_frm.notelabel -text "Note :  Support only Abaqus, LsDyna and Pamcrash"];
	pack $notelabel -side left -expand true -fill both -pady 4 -padx 4;	
		
	set help_btn  [hwtk::button $note_frm.help_btn -text "Help" -command "::connector::openHelp" -width 14];
	pack $help_btn -side left -expand false -pady 4 -padx 4 -anchor ne;	
	
	set ::connector::flag_doghouse 0;
	set ::connector::flag_weldCirc 0;
	set ::connector::flag_weldRibs 0;
	set ::connector::flag_surfWeld 0;
	set ::connector::flag_screw 0;
	set ::connector::flag_clip 0;
	
	
	#enable connection buttons
	::connector::enableConnectionBtns;
	#disable material button
	::connector::disableMaterialBtn;
	
	#activate only for development
	#set ::connector::vehicle_program_name "dummy"
	#::dummyMaterial::create_Assign_Mats_to_Comp
		
}

proc ::connector::enableConnectionBtns {} {

	variable dog_house_color_frm;
	variable weld_cir_color_frm;
	variable surf_weld_color_frm;
	variable rib_weld_color_frm;
	variable screw_color_frm;
	variable clip_color_frm;
			
	if {[info exists ::dummyMaterial::material_flag] && $::dummyMaterial::material_flag == 1} {
	
		$dog_house_color_frm.retainerBtn configure -state normal;
		$weld_cir_color_frm.heatStakeBtn configure -state normal;
		$surf_weld_color_frm.surfaceWeld_btn configure -state normal;
		$rib_weld_color_frm.ribWeldBtn configure -state normal;
		$screw_color_frm.screw_btn configure -state normal;
		$clip_color_frm.clip_btn configure -state normal;	
		
	}
}

proc ::connector::disableMaterialBtn {} {
	
	variable label_materialFrm;
	if {[info exists ::dummyMaterial::material_flag] && $::dummyMaterial::material_flag == 1} {
		$label_materialFrm.material_btn configure -state disabled;
	}
}


proc ::connector::createElementLayerComboBtn {frame_label} {

	variable label_mainFrm;	
	variable elem_layer_frm;	
	
	set ::connector::list_elem_layers [list "0" "1" "2" "3"];
	set ::connector::element_layers [lindex $::connector::list_elem_layers 2];
	
	catch {destroy $elem_layer_frm}
	
	set elem_layer_frm [hwtk::frame $label_mainFrm.elem_layer_frm ];
	pack $elem_layer_frm -side top -expand false -pady 4 -padx 4 -anchor nw;	
			
	set elem_layer_label [hwtk::label $elem_layer_frm.elem_layer_label -text $frame_label -width 18];
	pack $elem_layer_label -side left -expand true -pady 4 -padx 4;
	
	set elem_layer_entry [hwtk::editablecombobox $elem_layer_frm.elem_layer_entry -state readonly -width 10 -values [set ::connector::list_elem_layers] \
					 -default $::connector::element_layers -textvariable ::connector::element_layers];
	pack $elem_layer_entry -side left -expand true -pady 4 -padx 4;

}

proc ::connector::createExecuteButton {} {
	
	variable label_mainFrm;	
	variable execute_frm;	
	variable deleteBtn_frm;	
	variable execute_btn;	
	
	#reset review
	set ::connector::reviewConnection_flag 0;
	::connector::exec_reviewRecentConnection;
			
	catch {destroy $execute_frm}
	set execute_frm [hwtk::frame $label_mainFrm.execute_frm ];
	pack $execute_frm -side top -expand false -pady 4 -padx 4 -anchor ne;
	
	set review_chkBox [hwtk::checkbutton $execute_frm.review_chkBox -text "Review" -variable ::connector::reviewConnection_flag -command "::connector::exec_reviewRecentConnection" \
					-width 8 -help "Reverse the connection orientation"]
	pack $review_chkBox -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;
	
	#set reviewBtn_frm  [hwtk::button $execute_frm.reviewBtn_frm -text "Review" -command "::connector::exec_reviewRecentConnection" -width 14];
	#pack $reviewBtn_frm -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set execute_btn  [hwtk::button $execute_frm.execute_btn -text "Execute" -command "::connector::createConnections" -width 14];
	pack $execute_btn -side left -expand false -pady 4 -padx 4 -anchor ne;
	
	set deleteBtn_frm  [hwtk::button $execute_frm.deleteBtn_frm -text "Delete" -command "::delete::exec_deleteRecentConnection" -width 14];
	pack $deleteBtn_frm -side left -expand false -pady 4 -padx 4 -anchor nw;
	
}



proc ::connector::createWeldOptionGUI {sub_frm1} {
	
	variable label_mainFrm;
	variable usweld_frm;
				
	::connector::destroyFrames;
		
	set usweld_frm [hwtk::frame $label_mainFrm.usweld_frm ];
	pack $usweld_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set usweld_washer_frm [hwtk::labelframe $usweld_frm.usweld_washer_frm -text "Washers" -labelanchor nw -padding 4];
	pack $usweld_washer_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	#set usweld_mat_frm [hwtk::labelframe $usweld_frm.usweld_mat_frm -text "Materials" -labelanchor nw -padding 4];
	#pack $usweld_mat_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set usweld_methods_frm [hwtk::labelframe $usweld_frm.usweld_methods_frm -text "Methods" -labelanchor nw -padding 4];
	pack $usweld_methods_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set usweld_methods_frm1 [hwtk::frame $usweld_methods_frm.usweld_methods_frm1 ];
	pack $usweld_methods_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set usweld_methods_frm2 [hwtk::frame $usweld_methods_frm.usweld_methods_frm2 ];
	pack $usweld_methods_frm2 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set usweld_methods_frm3 [hwtk::frame $usweld_methods_frm.usweld_methods_frm3 ];
	pack $usweld_methods_frm3 -side top -expand false -pady 4 -padx 4 -anchor nw;
					
	::connector::createElementType_and_JointLength_GUI "usweld";
	::connector::createFaceNormal_and_JointOnSlave_GUI;
	#::connector::createElementLayerComboBtn "Boss Element Layers";
	::connector::createExecuteButton;
	
	variable deleteBtn_frm;	
	$deleteBtn_frm config -state normal;
	
	#----------------------------------------------------------------------------------------------
	variable us_washer_radioBtn1;
	variable us_washer_radioBtn2;
	set ::connector::usweld_radiobtn_washer 1;
	set us_washer_radioBtn1 [hwtk::radiobutton $usweld_washer_frm.us_washer_radioBtn1 -text "0-Layer" -width 14 -variable ::connector::usweld_radiobtn_washer\
	-value 1 -command "::usweld::rad_WasherBtn_callback zerolayer"]
	pack $us_washer_radioBtn1 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set us_washer_radioBtn2 [hwtk::radiobutton $usweld_washer_frm.us_washer_radioBtn2 -text "1-Layer" -width 14 -variable ::connector::usweld_radiobtn_washer\
	-value 2 -command "::usweld::rad_WasherBtn_callback onelayer"]
	pack $us_washer_radioBtn2 -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------
	
	#----------------------------------------------------------------------------------------------
	set ::connector::usweld_radiobtn_methods 1;
	set radioBtn3 [hwtk::radiobutton $usweld_methods_frm1.radioBtn3 -text "R - B - R" -width 14 -variable ::connector::usweld_radiobtn_methods\
	-value 1 -command "::usweld::rad_MethodBtn_callback r_b_r $sub_frm1"]
	pack $radioBtn3 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn4 [hwtk::radiobutton $usweld_methods_frm1.radioBtn4 -text "Rigid Patch" -width 14 -variable ::connector::usweld_radiobtn_methods\
	-value 2 -command "::usweld::rad_MethodBtn_callback rigid_patch $sub_frm1"]
	pack $radioBtn4 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable skoda_usweld_radioBtn;
	set skoda_usweld_radioBtn [hwtk::radiobutton $usweld_methods_frm2.skoda_usweld_radioBtn -text "Skoda" -width 14 -variable ::connector::usweld_radiobtn_methods\
	-value 3 -command "::usweld::rad_MethodBtn_callback Skoda $sub_frm1" -help "Skoda connections for PamCrash" -state disabled]
	pack $skoda_usweld_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn6 [hwtk::radiobutton $usweld_methods_frm2.radioBtn6 -text "Audi" -width 14 -variable ::connector::usweld_radiobtn_methods\
	-value 4 -command "::usweld::rad_MethodBtn_callback Audi $sub_frm1" -state disabled]
	pack $radioBtn6 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable collar_usweld_radioBtn;
	set collar_usweld_radioBtn [hwtk::radiobutton $usweld_methods_frm3.collar_usweld_radioBtn -text "Collar" -width 14 -variable ::connector::usweld_radiobtn_methods\
	-value 5 -command "::usweld::rad_MethodBtn_callback collar $sub_frm1" -state normal];
	pack $collar_usweld_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------
	
	if {$::connector::profile == "pamcrash2g"} {
		$skoda_usweld_radioBtn config -state normal;
		#$surf_weld_audi_chkBtn config -state normal;
	}
			
	set ::connector::flag_doghouse 0;
	set ::connector::flag_weldCirc 1;
	set ::connector::flag_weldRibs 0;
	set ::connector::flag_surfWeld 0;	
	set ::connector::flag_screw 0;
	set ::connector::flag_clip 0;
	
	set ::connector::usweld_Help_GUI_Flag 1;
	::connector::changeBtnBordingColor "weldCir"
	::connection::help::displayWeldCircularImage $sub_frm1

}


proc ::connector::createRibWeldOptionGUI {sub_frm1} {
	
	variable label_mainFrm;
	variable ribweld_frm;
		
	::connector::destroyFrames;
	
	set ribweld_frm [hwtk::frame $label_mainFrm.ribweld_frm ];
	pack $ribweld_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set ribweld_washer_frm [hwtk::labelframe $ribweld_frm.ribweld_washer_frm -text "Washers" -labelanchor nw -padding 4];
	pack $ribweld_washer_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	#set ribweld_mat_frm [hwtk::labelframe $ribweld_frm.ribweld_mat_frm -text "Materials" -labelanchor nw -padding 4];
	#pack $ribweld_mat_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set ribweld_methods_frm [hwtk::labelframe $ribweld_frm.ribweld_methods_frm -text "Methods" -labelanchor nw -padding 4];
	pack $ribweld_methods_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set ribweld_methods_frm1 [hwtk::frame $ribweld_methods_frm.ribweld_methods_frm1 ];
	pack $ribweld_methods_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set ribweld_methods_frm2 [hwtk::frame $ribweld_methods_frm.ribweld_methods_frm2 ];
	pack $ribweld_methods_frm2 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	::connector::createElementType_and_JointLength_GUI "ribweld";
	::connector::createFaceNormal_and_JointOnSlave_GUI;
	::connector::createExecuteButton;
	#----------------------------------------------------------------------------------------------
	variable rib_washer_radioBtn1;
	variable rib_washer_radioBtn2;
	set ::connector::ribweld_radiobtn_washer 1;
	set rib_washer_radioBtn1 [hwtk::radiobutton $ribweld_washer_frm.rib_washer_radioBtn1 -text "0-Layer" -width 14 -variable ::connector::ribweld_radiobtn_washer\
	-value 1 -command "::ribweld::rad_WasherBtn_callback zerolayer"]
	pack $rib_washer_radioBtn1 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set rib_washer_radioBtn2 [hwtk::radiobutton $ribweld_washer_frm.rib_washer_radioBtn2 -text "1-Layer" -width 14 -variable ::connector::ribweld_radiobtn_washer\
	-value 2 -command "::ribweld::rad_WasherBtn_callback onelayer" -state disabled]
	pack $rib_washer_radioBtn2 -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------
	
	#----------------------------------------------------------------------------------------------
	set ::connector::ribweld_radiobtn_methods 1;
	set radioBtn3 [hwtk::radiobutton $ribweld_methods_frm1.radioBtn3 -text "R - B - R" -width 14 -variable ::connector::ribweld_radiobtn_methods\
	-value 1 -command "::ribweld::rad_MethodBtn_callback r_b_r $sub_frm1"]
	pack $radioBtn3 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn4 [hwtk::radiobutton $ribweld_methods_frm1.radioBtn4 -text "Rigid Patch" -width 14 -variable ::connector::ribweld_radiobtn_methods\
	-value 2 -command "::ribweld::rad_MethodBtn_callback rigid_patch $sub_frm1"]
	pack $radioBtn4 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set skoda_ribweld_radioBtn [hwtk::radiobutton $ribweld_methods_frm2.skoda_ribweld_radioBtn -text "Skoda" -width 14 -variable ::connector::ribweld_radiobtn_methods\
	-value 3 -command "::ribweld::rad_MethodBtn_callback Skoda $sub_frm1" -help "Skoda connections for PamCrash" -state disabled]
	pack $skoda_ribweld_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn6 [hwtk::radiobutton $ribweld_methods_frm2.radioBtn6 -text "Audi" -width 14 -variable ::connector::ribweld_radiobtn_methods\
	-value 4 -command "::ribweld::rad_MethodBtn_callback Audi $sub_frm1" -state disabled]
	pack $radioBtn6 -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------
	if {$::connector::profile == "pamcrash2g"} {
		$skoda_ribweld_radioBtn config -state normal;
		#$surf_weld_audi_chkBtn config -state normal;
	}
	
	variable sandwich_chkBox;
	$sandwich_chkBox config -state disabled;
	
	set ::connector::flag_doghouse 0;
	set ::connector::flag_weldCirc 0;
	set ::connector::flag_weldRibs 1;
	set ::connector::flag_surfWeld 0;
	set ::connector::flag_screw 0;
	set ::connector::flag_clip 0;
	
	set ::connector::ribweld_Help_GUI_Flag 1;
	::connector::changeBtnBordingColor "ribWeld"
	::connection::help::displayWeldRibImage $sub_frm1
}

proc ::connector::createDogHouseOptionGUI {sub_frm1} {
	
	variable label_mainFrm;	
	variable dogHouse_labelFrm1
	
	::connector::destroyFrames;
	
	set dogHouse_labelFrm1 [hwtk::frame $label_mainFrm.dogHouse_labelFrm1 ];
	pack $dogHouse_labelFrm1 -side top -expand false -pady 4 -padx 4 -anchor nw;	
	
	::connector::createElementType_and_JointLength_GUI "doghouse";
	::connector::createFaceNormal_and_JointOnSlave_GUI;
	::connector::createExecuteButton;
		
	set retainer_methods_frm [hwtk::labelframe $dogHouse_labelFrm1.retainer_methods_frm -text "Methods" -labelanchor nw -padding 4];
	pack $retainer_methods_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set retainer_methods_frm1 [hwtk::frame $retainer_methods_frm.retainer_methods_frm1 ];
	pack $retainer_methods_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set retainer_methods_frm2 [hwtk::frame $retainer_methods_frm.retainer_methods_frm2 ];
	pack $retainer_methods_frm2 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	#----------------------------------------------------------------------------------------------
	set ::retainer::retainer_radiobtn_methods 1;
	set radioBtn3 [hwtk::radiobutton $retainer_methods_frm1.radioBtn3 -text "Option - 1" -width 14 -variable ::retainer::retainer_radiobtn_methods\
	-value 1 -command "::retainer::rad_MethodBtn_callback option_1 $sub_frm1"]
	pack $radioBtn3 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn4 [hwtk::radiobutton $retainer_methods_frm1.radioBtn4 -text "Option - 2" -width 14 -variable ::retainer::retainer_radiobtn_methods\
	-value 2 -command "::retainer::rad_MethodBtn_callback option_2 $sub_frm1"]
	pack $radioBtn4 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set skoda_retainer_radioBtn [hwtk::radiobutton $retainer_methods_frm2.skoda_retainer_radioBtn -text "Skoda" -width 14 -variable ::retainer::retainer_radiobtn_methods\
	-value 3 -command "::retainer::rad_MethodBtn_callback Skoda $sub_frm1" -help "Skoda connections for PamCrash" -state disabled]
	pack $skoda_retainer_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set audi_retainer_radioBtn [hwtk::radiobutton $retainer_methods_frm2.audi_retainer_radioBtn -text "Audi" -width 14 -variable ::retainer::retainer_radiobtn_methods\
	-value 4 -command "::retainer::rad_MethodBtn_callback Audi $sub_frm1" -state disabled]
	pack $audi_retainer_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	if {$::connector::profile == "pamcrash2g"} {
		$skoda_retainer_radioBtn config -state normal;
		#$surf_weld_audi_chkBtn config -state normal;
	}
	
	variable sandwich_chkBox;
	$sandwich_chkBox config -state disabled;
					
	set ::connector::flag_doghouse 1;
	set ::connector::flag_weldCirc 0;
	set ::connector::flag_weldRibs 0;
	set ::connector::flag_surfWeld 0;	
	set ::connector::flag_screw 0;	
	set ::connector::flag_clip 0;
	
	set ::connector::retainer_Help_GUI_Flag 1;
	
	::connector::changeBtnBordingColor "doghouse"
	::connection::help::displayDogHouseImage $sub_frm1

}

proc ::connector::createSurfaceWeldOptionGUI {sub_frm1} {
	
	variable label_mainFrm;
	variable surfWeld_frm;
	
	set ::connector::profile [hm_info templatetype];

	::connector::destroyFrames;
	
	set surfWeld_frm [hwtk::frame $label_mainFrm.surfWeld_frm ];
	pack $surfWeld_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	::connector::createElementType_and_JointLength_GUI "surfaceWeld";
	::connector::createFaceNormal_and_JointOnSlave_GUI;
	::connector::createExecuteButton;
		
	variable deleteBtn_frm;	
	$deleteBtn_frm config -state normal;
	
	variable sandwich_chkBox;
	$sandwich_chkBox config -state disabled;
	
	#----------------------------------------------------------------------------------------------
	set surfWeld_methods_frm [hwtk::labelframe $surfWeld_frm.surfWeld_methods_frm -text "Methods" -labelanchor nw -padding 4];
	pack $surfWeld_methods_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	set surfaceWeld_methods_frm1 [hwtk::frame $surfWeld_methods_frm.surfaceWeld_methods_frm1 ];
	pack $surfaceWeld_methods_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set ::connector::surfWeld_skoda_methods 0;
	set surf_weld_skoda_chkBtn [hwtk::checkbutton $surfaceWeld_methods_frm1.surf_weld_skoda_chkBtn  -text "Skoda" -variable ::connector::surfWeld_skoda_methods \
				-width 14 -command "::surfaceWeld::checkBox_MethodBtn_callback skoda $sub_frm1" -help "Skoda connections for PamCrash" -state disabled]
	pack $surf_weld_skoda_chkBtn -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;
	
	set ::connector::surfWeld_audi_methods 0;
	set surf_weld_audi_chkBtn [hwtk::checkbutton $surfaceWeld_methods_frm1.surf_weld_audi_chkBtn  -text "Audi" -variable ::connector::surfWeld_audi_methods \
					-width 14 -command "::surfaceWeld::checkBox_MethodBtn_callback audi $sub_frm1" -help "Audi connections" -state disabled]
	pack $surf_weld_audi_chkBtn -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;
	
	if {$::connector::profile == "pamcrash2g"} {
		$surf_weld_skoda_chkBtn config -state normal;
		#$surf_weld_audi_chkBtn config -state normal;
	}
	#----------------------------------------------------------------------------------------------
		
	set ::connector::flag_doghouse 0;
	set ::connector::flag_weldCirc 0;
	set ::connector::flag_weldRibs 0;
	set ::connector::flag_surfWeld 1;	
	set ::connector::flag_screw 0;
	set ::connector::flag_clip 0;
	
	set ::connector::surface_Help_GUI_Flag 1;
	::connector::changeBtnBordingColor "surfaceWeld"
	::connection::help::displaySurfaceWeldImage $sub_frm1
}


proc ::connector::createScrewOptionGUI {sub_frm1} {
	
	variable label_mainFrm;
	variable screw_frm;	
	
	::connector::destroyFrames;
	
	set screw_frm [hwtk::frame $label_mainFrm.screw_frm ];
	pack $screw_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set screw_washer_frm [hwtk::labelframe $screw_frm.screw_washer_frm -text "Washers" -labelanchor nw -padding 4];
	pack $screw_washer_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set screw_mat_frm [hwtk::labelframe $screw_frm.screw_mat_frm -text "Materials" -labelanchor nw -padding 4];
	pack $screw_mat_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set screw_methods_frm [hwtk::labelframe $screw_frm.screw_methods_frm -text "Methods" -labelanchor nw -padding 4];
	pack $screw_methods_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set screw_methods_frm1 [hwtk::frame $screw_methods_frm.screw_methods_frm1 ];
	pack $screw_methods_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set screw_methods_frm2 [hwtk::frame $screw_methods_frm.screw_methods_frm2 ];
	pack $screw_methods_frm2 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set screw_methods_frm3 [hwtk::frame $screw_methods_frm.screw_methods_frm3 ];
	pack $screw_methods_frm3 -side top -expand false -pady 4 -padx 4 -anchor nw;
					
	::connector::createElementType_and_JointLength_GUI "screw";
	::connector::createFaceNormal_and_JointOnSlave_GUI;
	::connector::createElementLayerComboBtn "Boss Element Layers";
	::connector::createExecuteButton;
		
	variable deleteBtn_frm;	
	$deleteBtn_frm config -state normal;
	
	#----------------------------------------------------------------------------------------------
	variable screw_washer_radioBtn1;
	variable screw_washer_radioBtn2;
	set ::connector::screw_radiobtn_washer 1;
	set screw_washer_radioBtn1 [hwtk::radiobutton $screw_washer_frm.screw_washer_radioBtn1 -text "0-Layer" -width 14 -variable ::connector::screw_radiobtn_washer\
	-value 1 -command "::screw::rad_WasherBtn_callback zerolayer"]
	pack $screw_washer_radioBtn1 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set screw_washer_radioBtn2 [hwtk::radiobutton $screw_washer_frm.screw_washer_radioBtn2 -text "1-Layer" -width 14 -variable ::connector::screw_radiobtn_washer\
	-value 2 -command "::screw::rad_WasherBtn_callback onelayer"]
	pack $screw_washer_radioBtn2 -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------
	
	#----------------------------------------------------------------------------------------------
	set ::connector::screw_radiobtn_material 1;
	set radioBtn1 [hwtk::radiobutton $screw_mat_frm.radioBtn1 -text "Plastic - Plastic" -width 14 -variable ::connector::screw_radiobtn_material\
	-value 1 -command "::screw::rad_MaterialBtn_callback plastic_plastic"]
	pack $radioBtn1 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn2 [hwtk::radiobutton $screw_mat_frm.radioBtn2 -text "Plastic - BIW" -width 14 -variable ::connector::screw_radiobtn_material\
	-value 2 -command "::screw::rad_MaterialBtn_callback plastic_biw" -state disabled]
	pack $radioBtn2 -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------
	
	#----------------------------------------------------------------------------------------------
	set ::connector::screw_radiobtn_methods 1;
	set radioBtn3 [hwtk::radiobutton $screw_methods_frm1.radioBtn3 -text "R - B - R" -width 14 -variable ::connector::screw_radiobtn_methods\
	-value 1 -command "::screw::rad_MethodBtn_callback r_b_r $sub_frm1"]
	pack $radioBtn3 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn4 [hwtk::radiobutton $screw_methods_frm1.radioBtn4 -text "Rigid Patch" -width 14 -variable ::connector::screw_radiobtn_methods\
	-value 2 -command "::screw::rad_MethodBtn_callback rigid_patch $sub_frm1"]
	pack $radioBtn4 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable screw_skoda_radioBtn;
	set screw_skoda_radioBtn [hwtk::radiobutton $screw_methods_frm2.screw_skoda_radioBtn -text "Skoda" -width 14 -variable ::connector::screw_radiobtn_methods\
	-value 3 -command "::screw::rad_MethodBtn_callback Skoda $sub_frm1" -help "Skoda connections for PamCrash" -state disabled]
	pack $screw_skoda_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set radioBtn6 [hwtk::radiobutton $screw_methods_frm2.radioBtn6 -text "Audi" -width 14 -variable ::connector::screw_radiobtn_methods\
	-value 4 -command "::screw::rad_MethodBtn_callback Audi $sub_frm1" -state disabled]
	pack $radioBtn6 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	variable collar_screw_radioBtn;
	set collar_screw_radioBtn [hwtk::radiobutton $screw_methods_frm3.collar_screw_radioBtn -text "Collar" -width 14 -variable ::connector::screw_radiobtn_methods\
	-value 5 -command "::screw::rad_MethodBtn_callback collar $sub_frm1" -state normal]
	pack $collar_screw_radioBtn -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	#----------------------------------------------------------------------------------------------
	if {$::connector::profile == "pamcrash2g"} {
		$screw_skoda_radioBtn config -state normal;
		#$clip_weld_audi_chkBtn config -state normal;
	}
			
	set ::connector::flag_doghouse 0;
	set ::connector::flag_weldCirc 0;
	set ::connector::flag_weldRibs 0;
	set ::connector::flag_surfWeld 0;	
	set ::connector::flag_screw 1;
	set ::connector::flag_clip 0;
	
	set ::connector::screw_Help_GUI_Flag 1;
	::connector::changeBtnBordingColor "screw"
	::connection::help::displayScrewImage $sub_frm1
	
}

proc ::connector::createClipOptionGUI {sub_frm1} {
	
	variable label_mainFrm;
	variable clip_frm;
			
	::connector::destroyFrames;

	set clip_frm [hwtk::frame $label_mainFrm.clip_frm ];
	pack $clip_frm -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set clip_type_frm [hwtk::labelframe $clip_frm.clip_type_frm -text "Types" -labelanchor nw -padding 4];
	pack $clip_type_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	set clip_type_frm1 [hwtk::frame $clip_type_frm.clip_type_frm1 ];
	pack $clip_type_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	
	set clip_options_frm [hwtk::labelframe $clip_frm.clip_options_frm -text "Options" -labelanchor nw -padding 4];
	pack $clip_options_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	set clip_options_frm1 [hwtk::frame $clip_options_frm.clip_options_frm1 ];
	pack $clip_options_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	set clip_options_frm2 [hwtk::frame $clip_options_frm.clip_options_frm2 ];
	pack $clip_options_frm2 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	
	#----------------------------------------------------------------------------------------------
	set clip_methods_frm [hwtk::labelframe $clip_frm.clip_methods_frm -text "Methods" -labelanchor nw -padding 4];
	pack $clip_methods_frm -side top -expand false -padx 4 -pady 4 -anchor nw;
	set clip_methods_frm1 [hwtk::frame $clip_methods_frm.clip_methods_frm1 ];
	pack $clip_methods_frm1 -side top -expand false -pady 4 -padx 4 -anchor nw;
	
	set ::connector::clip_skoda_methods 0;
	set clip_weld_skoda_chkBtn [hwtk::checkbutton $clip_methods_frm1.clip_weld_skoda_chkBtn  -text "Skoda" -variable ::connector::clip_skoda_methods \
				-width 14 -command "::clips::checkBox_MethodBtn_callback skoda $sub_frm1" -help "Skoda connections for PamCrash" -state disabled]
	pack $clip_weld_skoda_chkBtn -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;
	
	set ::connector::clip_audi_methods 0;
	set clip_weld_audi_chkBtn [hwtk::checkbutton $clip_methods_frm1.clip_weld_audi_chkBtn  -text "Audi" -variable ::connector::clip_audi_methods \
					-width 14 -command "::clips::checkBox_MethodBtn_callback audi $sub_frm1" -help "Audi connections" -state disabled]
	pack $clip_weld_audi_chkBtn -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;
	
	if {$::connector::profile == "pamcrash2g"} {
		$clip_weld_skoda_chkBtn config -state normal;
		#$clip_weld_audi_chkBtn config -state normal;
	}
	#----------------------------------------------------------------------------------------------
	
	
	::connector::createElementType_and_JointLength_GUI "clips";
	::connector::createFaceNormal_and_JointOnSlave_GUI;
	::connector::createElementLayerComboBtn "Clip Tower Layer";
	::connector::createExecuteButton;
	
	variable deleteBtn_frm;	
	$deleteBtn_frm config -state normal;
	
	variable sandwich_chkBox;
	$sandwich_chkBox config -state disabled;
		
	#----------------------------------------------------------------------------------------------
	set ::connector::clip_radiobtn_options 1;
	set clip_radioBtn1 [hwtk::radiobutton $clip_options_frm1.clip_radioBtn1 -text "Option - 1 " -width 14 -variable ::connector::clip_radiobtn_options\
	-value 1 -command "::clips::Clip_radBtnOptions option1 $sub_frm1"]
	pack $clip_radioBtn1 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set clip_radioBtn2 [hwtk::radiobutton $clip_options_frm1.clip_radioBtn2 -text "Option - 2" -width 14 -variable ::connector::clip_radiobtn_options\
	-value 2 -command "::clips::Clip_radBtnOptions option2 $sub_frm1"]
	pack $clip_radioBtn2 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set clip_radioBtn3 [hwtk::radiobutton $clip_options_frm2.clip_radioBtn3 -text "Option - 3" -width 14 -variable ::connector::clip_radiobtn_options\
	-value 3 -command "::clips::Clip_radBtnOptions option3 $sub_frm1"]
	pack $clip_radioBtn3 -side left -expand false -pady 4 -padx 4 -anchor nw;
	#----------------------------------------------------------------------------------------------	
	
	set ::connector::clip_radiobtn_type 1;
	set cliptype_radioBtn1 [hwtk::radiobutton $clip_type_frm1.cliptype_radioBtn1 -text "Metal Clips" -width 14 -variable ::connector::clip_radiobtn_type\
	-value 1 -command "::clips::Clip_radBtnTypes metal $sub_frm1 $clip_radioBtn1 $clip_radioBtn2 $clip_radioBtn3"]
	pack $cliptype_radioBtn1 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	set ::connector::clip_radiobtn_type 1;
	set cliptype_radioBtn2 [hwtk::radiobutton $clip_type_frm1.cliptype_radioBtn2 -text "Plastic Clips" -width 14 -variable ::connector::clip_radiobtn_type\
	-value 2 -command "::clips::Clip_radBtnTypes plastic $sub_frm1 $clip_radioBtn1 $clip_radioBtn2 $clip_radioBtn3"]
	pack $cliptype_radioBtn2 -side left -expand false -pady 4 -padx 4 -anchor nw;
	
	#----------------------------------------------------------------------------------------------
	
	set ::connector::flag_doghouse 0;
	set ::connector::flag_weldCirc 0;
	set ::connector::flag_weldRibs 0;
	set ::connector::flag_surfWeld 0;
	set ::connector::flag_screw 0;
	set ::connector::flag_clip 1;
	
	set ::connector::Clip_Help_GUI_Flag 1;
	::connector::changeBtnBordingColor "clip"
	::connection::help::displayClipImage $sub_frm1


}

proc ::connector::createElementType_and_JointLength_GUI {connectionType} {
	
	variable connection_type_level2_2_frm;
	variable elemType_joint_lng_frm;
	
	catch {destroy $connection_type_level2_2_frm.elemType_joint_lng_frm}
		
	set ::connector::profile [hm_info templatetype];
	if {$::connector::profile == "pamcrash2g"} {
		set ::connector::pArr(beamtypelist) [list "Rigids" "Mtoco"];	
	} elseif {$::connector::profile == "abaqus"} {
		set ::connector::pArr(beamtypelist) [list "Coup_Kin"];	
	} else {
		#ls dyna
		set ::connector::pArr(beamtypelist) [list "Rigids" "Beams"];
	}
	set ::connector::pArr(beamType) [lindex $::connector::pArr(beamtypelist) 0];
			
	set elemType_joint_lng_frm [hwtk::frame $connection_type_level2_2_frm.elemType_joint_lng_frm ];
	pack $elemType_joint_lng_frm -side left -expand false -pady 4 -padx 4 -anchor nw;	
	
	set dEntType_label [hwtk::label $elemType_joint_lng_frm.dEntType_label -text "Element Type" -width 12];
	pack $dEntType_label -side left -expand true -pady 4 -padx 4;

	set dEntType [hwtk::editablecombobox $elemType_joint_lng_frm.dEntType -state readonly -width 10 -values [set ::connector::pArr(beamtypelist)] \
					 -default $::connector::pArr(beamType) -textvariable ::connector::pArr(beamType)];
	pack $dEntType -side left -expand true -pady 4 -padx 4;
		
	#set ::connector::joint_length "5.0";
	set joint_lgn_label [hwtk::label $elemType_joint_lng_frm.joint_lgn_label -text "Joint Length" -width 10];
	pack $joint_lgn_label -side left -expand true -pady 4 -padx 4;	
	set joing_lng_entry [hwtk::entry $elemType_joint_lng_frm.joing_lng_entry -textvariable "$::connector::joint_length" -width 10 \
			-textvariable ::connector::joint_length];
	pack $joing_lng_entry -side left -expand false -pady 4 -padx 4 -anchor nw;	

}

proc ::connector::createFaceNormal_and_JointOnSlave_GUI {} {
	
	variable sandwich_frm;
	variable slaveJoint_frm;
	
	catch {destroy $sandwich_frm.dummyFrm};
	
	set tempSolver [hm_info templatetype]
	
	set ::connector::normal_flag 0;
	
	set dummyFrm [hwtk::frame $sandwich_frm.dummyFrm ];
	pack $dummyFrm -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;	
	
	variable sandwich_chkBox;
	set ::connector::sandwichConnection_flag 0;
	set sandwich_chkBox [hwtk::checkbutton $dummyFrm.sandwich_chkBox  -text "Sandwich" -variable ::connector::sandwichConnection_flag \
					-width 14 -help "Create Sandwich connections"  -state normal -command ::connector::Sandwich_callback]
	pack $sandwich_chkBox -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;
		
	set ::connector::slave_joint_flag 0
	set slaveJoint_frm [hwtk::checkbutton $dummyFrm.slaveJoint_frm -text "Joint On Slave" -variable ::connector::slave_joint_flag \
				-width 14 -help "Support only Pamcrash" -state disabled]
	pack $slaveJoint_frm -side left -expand true -fill both -pady 4 -padx 4 -anchor nw;	
	
	if {$tempSolver == "pamcrash2g"} {
		$slaveJoint_frm config -state normal;
		$sandwich_chkBox config -state disabled;
	}

}


proc ::connector::Sandwich_callback {} {
	
	variable collar_usweld_radioBtn;
	variable collar_screw_radioBtn;
	variable skoda_usweld_radioBtn;
	variable screw_skoda_radioBtn;
	variable duplicateVar_sub_frm1;
			
	if {$::connector::flag_weldCirc == 1} {
		::usweld::SandwichWeld $collar_usweld_radioBtn $skoda_usweld_radioBtn $duplicateVar_sub_frm1;
	}
	if {$::connector::flag_screw == 1} {
		::screw::SandwichWeld $collar_screw_radioBtn $screw_skoda_radioBtn $duplicateVar_sub_frm1;
	}

}

proc ::connector::changeBtnBordingColor {btnName} {
	#this is to highlight button border frame color. User will identify which button is active
	
	variable dog_house_color_frm;
	variable weld_cir_color_frm;
	variable surf_weld_color_frm;
	variable rib_weld_color_frm;
	variable screw_color_frm;
	variable clip_color_frm;
	
	#reset color to normal
	$dog_house_color_frm configure -background "#F1F1F1"
	$weld_cir_color_frm configure -background "#F1F1F1"
	$surf_weld_color_frm configure -background "#F1F1F1"
	$rib_weld_color_frm configure -background "#F1F1F1"
	$screw_color_frm configure -background "#F1F1F1"
	$clip_color_frm configure -background "#F1F1F1"
	
	set color darkblue;
	if {$btnName == "doghouse"} {
		$dog_house_color_frm configure -background $color;
	}
	if {$btnName == "weldCir"} {
		$weld_cir_color_frm configure -background $color;
	}
	if {$btnName == "surfaceWeld"} {
		$surf_weld_color_frm configure -background $color;
	}
	if {$btnName == "ribWeld"} {
		$rib_weld_color_frm configure -background $color;
	}
	if {$btnName == "screw"} {
		$screw_color_frm configure -background $color;
	}
	if {$btnName == "clip"} {
		$clip_color_frm configure -background $color;
	}
}


proc ::connector::destroyFrames {} {

	variable dogHouse_labelFrm1;
	catch {destroy $dogHouse_labelFrm1}
	variable dogHouseExt_labelFrm1;
	catch {destroy $dogHouseExt_labelFrm1}
	variable screw_frm;
	catch {destroy $screw_frm};
	variable clip_frm;
	catch {destroy $clip_frm}
	variable usweld_frm;
	catch {destroy $usweld_frm}
	variable elem_layer_frm;
	catch {destroy $elem_layer_frm}
	variable surfWeld_frm;
	catch {destroy $surfWeld_frm}
	variable ribweld_frm
	catch {destroy $ribweld_frm}
}


proc ::connector::openHelp {} {
	
	set helpDocPath [file join $::connector::scriptDir ConnectorModelling_Help.pdf];
	if {[file exists $helpDocPath]} {
		eval exec [auto_execok start] $helpDocPath
	} else {
		tk_messageBox -message "Help does not exists in installation directory.\
		Kindly confirm and try launching help" -icon info
	}
}


proc ::connector::exec_reviewRecentConnection {} {

	if {![info exists ::connector::recentlyCreatedEntity]} {
		return;
	}
	
	if {$::connector::reviewConnection_flag == 1 } {
	
		*createmark sets 1 "temp_review_connection_set"
		catch {*deletemark sets 1}
		
		set setId [::antolin::connection::utils::createSet "temp_review_connection_set"];
		#add entity to sets 
		*setvalue sets id=$setId ids={elems $::connector::recentlyCreatedEntity};
		#*settopologydisplaymode 0
		#*createmark sets 2 "temp_review_connection_set"
		#*reviewentitybymark 2 0 1 0;
		*reviewentity sets "by id" $setId 8 1 1;
		
	} else {
	
		*resetreview;
		*createmark sets 1 "temp_review_connection_set"
		catch {*deletemark sets 1}
	}
}

proc ::connector::createConnections {} {
	
	variable execute_btn;
	
	if {[string trim [set ::connector::vehicle_program_name]] == ""} {
		tk_messageBox -message "Kindly enter \"valid vehicle program name\" to proceed...!" -icon error;
		return;
	}
		
	#disable execute button to avoid unnessary clicks
	$execute_btn config -state disabled;
	
	#reset review
	set ::connector::reviewConnection_flag 0;
	::connector::exec_reviewRecentConnection;
	
	if {$::connector::flag_doghouse == 1} {
		set retainerHelpImage [file join $::connector::scriptDir icons retainer_selection.png];
		set message "Select node as shown in image"
		
		if {$::connector::retainer_Help_GUI_Flag<=2} {
			#pop up message for 2 times only
			::popUpImages::createExecHelpPopUp $message $retainerHelpImage;
		}
		::retainer::exec_retainers_main;
		incr ::connector::retainer_Help_GUI_Flag;
	}
	
	if {$::connector::flag_weldCirc == 1} {
	
		# ::connector::weld_master;
		if {$::connector::usweld_radiobtn_methods == 5} {
			set weldcircHelpImage [file join $::connector::scriptDir icons Weld_Circ_collar_selection.png];
			set message "Select \"Single Edge\" on a hole"
		} else {
			set weldcircHelpImage [file join $::connector::scriptDir icons weld_circ_selection.png];
			set message "Select \"Edge Node(s)\" on hole"
		}
		
		if {$::connector::usweld_Help_GUI_Flag<=2} {
			#pop up message for 2 times only
			::popUpImages::createExecHelpPopUp $message $weldcircHelpImage;
		}
		
		::usweld::exec_uswelds_main;
		incr ::connector::usweld_Help_GUI_Flag;
	}
	if {$::connector::flag_weldRibs == 1} {
		set ribWeldHelpImage [file join $::connector::scriptDir icons ribWeld_selection.png];
		set message "Select node(s) on Ribs"
		
		if {$::connector::ribweld_Help_GUI_Flag<=2} {
			#pop up message for 2 times only
			::popUpImages::createExecHelpPopUp $message $ribWeldHelpImage;
		}
		
		::ribweld::exec_rib_welds_main;
		incr ::connector::ribweld_Help_GUI_Flag;
	}
	
	if {$::connector::flag_surfWeld == 1} {
		
		set surfaceWeldHelpImage [file join $::connector::scriptDir icons surfWeld_selection.png];
		set message "Select \"Middle Node(s)\" on surface welds"
		
		if {$::connector::surface_Help_GUI_Flag<=2} {
			#pop up message for 2 times only
			::popUpImages::createExecHelpPopUp $message $surfaceWeldHelpImage;
		}
		::surfaceWeld::exec_surfaceWeld;
		incr ::connector::surface_Help_GUI_Flag;
	}
	
	if {$::connector::flag_screw == 1} {
	
		set screwHelpImage [file join $::connector::scriptDir icons screw_selection.png];
		set message "Select \"Edge Node(s)\" on hole"
		
		if {$::connector::screw_Help_GUI_Flag<=2} {
			#pop up message for 2 times only
			::popUpImages::createExecHelpPopUp $message $screwHelpImage;
		}
		::screw::exec_screws_main;
		incr ::connector::screw_Help_GUI_Flag;
	}
	
	if {$::connector::flag_clip == 1} {
		
		if {$::connector::clip_radiobtn_type == 1} {
			set clipHelpImage [file join $::connector::scriptDir icons metalClip_selection.png];
			set message "Select \"Center Node On Edge\" of metal clip tower"
		} else {
			set clipHelpImage [file join $::connector::scriptDir icons plasticClip_selection.png];
			set message "Select any node on center slot of plastic clip tower"
		}
		
		if {$::connector::Clip_Help_GUI_Flag<=2} {
			#pop up message for 2 times only
			::popUpImages::createExecHelpPopUp $message $clipHelpImage;
		}
		
		::clips::exec_clip_main;
		
		incr ::connector::Clip_Help_GUI_Flag;
	}
	
	$execute_btn config -state normal;
}

proc ::connector::log_files_write {  } {
				
	set log_name log_file_$::connector::file_open_start_time 
	set formattext ".txt"	
	set log_file_head [open $::CustomConnectors::log_filepath_antolin a];
	puts $log_file_head "Program Name : ----- $::connector::vehicle_program_name ----- ";
	foreach linevalue $::connector::connection_log_var {
		puts $log_file_head "\[[clock format [clock seconds] -format %D::%H:%M:%S]\]Info : $linevalue";
	
	}
	puts $log_file_head "";
	close $log_file_head
	
}
					
proc ::connector::antolin_main_fun {subfram} {
	::connector::gui_load $subfram;
}


