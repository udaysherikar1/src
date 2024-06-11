if {[namespace exists ::clips]} {
	namespace delete ::clips
}

namespace eval ::clips {
	set ::clips::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::clips::scriptDir clips_metals.tbc]]} {
		source [file join $::clips::scriptDir clips_metals.tbc];
	} else {
		source [file join $::clips::scriptDir clips_metals.tcl];
	}
	if {[file exists [file join $::clips::scriptDir clips_plastic.tbc]]} {
		source [file join $::clips::scriptDir clips_plastic.tbc];
	} else {
		source [file join $::clips::scriptDir clips_plastic.tcl];
	}

}

proc ::clips::Clip_radBtnOptions {arg sub_frm1} {

	if { $arg == "option1"} {
		set ::connector::clip_radiobtn_options 1;
		set ::connector::element_layers 2;
	}
	if { $arg == "option2"} {
		set ::connector::clip_radiobtn_options 2;
		set ::connector::element_layers 1;
	}
	if { $arg == "option3"} {
		set ::connector::clip_radiobtn_options 3;
		set ::connector::element_layers 1;
	}
	
	::connection::help::displayClipImage $sub_frm1;
}

proc ::clips::Clip_radBtnTypes {arg sub_frm1 clip_radioBtn1 clip_radioBtn2 clip_radioBtn3} {
	
	if { $arg == "metal"} {
		set ::connector::clip_radiobtn_type 1;
		$clip_radioBtn1 config -state normal;
		$clip_radioBtn2 config -state normal;
		$clip_radioBtn3 config -state normal;
		
		$::connector::elem_layer_frm.elem_layer_label config -state normal;
		$::connector::elem_layer_frm.elem_layer_entry config -state normal;
	}
	if { $arg == "plastic"} {
		set ::connector::clip_radiobtn_type 2;
		set ::connector::clip_radiobtn_options 1;
		$clip_radioBtn1 config -state normal;
		$clip_radioBtn2 config -state disabled;
		$clip_radioBtn3 config -state disabled;
		
		$::connector::elem_layer_frm.elem_layer_label config -state disabled;
		$::connector::elem_layer_frm.elem_layer_entry config -state disabled;
	}
	
	set ::connector::Clip_Help_GUI_Flag 1;
	::connection::help::displayClipImage $sub_frm1;
}


proc ::clips::checkBox_MethodBtn_callback {arg sub_frm1} {

	if {$::connector::clip_skoda_methods == 1} {
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state disabled;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state disabled;
		#joint on slave 
		$::connector::slaveJoint_frm config -state disabled;

		set ::connector::clip_audi_methods 0;
		#::connection::help::displayClipImage $sub_frm1
		
	} else {
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state normal;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state normal;
		#joint on slave 
		$::connector::slaveJoint_frm config -state normal;
		
		#::connection::help::displayClipImage $sub_frm1
	}
	
	if {$::connector::clip_audi_methods == 1} {
		set ::connector::clip_skoda_methods 0;
	}
}

proc ::clips::exec_clip_main {} {

	set ::clips::profile [hm_info templatetype];

	if {$::connector::slave_joint_flag == 1 && $::connector::profile != "pamcrash2g" } {
		tk_messageBox -message "\"Joint On Slave\" supported only for \"PAMCRASH\" profile" -icon error;
		return
	}
	
	set ::connector::connection_log_var  [list];
	
	::hwat::utils::BlockMessages "On"
	if {$::connector::clip_radiobtn_type == 1} {
		# metal clips
		::metal_clips::exec_metalClips_main;
	
	}
	if {$::connector::clip_radiobtn_type == 2} {
		# plastic clips
		::plastic_clips::exec_plasticClips_main;
	
	}
	::hwat::utils::BlockMessages "Off"
	::connector::log_files_write;
}

