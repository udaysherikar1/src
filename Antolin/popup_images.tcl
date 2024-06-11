catch {namespace delete ::popUpImages}

namespace eval ::popUpImages {
	set ::popUpImages::scriptDir [file dirname [info script]];
}

proc ::popUpImages::OnOK {} {
	variable popUpHelp;
	catch {destroy .popUpHelp};
}

proc ::popUpImages::createExecHelpPopUp {message imagePath} {
	
	variable popUpHelp;
	catch {destroy .popUpHelp};

	set popUpHelp [toplevel .popUpHelp];
	
	#set mainGui_x [expr [winfo x .popUpHelp]+200];
	#set mainGui_y [expr [winfo y .popUpHelp]+675];
	
	wm geometry  .popUpHelp +400+200;
	wm resizable .popUpHelp 0 0;
	wm transient .popUpHelp .
	wm deiconify .popUpHelp;
	wm title .popUpHelp "Selection Help";
	
	#grab .popUpHelp
	
	set helpImages_top [hwtk::labelframe $popUpHelp.helpImages_top -text "Selections" -labelanchor nw -padding 4];
	pack $helpImages_top -side top -expand false -padx 4 -pady 4 -anchor nw;

	#add text message in frame
	set label_frm [hwtk::label $helpImages_top.label_frm -text $message -width 50];
	pack $label_frm -side top -expand true -pady 4 -padx 4 -anchor nw;

	#add image to frame
	set help_image [hwtk::frame $helpImages_top.help_image];
	pack $help_image -side top -expand true -fill both -pady 4 -padx 4 -anchor ne;
	pack [hwtk::label $help_image.picture -image $imagePath ] -side top -padx 4 -pady 2;

	set ok_btn  [hwtk::button $helpImages_top.ok_btn  -text "OK" -command "::popUpImages::OnOK" -width 14];
	pack $ok_btn -side left -expand false -pady 4 -padx 4 -anchor ne;
	
	tkwait window .popUpHelp

}


