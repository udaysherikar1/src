catch {namespace delete ::connection::help}

namespace eval ::connection::help {
	set ::connector::scriptDir [file dirname [info script]];
}

proc ::connection::help::destroyImageFrame {} {

	variable helpImages_top;
	
	catch {destroy $helpImages_top};
}

proc ::connection::help::createHelpFrm {sub_frm1} {

	variable helpImages_top;
	
	set helpImages_top [hwtk::labelframe $sub_frm1.helpImages_top -text "Help Images" -labelanchor nw -padding 4];
	pack $helpImages_top -side top -expand false -padx 4 -pady 4 -anchor nw;
	
	set help_image [hwtk::frame $helpImages_top.help_image];
	pack $help_image -side top -expand true -fill both -pady 4 -padx 4 -anchor ne;
	
	return $help_image
}

proc ::connection::help::displayDogHouseImage {sub_frm1} {
	
	::connection::help::destroyImageFrame;
	
	if {$::retainer::retainer_radiobtn_methods == 1 } {
		set dog_house_image [file join $::connector::scriptDir icons Retainer_option_1.png];
	} elseif {$::retainer::retainer_radiobtn_methods == 2 } {
		set dog_house_image [file join $::connector::scriptDir icons Retainer_option_2.png];
	} else {
		set dog_house_image [file join $::connector::scriptDir icons Retainer_skoda.png];
	}
	
	set help_image [::connection::help::createHelpFrm $sub_frm1];
	pack [hwtk::label $help_image.picture -image $dog_house_image ] -side top -padx 4 -pady 2;
	
}

proc ::connection::help::displayWeldCircularImage {sub_frm1} {

	::connection::help::destroyImageFrame;
		
	if {$::connector::usweld_radiobtn_methods == 1 } {
		#r-b-r
		set weld_Circ_image [file join $::connector::scriptDir icons Weld_Circ_r_b_r_.png];
	} elseif {$::connector::usweld_radiobtn_methods == 2 } {
		#RP
		set weld_Circ_image [file join $::connector::scriptDir icons Weld_Circ_RP.png];
	} elseif {$::connector::usweld_radiobtn_methods == 5 } {
		#collar
		set weld_Circ_image [file join $::connector::scriptDir icons Weld_Circ_collar.png];
	} else {
		#skoda
		set weld_Circ_image [file join $::connector::scriptDir icons Weld_Circ_Pam_Skoda.png];
	}
	
	if {$::connector::sandwichConnection_flag == 1 && $::connector::usweld_radiobtn_methods == 1} {
		#sandwich connection image for R-B-R
		set weld_Circ_image [file join $::connector::scriptDir icons Weld_Circ_sandwich_1.png];
	}
	if {$::connector::sandwichConnection_flag == 1 && $::connector::usweld_radiobtn_methods == 2} {
		#sandwich connection image for RP
		set weld_Circ_image [file join $::connector::scriptDir icons Weld_Circ_sandwich_2.png];
	}
	
	set help_image [::connection::help::createHelpFrm $sub_frm1];
	pack [hwtk::label $help_image.picture -image $weld_Circ_image ] -side top -padx 4 -pady 2;

}

proc ::connection::help::displayWeldRibImage {sub_frm1} {
	::connection::help::destroyImageFrame;
		
	if {$::connector::ribweld_radiobtn_methods == 1} {
		set weld_rib_image [file join $::connector::scriptDir icons rib_weld_r_b_r.png];
	}
	if {$::connector::ribweld_radiobtn_methods == 2} {
		set weld_rib_image [file join $::connector::scriptDir icons rib_weld_RP.png];
	}
	if {$::connector::ribweld_radiobtn_methods == 3} {
		#skoda
		set weld_rib_image [file join $::connector::scriptDir icons rib_weld_skoda.png];
	}
	
	
	set help_image [::connection::help::createHelpFrm $sub_frm1];
	pack [hwtk::label $help_image.picture -image $weld_rib_image ] -side top -padx 4 -pady 2;
}

proc ::connection::help::displaySurfaceWeldImage {sub_frm1} {
	::connection::help::destroyImageFrame;
	
	set tempSolver [hm_info templatetype];
	
	if { $::connector::surfWeld_skoda_methods == 1} {
		set surf_weld_image [file join $::connector::scriptDir icons surface_weld_skoda.png];
	} else {
		set surf_weld_image [file join $::connector::scriptDir icons surface_weld.png];
	}
	
	set help_image [::connection::help::createHelpFrm $sub_frm1];
	pack [hwtk::label $help_image.picture -image $surf_weld_image ] -side top -padx 4 -pady 2;


}

proc ::connection::help::displayScrewImage {sub_frm1} {

	::connection::help::destroyImageFrame;
		
	if { $::connector::screw_radiobtn_methods == 1} {
		set screw_image [file join $::connector::scriptDir icons screw_r_b_r.png];
	}
	
	if { $::connector::screw_radiobtn_methods == 2} {
		set screw_image [file join $::connector::scriptDir icons screw_RP.png];
	}
	
	if { $::connector::screw_radiobtn_methods == 3} {
		set screw_image [file join $::connector::scriptDir icons screw_skoda.png];
	}
	
	if { $::connector::screw_radiobtn_methods == 5} {
		set screw_image [file join $::connector::scriptDir icons screw_collar.png];
	}
	
	
	if {$::connector::sandwichConnection_flag == 1 && $::connector::screw_radiobtn_methods == 1} {
		#sandwich connection image for R-B-R
		set screw_image [file join $::connector::scriptDir icons screw_sandwich_1.png];
	}
	if {$::connector::sandwichConnection_flag == 1 && $::connector::screw_radiobtn_methods == 2} {
		#sandwich connection image for RP
		set screw_image [file join $::connector::scriptDir icons screw_sandwich_2.png];
	}
	
	set help_image [::connection::help::createHelpFrm $sub_frm1];
	pack [hwtk::label $help_image.picture -image $screw_image ] -side top -padx 4 -pady 2;

}

proc ::connection::help::displayClipImage {sub_frm1} {

	::connection::help::destroyImageFrame;
	
	#metal clip images
	if {$::connector::clip_radiobtn_type == 1 && $::connector::clip_radiobtn_options == 1} {
		set clip_image [file join $::connector::scriptDir icons Clips_metal_option_1.png];
	}
	if {$::connector::clip_radiobtn_type == 1 && $::connector::clip_radiobtn_options == 2} {
		set clip_image [file join $::connector::scriptDir icons Clips_metal_option_2.png];
	}
	if {$::connector::clip_radiobtn_type == 1 && $::connector::clip_radiobtn_options == 3} {
		set clip_image [file join $::connector::scriptDir icons Clips_metal_option_3.png];
	}
	#---------------------------------------------------------------------------------------
	
	if {$::connector::clip_radiobtn_type == 2 && $::connector::clip_radiobtn_options == 1} {
		set clip_image [file join $::connector::scriptDir icons Clips_plastic_option_1.png];
	}
	
	set help_image [::connection::help::createHelpFrm $sub_frm1];
	pack [hwtk::label $help_image.picture -image $clip_image ] -side top -padx 4 -pady 2;
}
