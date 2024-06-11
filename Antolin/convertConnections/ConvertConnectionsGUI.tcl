catch {namespace delete ::convertGUI}

namespace eval ::convertGUI {
	set ::convertGUI::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::convertGUI::scriptDir ConvertConnections.tbc]]} {
		source [file join $::convertGUI::scriptDir ConvertConnections.tbc];
	} else {
		source [file join $::convertGUI::scriptDir ConvertConnections.tcl];
	}
	if {[file exists [file join $::convertGUI::scriptDir RemoveFreeNodes_rigids.tbc]]} {
		source [file join $::convertGUI::scriptDir RemoveFreeNodes_rigids.tbc];
	} else {
		source [file join $::convertGUI::scriptDir RemoveFreeNodes_rigids.tcl];
	}
}


proc ::convertGUI::createConversionGUI { convert_frm } {

	set ::connector::file_open_start_time [clock seconds];
	
	if {![info exists ::connector::vehicle_program_name]} {
		set ::connector::vehicle_program_name "";
	}
	
	set label_mainFrm [hwtk::labelframe $convert_frm.label_mainFrm -text "Convert Connections" -labelanchor nw ];
	pack $label_mainFrm -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set frm_level1 [hwtk::frame $label_mainFrm.frm_level1 ];
	pack $frm_level1 -side top -expand false -pady 4 -padx 4 -anchor nw;	
	
	set frm_level2 [hwtk::frame $label_mainFrm.frm_level2 ];
	pack $frm_level2 -side top -expand false -pady 4 -padx 4 -anchor ne;
	
	set convertFrom_label [hwtk::label $frm_level1.convertFrom_label -text "From:" ];
	pack $convertFrom_label -side left -expand true -pady 4 -padx 4;
		
	set ::convertGUI::parentElement_list [list "Rigid-Beam-Rigid" "COUP_KIN"];
	set ::convertGUI::str_parrentElement [lindex $::convertGUI::parentElement_list 0];
	set frm_from [hwtk::editablecombobox $frm_level1.frm_from -state readonly -width 16 -values [set ::convertGUI::parentElement_list] \
					 -default $::convertGUI::str_parrentElement -textvariable ::convertGUI::str_parrentElement -selcommand ::convertGUI::updateDropDown];
	pack $frm_from -side left -expand true -pady 4 -padx 4;
	
	set convertTo_label [hwtk::label $frm_level1.convertTo_label -text "To:"];
	pack $convertTo_label -side left -expand true -pady 4 -padx 4;
	
	
	set ::convertGUI::convertedElement_list [list "Rigid"];
	set ::convertGUI::str_convertElem [lindex $::convertGUI::convertedElement_list 0];
	
	variable frm_to;
	set frm_to [hwtk::editablecombobox $frm_level1.frm_to -state readonly -width 16 -values [set ::convertGUI::convertedElement_list] \
					 -default $::convertGUI::str_convertElem -textvariable ::convertGUI::str_convertElem];
	pack $frm_to -side left -expand true -pady 4 -padx 4;
		
	set apply_btn  [hwtk::button $frm_level2.apply_btn -text "Execute" -command "::convert::ExecuteConnectionConvert" -width 14];
	pack $apply_btn -side left -expand false -pady 4 -padx 4 -anchor ne;	

}

proc ::convertGUI::updateDropDown {} {

	variable frm_to;
	
	if {$::convertGUI::str_parrentElement == "Rigid-Beam-Rigid"} {
		set ::convertGUI::convertedElement_list [list "Rigid"];
	} elseif {$::convertGUI::str_parrentElement == "COUP_KIN"} {
		set ::convertGUI::convertedElement_list [list "B31" "Rigid_BEAM"];
	}
	
	$frm_to config  -values [set ::convertGUI::convertedElement_list];
	set ::convertGUI::str_convertElem [lindex $::convertGUI::convertedElement_list 0];

}

proc ::convertGUI::createFreeRigidNodeGUI {rigid_frm} {

	set rigidLabel_mainFrm [hwtk::labelframe $rigid_frm.rigidLabel_mainFrm -text "Remove free node(s) of Rigids" -labelanchor nw -width 100];
	pack $rigidLabel_mainFrm -side top -expand true -padx 4 -pady 4 -fill x -anchor nw;
	
	set frm_level1 [hwtk::frame $rigidLabel_mainFrm.frm_level1 ];
	pack $frm_level1 -side top -expand false -pady 4 -padx 4 -fill x -anchor nw;	
	
	set apply_btn  [hwtk::button $frm_level1.apply_btn -text "Execute" -command "::freeNode::removeFree1DNodes" -width 15];
	pack $apply_btn -side left -expand false -pady 4 -padx 4 -anchor ne;
}

proc ::convertGUI::antolin_main_fun {subfram} {	
	
	set convert_frm [hwtk::frame $subfram.convert_frm ];
	pack $convert_frm -side top -expand true -fill x -pady 4 -padx 4 -anchor nw;
	
	set separator_frm [hwtk::label $subfram.separator_frm -text "--------------------------------------------------------------------------------------------------"];
	pack $separator_frm -side top -expand true -fill x -pady 4 -padx 4;	
	
	set rididNode_frm [hwtk::frame $subfram.rididNode_frm ];
	pack $rididNode_frm -side top -expand true -fill x -pady 4 -padx 4 -anchor nw;
	
	::convertGUI::createConversionGUI $convert_frm;
	::convertGUI::createFreeRigidNodeGUI $rididNode_frm;
}

