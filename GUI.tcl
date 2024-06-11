#procomp E:\\WorkingDir\\WIP\\Connection_modelling\\package\\03Nov\\03Nov\\*.tcl
#procomp E:\\aa\\*.tcl
namespace eval ::CustomConnectors {
	
	#######Help variables#################################
	variable ::CustomConnectors::fl_help_MetalClip "insert MetalClip helpfile"
	variable ::CustomConnectors::fl_help_UsWeld "insert UsWeld helpfile"
	variable ::CustomConnectors::fl_help_Screw "insert Screw helpfile"
	variable ::CustomConnectors::fl_help_PlasticClip "insert PlasticClip helpfile"
	variable ::CustomConnectors::fl_help_Retainer "insert Retainer helpfile"
	variable ::CustomConnectors::fl_help_Grommet "insert Grommet helpfile"
	variable ::CustomConnectors::fl_help_Crashclip "insert Crashclip helpfile"
	variable ::CustomConnectors::fl_help_Snaps "insert Snaps helpfile"
	variable ::CustomConnectors::fl_help_RibWeld "insert RibWeld helpfile"
	variable ::CustomConnectors::fl_help_Hinge "insert Hinge helpfile"
	variable ::CustomConnectors::fl_help_Locators "insert Locators helpfile"
	variable ::CustomConnectors::fl_help_manageFixaton "insert ManageFixaton helpfile"
	variable ::CustomConnectors::fl_help_export "insert Export helpfile"
	variable ::CustomConnectors::fl_help_import "insert Import helpfile"
	#######################################################
	
	set ::CustomConnectors::autoElemsLocator 1
	set ::CustomConnectors::typeCon 0
	set ::CustomConnectors::n_systemID 0
	set ::CustomConnectors::n_locator 0
	set ::CustomConnectors::n_sysID ""
	set ::CustomConnectors::createbtn 0
	set ::CustomConnectors::selectionType 1
	set ::CustomConnectors::spcCon 1
	set ::CustomConnectors::spcCon_b4Loc 1
	set ::CustomConnectors::washerType 1
	set ::CustomConnectors::planeCreationType 1
	set ::CustomConnectors::planeCreationType_modify 2
	set ::CustomConnectors::numlayers 2
	set ::CustomConnectors::str_freeEnd 0
	set ::CustomConnectors::n_sysExistingID ""
	set ::CustomConnectors::n_sysLastCreated ""
	set ::CustomConnectors::cb_plane ""
	set ::CustomConnectors::btn_selCon ""
	set ::CustomConnectors::chk_system ""
	set ::CustomConnectors::frm_orentationNote ""
	set ::CustomConnectors::frm_repimage ""
	set ::CustomConnectors::str_level 0
	set ::CustomConnectors::str_Cname ""
	set ::CustomConnectors::nVector ""
	set ::CustomConnectors::n_yVector ""
	set ::CustomConnectors::lsttags ""
	set ::CustomConnectors::lsttags_vector ""
	set ::CustomConnectors::lst_dirNodeTags ""
	set ::CustomConnectors::lstplane {"X-Global" "Y-Global" "Z-Global" {N1|N2|N3}}
	set ::CustomConnectors::lstConnection {Antolin Convert VibWeld UsWeld Screw MetalClip PlasticClip Retainer Grommet Crashclip Snaps RibWeld Hinge Locators Rerealize fileExportConnect fileImportConnect  }
	set ::CustomConnectors::lstEids "Rigids-Beam-Rigids"
	variable str_sytemopt 1
	set ::CustomConnectors::scriFPath [file join [file dirname [info script] ] incl]
	set ::CustomConnectors::path_materialdata [file join [file dirname [info script] ] config]
	# set ::CustomConnectors::imagePath [file join $::CustomConnectors::scriFPath Images]
	set ::CustomConnectors::imagePath [file join  [file dirname [info script] ] images]
	set ::CustomConnectors::vibRealize [file join  [file dirname [info script] ] RealizeVibWeld]
	set ::CustomConnectors::vibTool [file join  [file dirname [info script] ] VibrationWeldingTool]
	
	set ::CustomConnectors::antolinDir [file join  [file dirname [info script] ] Antolin]
	
	variable lBox "";
	# variable spcCon "";
	variable str_MatrailName "";
	variable str_PropsName "";
	variable username $::env(USERNAME)
	if {[info exist username]} {set username $username} else {set username guest}
	
	set s1 [file join $scriFPath Function.tcl]
	set pb [file join $scriFPath TDProgressBar.tcl]
	set s2 [file join $scriFPath ElementCreate.tcl]
	set s3 [file join $scriFPath metadata.tcl]
	set s4 [file join $scriFPath Utils.tcl]
	set s5 [file join $scriFPath Connectors_procs.tcl]
	set s6 [file join $scriFPath Tab_Utils.tcl]
	set s7 [file join $vibRealize ConversionLsDyna.tcl]
	set s8 [file join $vibRealize ConversionAbaqus.tcl]
	set s9 [file join $vibRealize ConversionNastran.tcl]
	set s10 [file join $vibRealize ConversionPamcrash.tcl]
	set s11 [file join $vibRealize ConversionRadioss.tcl]
	set mat [file join $scriFPath MaterialTextWidget.tcl]
	set vwt [file join $vibTool Launch.tcl]
	set antolin_main [file join $antolinDir gui_antolin.tcl]
	set antolin_connectionConvert [file join $antolinDir convertConnections ConvertConnectionsGUI.tcl];
	
	::hwt::Source $s1;
	::hwt::Source $pb;
	::hwt::Source $s2;
	::hwt::Source $s3;
	::hwt::Source $s4;
	::hwt::Source $s5;
	::hwt::Source $s6;
	::hwt::Source $s7;
	::hwt::Source $s8;
	::hwt::Source $s9;
	::hwt::Source $s10;
	::hwt::Source $s11;
	::hwt::Source $mat;
	::hwt::Source $vwt;
	::hwt::Source $antolin_main;
	::hwt::Source $antolin_connectionConvert;
		
	package require hwat;
	
	variable arr_materialNameHolder
	catch {array unset arr_materialNameHolder}
	array set arr_materialNameHolder [list]
	
	variable arr_levelStateHolder
	catch {array unset arr_levelStateHolder}
	array set arr_levelStateHolder [list]
	
	variable arr_con_type
	catch {array unset arr_con_type}
	array set arr_con_type [list]
		
}

###Added for help button#####
proc ::CustomConnectors::CallOnHelpButtons {filepath} {
	catch {::FIS_Tools::FIS_Framework::CallHelp $filepath}
}

proc ::CustomConnectors::CheckProfileAnUpdaEid {args} {
	
	variable lstEids
	variable lstEidsRealize
	variable arr_inputNods
	variable path_materialdata
	variable arr_materialPath
	variable str_Relizeeids
	variable lstProps
	variable lstMAts
	catch {unset arr_inputNods}
	if {[array exist arr_materialPath]} {
		array unset arr_materialPath
	}
	set lstProps ""
	set lstMAts ""
	array set arr_inputNods [list]
	array set arr_materialPath [list]
	set unserProfile [lindex [hm_framework getuserprofile] 0]
	set ::CustomConnectors::unitSystem ""
	set ::CustomConnectors::unit ""
	
	if {$unserProfile == "LsDyna" || $unserProfile == "Pamcrash2G"} {
		set ::CustomConnectors::str_level 1
	} elseif {$unserProfile == "Nastran" || $unserProfile == "OptiStruct"} {
		set ::CustomConnectors::str_level 1
	}
	
	if {[file exist [file join $path_materialdata $unserProfile]]} {
	
		set ::CustomConnectors::unitSystem [glob -tails -directory [file join $path_materialdata $unserProfile] *]
		set ::CustomConnectors::unit [lindex $::CustomConnectors::unitSystem 0]
		set str_matfile [glob -nocomplain -directory [file join $path_materialdata $unserProfile $::CustomConnectors::unit material] *]
		set str_Propsfile [glob -nocomplain -directory [file join $path_materialdata $unserProfile $::CustomConnectors::unit property] *]
		
		foreach n $str_matfile {
		
			set name [file tail [file rootname $n]]
			set arr_materialPath($name,Mats) $n
			lappend lstMAts $name
		}
		
		foreach n $str_Propsfile {
		
			set name [file tail [file rootname $n]]
			set arr_materialPath($name,Props) $n
			lappend lstProps $name
		}

	}
	
	if {$unserProfile == {RadiossBlock}} {
	
		set lstEids {Rigids-Spring-Rigids}
		set lstEidsRealize {Rigids-Spring-Rigids-Fis Rigids-Fis Spring-Fis}
		
	} elseif {$unserProfile == {LsDyna}} {
	
		set lstEids {Rigids-Beam-Rigids}
		set lstEidsRealize {Beam-Fis Rigids-Fis}
		
	} elseif {$unserProfile == {Nastran} || $unserProfile == {OptiStruct}} {
	
		set lstEids {Rigids-Bar-Rigids}
		set lstEidsRealize {Rigids-Bar-Rigids-Fis Rigids-Fis}

	} elseif {$unserProfile == {Pamcrash2G}} {
	
		set lstEids {Rigids-Bar-Rigids}
		set lstEidsRealize {Rigids-Fis}
	} else {
		set lstEids {Rigids-Bar-Rigids}
		set lstEidsRealize {Rigids-Bar-Rigids-Fis Rigids-Fis}
		
	}
	
	set str_Relizeeids [lindex $::CustomConnectors::lstEidsRealize 0]
	
	return;

}

proc ::CustomConnectors::CheckUnit {args} {
	
	::CustomConnectors::TogglePerformance "off"
	
	variable arr_inputNods
	variable path_materialdata
	variable arr_materialPath
	variable lstProps
	variable lstMAts
	catch {unset arr_inputNods}
	if {[array exist arr_materialPath]} {
		array unset arr_materialPath
	}
	set lstProps ""
	set lstMAts ""
	array set arr_inputNods [list]
	array set arr_materialPath [list]
	set unserProfile [lindex [hm_framework getuserprofile] 0]
	set ::CustomConnectors::unitSystem ""
	# set ::CustomConnectors::unit ""
	
	if {[file exist [file join $path_materialdata $unserProfile]]} {
	
		set ::CustomConnectors::unitSystem [glob -tails -directory [file join $path_materialdata $unserProfile] *]
		# set ::CustomConnectors::unit [lindex $::CustomConnectors::unitSystem 0]

		set lst_units [list]
		foreach n [hm_entitylist connectors id] {
			if {[hm_entityinfo exist connector $n]} {
				lappend lst_units [::MetaData::GetMetadataByMark connector $n Unit]
			}	
		}
		set n_check 0
		if {[llength $lst_units]} {
			foreach unit $::CustomConnectors::unitSystem {
				set n_times [llength [lsearch -all $lst_units $unit]]
				# puts $n_times-----n_times
				if {$n_times > $n_check} {
					set ::CustomConnectors::unit $unit
					set n_check $n_times
				}
			}
		}
	}
	
	::CustomConnectors::TogglePerformance "on"
	
	return;

}



proc ::CustomConnectors::LevelElemnts {frm args} {

	
	set unserProfile [lindex [hm_framework getuserprofile] 0]
	
	if {$unserProfile == {RadiossBlock}} {
		
		if {$args == 0} {
			set ::CustomConnectors::str_Relizeeids Rigids-Fis
		} elseif {$args == 1} {
			set ::CustomConnectors::str_Relizeeids Rigids-Spring-Rigids-Fis
		} elseif {$args == 2} {
		 set ::CustomConnectors::str_Relizeeids Rigids-Spring-Rigids-Fis
		}
	
		
	} elseif {$unserProfile == {LsDyna}} {
		
		if {$args == 0} {
			set ::CustomConnectors::str_Relizeeids Rigids-Fis
		} elseif {$args == 1} {
			set ::CustomConnectors::str_Relizeeids Rigids-Beam-Rigids-Fis
		} elseif {$args == 2} {
			# set ::CustomConnectors::str_Relizeeids Rigids-RevJoint-Rigids-Fis
			set ::CustomConnectors::str_Relizeeids EdgeTOEdge
		}
		

	} elseif {$unserProfile == {Nastran} || $unserProfile == {OptiStruct}} {
		
		if {$args == 0} {
			set ::CustomConnectors::str_Relizeeids Rigids-Fis
		} elseif {$args == 1} {
			set ::CustomConnectors::str_Relizeeids Rigids-Bar-Rigids-Fis
		} elseif {$args == 2} {
			set ::CustomConnectors::str_Relizeeids Rigids-Bar-Rigids-Fis
		}
	
	} elseif {$unserProfile == {Pamcrash2G}} {
	
		if {$args == 0} {
			set ::CustomConnectors::str_Relizeeids Rigids-Fis
		} elseif {$args == 1} {
			set ::CustomConnectors::str_Relizeeids Rigids-Spring-Rigids-Fis
		} elseif {$args == 2} {
			set ::CustomConnectors::str_Relizeeids Plink
		}


	} else {
		
		set ::CustomConnectors::str_Relizeeids Rigids-Fis
	}
	
	
	# puts $args---$::CustomConnectors::str_Relizeeids
	if {$frm != 0 } {
		::CustomConnectors::ImageForLevel1 $frm $args
	}
	return;

}


proc ::CustomConnectors::ImageForLevel {fram args} {
	
	catch {destroy $fram.helpImage}
	set frm_image [frame $fram.helpImage]
	pack $frm_image -side top -anchor nw -padx 2 -pady 2;
	
	if {$args == 1} {
		set imge_level1 [image create photo img_Level1 -file [file join $::CustomConnectors::imagePath Level1.png]]
		pack [hwtk::label $frm_image.leb1 -relief sunken -image $imge_level1] -side top -padx 4 -pady 2
	} else {
		
		set imge_level1 [image create photo img_Level0 -file [file join $::CustomConnectors::imagePath Level0.png]]
		pack [hwtk::label $frm_image.leb1 -relief sunken -image $imge_level1] -side top -padx 4 -pady 2
	}
	
	return

}


proc ::CustomConnectors::ImageForLevel1 {fram args} {
	
	# puts $fram
	catch {destroy $fram.helpImage}
	catch {destroy $fram.oriImage}
	set frm_image [frame $fram.helpImage]
	pack $frm_image -side left -anchor nw -padx 2 -pady 2;
	
	# puts out
	set unserProfile [lindex [hm_framework getuserprofile] 0]
	
	set filpath [file join $::CustomConnectors::imagePath ${::CustomConnectors::str_combovalue}_${::CustomConnectors::str_level}_${unserProfile}.png]
	if {![file exist $filpath]} {
		
		if {$::CustomConnectors::str_level == 0} {
			set filpath [file join $::CustomConnectors::imagePath Level0.png]
		} else {
			set filpath [file join $::CustomConnectors::imagePath Level1.png]
		}
		
	}
	set img_change [image create photo img_change -file $filpath]
	pack [hwtk::label $frm_image.leb1 -relief sunken -image $img_change] -side top -padx 4 -pady 2
	
	
	return

}

proc ::CustomConnectors::ImageForLevel1_orientation {str_orientationtype args} {
	
	variable frm_repimage;
	
	if {![winfo exists $frm_repimage]} {
		return;
	}
	
	if {[string match -nocase "Normal Selection" $str_orientationtype]} {
		set str_orientation "normal"
	} elseif {[string match -nocase "Parallel Selection" $str_orientationtype]} {
		set str_orientation "parallel"
	} else {
		set str_orientation "dirplane"
	}
	
	set userProfile [lindex [hm_framework getuserprofile] 0]
	set filepath [file join $::CustomConnectors::imagePath ${::CustomConnectors::str_combovalue}_${str_orientation}.png]
	
	# set filepath [file join $::CustomConnectors::imagePath ${::CustomConnectors::str_combovalue}_${::CustomConnectors::str_level}_${str_orientation}.png]
	
	# set lst_imgfiles [glob -nocomplain -tails -directory $::CustomConnectors::imagePath *$::CustomConnectors::str_combovalue*]
	# set str_imgfile [lsearch -all -inline -nocase $lst_imgfiles "*$::CustomConnectors::str_combovalue*$::CustomConnectors::str_level*$userProfile*$str_orientation*"]
	
	if {[file exist $filepath]} {
	
		catch {destroy $frm_repimage.oriImage}
		set frm_image [frame $frm_repimage.oriImage]
		pack $frm_image -side left -anchor nw -padx 2 -pady 2;
		
		set img_orientation [image create photo img_orientation -file $filepath]
		pack [hwtk::label $frm_image.label -relief sunken -image $img_orientation] -side top -padx 4 -pady 2
		
	}
	
	return

}

proc ::CustomConnectors::RetEidLevel {args} {

	
	set unserProfile [lindex [hm_framework getuserprofile] 0]
	
	if {$unserProfile == {RadiossBlock}} {
		
		if {$args == {Rigids-Fis}} {

			set ::CustomConnectors::str_Relizeeids Rigids-Fis
			return 0
			
		} elseif {$args == {Rigids-Spring-Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Spring-Rigids-Fis
			return 1
		} elseif {$args == 2} {
			 set ::CustomConnectors::str_Relizeeids Rigids-Spring-Rigids-Fis
			 return 2
		}
	
		
	} elseif {$unserProfile == {LsDyna}} {
		
		if {$args == {Beam-Fis}} {
			set ::CustomConnectors::str_Relizeeids Beam-Fis
			return 0
		} elseif {$args == {Rigids-Beam-Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Beam-Rigids-Fis
			return 1
		} elseif {$args == {Rigids-Beam-Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Beam-Rigids-Fis
			return 2
		}
		

	} elseif {$unserProfile == {Nastran} || $unserProfile == {OptiStruct}} {
		
		if {$args == {Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Fis
			return 0
		} elseif {$args == {Rigids-Bar-Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Bar-Rigids-Fis
			return 1
		} elseif {$args == 2} {
			set ::CustomConnectors::str_Relizeeids Rigids-Bar-Rigids-Fis
			return 2
		}
	
	} elseif {$unserProfile == {Pamcrash2G}} {
	
		if {$args == {Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Fis
			return 0
		} elseif {$args == {Rigids-Bar-Rigids-Fis}} {
			set ::CustomConnectors::str_Relizeeids Rigids-Bar-Rigids-Fis
			return 1
		} elseif {$args == 2} {
			set ::CustomConnectors::str_Relizeeids Rigids-Bar-Rigids-Fis
			return 2
		}


	} else {
		
		set ::CustomConnectors::str_Relizeeids Rigids-Fis
	}
	

	return;

}


proc ::CustomConnectors::OnConnecTypeMAtPrpsUpt {args} {

	variable str_combovalue
	variable path_materialdata
	variable arr_materialPath
	variable lstProps
	variable lstMAts
	
	if {[array exist arr_materialPath]} {
		array unset arr_materialPath
	}
	set unserProfile [lindex [hm_framework getuserprofile] 0]
	array set arr_materialPath [list]
	set str_matfile [glob -nocomplain -directory [file join $path_materialdata $unserProfile $::CustomConnectors::unit material] *]
	set str_plink "" 
	if {$unserProfile == "Pamcrash2G" && $::CustomConnectors::str_level == 2} {
		set str_matfile [glob -nocomplain -directory [file join $path_materialdata $unserProfile $::CustomConnectors::unit material Level2] *]
		set str_plink "_Level2"
	}
	set str_Propsfile [glob -nocomplain -directory [file join $path_materialdata $unserProfile $::CustomConnectors::unit property] *]
	set str_matfile1 [lsearch -nocase -all -inline $str_matfile *$str_combovalue*]
	# puts $str_matfile1----str_matfile1-------$::CustomConnectors::str_level--------::CustomConnectors::str_level
	set str_Propsfile1 [lsearch -nocase -all -inline $str_Propsfile *$str_combovalue*]

	foreach n $str_matfile1 {
	
		set name [file tail [file rootname $n]]
		set name1 ${name}${str_plink}
		set arr_materialPath($name1,Mats) $n
		lappend lstMAts $name
	}
	
	foreach n $str_Propsfile1 {
	
		set name [file tail [file rootname $n]]
		set arr_materialPath($name,Props) $n
		lappend lstProps $name
	}
	
	return;
}

proc ::CustomConnectors::ComboBoxMaterialName {args} {

	variable arr_materialNameHolder
	variable str_combovalue
	
	set arr_materialNameHolder($str_combovalue) $::CustomConnectors::str_MatrailName
	return
}
	
proc ::CustomConnectors::UpdateUnitPath {args} {

	variable path_materialdata
	variable arr_materialPath
	variable str_combovalue
	variable lstProps
	variable lstMAts
	variable arr_materialNameHolder
	catch {unset arr_inputNods}
	
	set ::CustomConnectors::lstProps ""
	set ::CustomConnectors::lstMAts ""
	array set arr_inputNods [list]
	
	::CustomConnectors::OnConnecTypeMAtPrpsUpt
	
	# if {[file exist [$path_materialdata $unserProfile $::CustomConnectors::unit]]} {
		
		set ::CustomConnectors::str_PropsName [lindex $lstProps 0]
		if {[info exists arr_materialNameHolder($str_combovalue)]} {
			set ::CustomConnectors::str_MatrailName [set arr_materialNameHolder([set str_combovalue])]
		} else {
			set ::CustomConnectors::str_MatrailName [lindex $lstMAts 0]
		}


		set imge_edit [image create photo img_edit -file [file join $::CustomConnectors::imagePath EditMat.png]]

		catch {destroy $args.frm_propsMat}
		set frm_propsMat [frame $args.frm_propsMat ]
		pack $frm_propsMat -side top -anchor nw -padx 2;
		
		set frm_prop [frame $frm_propsMat.frm_prop ]
		pack $frm_prop -side top -anchor nw -padx 2;
		
		set lbl_1 [ttk::label [set frm_prop].lbl_1 -text "Property List" -width 20]
		set cb_p [hwtk::combobox $frm_prop.cb1 -textvariable "::CustomConnectors::str_PropsName" -state readonly -values $::CustomConnectors::lstProps -width 15]
		
		# pack $lbl_1 -side left -anchor w  -pady 2;
		# pack $cb_p -side left -anchor w  -pady 2;
		
		set frm_Mat [ttk::labelframe $frm_propsMat.mat -text "Material List" -labelanchor n]
		pack $frm_Mat -side top -anchor nw -padx 2 -pady 2;
		# set lbl_1 [ttk::label [set frm_Mat].lbl_1 -text "Material List" -width 12]
		set cb_m [hwtk::combobox $frm_Mat.cb1 -textvariable "::CustomConnectors::str_MatrailName" -state readonly -values $::CustomConnectors::lstMAts -width 40]
		set btnedit [hwtk::button ${frm_Mat}.cmEdit -image [set imge_edit]  -command [list ::CustomConnectors::MatWidgetEidt 1]  -help "Verify the Material"] 
		
		
		bind $cb_m <<ComboboxSelected>> [list ::CustomConnectors::ComboBoxMaterialName]
		
		# pack $lbl_1 -side left -anchor w  -pady 2;
		pack $cb_m -side left -anchor w -padx 5 -pady 2;
		pack $btnedit -side left -anchor w  -pady 2 -padx 5;
		# pack [hwtk::button ${frm_Mat}.cpEdit -image [set imge_edit]  -command ::example::CreatePropertyArea -help "Edit Material"] -side left -pady 2;

	# }	
	# puts coasjlksdjl
	
	return

}


proc ::CustomConnectors::MainGui args {

	variable strMainFram
	variable frm_create
	if {![winfo exists $args]} {
		# catch  {destroy .frm_main}
		# set frm_main ".frm_main"
		lassign [::HmTap::MainGui "Custom Connector" ".fcustom"]  x frm_main y
		# set tab_name "Custom Connector"
		# set frm_main [::CustomConnectors::AddTabToframework $tab_name $frm_main];
	} else {
	
		set frm_main $args
	}
	
	#  
	################
	# set ::CustomConnectors::createbtn 0
	catch {destroy $frm_main.frm_mainfrm2}
	set frm_mainfrm2 [frame $frm_main.frm_mainfrm2 ]
	pack $frm_mainfrm2 -side top -anchor nw -padx 2 -pady 2 -fill both 
	
	 
	
	set frm_create [frame $frm_mainfrm2.frm_create]
	pack $frm_create -side left -anchor nw -padx 2 -pady 2 -fill y 
	
	set frm_Input [frame $frm_mainfrm2.frm_Input ]
	pack $frm_Input -side left -anchor nw -padx 2 -pady 2 -fill both 
	set strMainFram $frm_Input
	set frm_sep12 [frame $frm_main.frm_sep12]
	pack $frm_sep12 -side top -fill both;
	
	::CustomConnectors::CheckProfileAnUpdaEid
	::CustomConnectors::ImageButton1 $frm_create [list ::CustomConnectors::OnCreate2] $frm_Input


}	

proc ::CustomConnectors::ONRaidos {frm_main} {
	
	
	::CustomConnectors::CheckProfileAnUpdaEid
	catch {destroy $frm_main.frm_firsttp1}
	set frm_firsttp [frame $frm_main.frm_firsttp1]
	pack $frm_firsttp -side top -anchor nw -padx 2 -pady 2;

	if {$::CustomConnectors::createbtn == 0} {
	
		# ::CustomConnectors::OnCreate $frm_firsttp
	} elseif  {$::CustomConnectors::createbtn == 1} {

		::CustomConnectors::OnReRealize $frm_firsttp
	} elseif  {$::CustomConnectors::createbtn == 2} {
		::CustomConnectors::OnExport $frm_firsttp
	} else {
	
		::CustomConnectors::OnImport $frm_firsttp
		
	}
	
	return;
}


proc ::CustomConnectors::OnCreate {frm_main1} {
	
	set frm_ConType [frame $frm_main1.frm_ConType ]
	pack $frm_ConType -side top -anchor nw -padx 2 -pady y;
	
	::CustomConnectors::ImageButton1 $frm_ConType [list ::CustomConnectors::OnCreate2] $frm_main1
	
	::CustomConnectors::OnCreate2 $frm_main1
	return;
	
}

proc ::CustomConnectors::OnCreate2 {args} {
	
	variable str_combovalue
	variable strMainFram
	variable arr_inputNods
	catch {unset arr_inputNods}
	set frm_main1 $strMainFram
	catch {destroy $frm_main1.subfram}
	set subfram [frame $frm_main1.subfram ]
	pack $subfram -side top -anchor nw -padx 2 -pady 2;
	::CustomConnectors::Deltag1
	 
	set str_combovalue $args;
	
	if {$args == {VibWeld} } {
		
		::CustomConnectors::VibrationWelding $subfram
		
	} elseif {$str_combovalue == {0} } {
		catch {destroy $frm_main1.subfram}
	} elseif {$str_combovalue == {Rerealize} } {
		::CustomConnectors::OnReRealize $subfram
	} elseif {$str_combovalue == {fileExportConnect} } {
		::CustomConnectors::OnExport $subfram
	} elseif {$str_combovalue == {fileImportConnect} } {
		::CustomConnectors::OnImport $subfram
	} else {
		::CustomConnectors::ComboName
		
		if {$args == {Locators}} {
			::CustomConnectors::ForlocatorGUi $subfram $str_combovalue
			
		} elseif {$args == {Antolin}} {
			#variable to disable material button
			set ::dummyMaterial::material_flag 0;
			
			::connector::antolin_main_fun $subfram;
		} elseif {$args == {Convert}} {
			::convertGUI::antolin_main_fun $subfram;
		} else {
			::CustomConnectors::OnCreate3 $subfram $str_combovalue
		}
		
	}
	
	return;
}


proc ::CustomConnectors::OnCreate3 {frm_main1 args} {
	
	::CustomConnectors::CheckUnit
	
	variable lstConnection
	variable str_combovalue
	variable str_Cname
	variable str_eids
	variable str_Relizeeids
	variable lstProps
	variable lstMAts
	variable str_sytemopt 
	variable imagePath
	variable chk_system
	variable btn_selCon
	variable cb_plane
	variable frm_orentationNote
	variable frm_repimage
	variable arr_levelStateHolder
	set ::CustomConnectors::selectionType 1
	set ::CustomConnectors::n_locator 0
	# set ::CustomConnectors::spcCon 0
	# set ::CustomConnectors::str_level 0
	*clearmarkall 1
	*clearmarkall 2
	# set frm_sep1 [frame $frm_main.frm_sep1]
	# pack $frm_sep1 -side top -fill both;
	# Separator [set frm_sep1] Horizontal
	# ::CustomConnectors::ComboName

	if {$::CustomConnectors::str_level == "explicit" || $::CustomConnectors::str_level == "implicit" || $::CustomConnectors::str_level == "all" || $::CustomConnectors::str_level == "type1" || $::CustomConnectors::str_level == "type2" || $::CustomConnectors::str_level == "3"} {
		set ::CustomConnectors::str_level 1
	}
	
	if {[info exists arr_levelStateHolder($str_combovalue)]} {
		set ::CustomConnectors::str_level [set arr_levelStateHolder([set str_combovalue])]
	} else {
		if {$::g_profile_name == {Pamcrash2G}} {
			if {$str_combovalue != {UsWeld} || $str_combovalue != {RibWeld} || $str_combovalue != {Retainer}} {
				set ::CustomConnectors::str_level 1
			}
		}
		set arr_levelStateHolder([set str_combovalue]) $::CustomConnectors::str_level
	}
	# parray arr_levelStateHolder
	set img_selc [image create photo imgSel -file [file join $imagePath select-24.png]]
	
	set frm_unitSystem [frame $frm_main1.units ]
	pack $frm_unitSystem -side top -anchor nw -padx 2 -pady 2;
	set lb_Uit [ttk::label [set frm_unitSystem].inilab -text "Connector Unit System" -width 20]
	set cb_uit [hwtk::combobox $frm_unitSystem.unicb -textvariable "::CustomConnectors::unit" -state readonly -values $::CustomConnectors::unitSystem -width 15 ]
	pack $lb_Uit -side left -anchor nw -padx 2 -pady 2;
	pack $cb_uit -side left -anchor nw -padx 2 -pady 2;

	
	set frm_main [ttk::labelframe $frm_main1.lbMain1 -labelanchor n -width 2]
	pack $frm_main -side top -anchor n -padx 5 -pady 2
	
	set btnCreate [label [set frm_main].label -text "$args" -font [list -size 12 -weight bold]]
	$frm_main configure -labelwidget $btnCreate
	
		# set frm_unitSystem [frame $frm_main.units ]
		# pack $frm_unitSystem -side top -anchor nw -padx 2 -pady 2;
		# set lb_Uit [ttk::label [set frm_unitSystem].inilab -text "Unit System" -width 20]
		# set cb_uit [hwtk::combobox $frm_unitSystem.unicb -textvariable "::CustomConnectors::unit" -state readonly -values $::CustomConnectors::unitSystem -width 15 ]
		bind $cb_uit <ButtonPress>  [list ::CustomConnectors::OnUnitChange]
		bind $cb_uit <<ComboboxSelected>>  [list ::CustomConnectors::UpdateUnitPath $frm_main.matelist ]
		# pack $lb_Uit -side left -anchor nw -padx 2 -pady 2;
		# pack $cb_uit -side left -anchor nw -padx 2 -pady 2;
		# Separator [set frm_main] Horizontal
		set frm_mainfrm1 [frame $frm_main.frm_mainfrm1 ]
		pack $frm_mainfrm1 -side top -anchor nw -padx 2 -pady 2 -fill x -expand 1;

		# puts $cb_uit
		
		# Separator [set frm_main] Horizontal
		# set frm_mainfrm3 [frame $frm_main.frm_mainfrm3 ]
		# pack $frm_mainfrm3 -side top -anchor nw -padx 2 -pady 2;
		
		# set frm_namewld [frame $frm_mainfrm3.eidType ]
		# pack $frm_namewld -side top -anchor nw -padx 2 -pady 2;
		# set lbl_1 [ttk::label [set frm_namewld].lbl_1 -text "ElementType" -width 20]
		# set cb_1 [hwtk::combobox $frm_namewld.cb1 -textvariable "::CustomConnectors::str_Relizeeids" -state readonly -values $::CustomConnectors::lstEidsRealize -width 15]
		# bind $cb_1 <ButtonRelease-1> [list ::CustomConnectors::ComboName]
		
		set level0 [hwtk::radiobutton $frm_mainfrm1.level0 -value 0 -variable ::CustomConnectors::str_level -text "Level-0" -command [list ::CustomConnectors::RadioLevelSelector $frm_main.matelist $frm_main.frmimage 0]]
		set level1 [hwtk::radiobutton $frm_mainfrm1.level1 -value 1 -variable ::CustomConnectors::str_level -text "Level-1" -command [list ::CustomConnectors::RadioLevelSelector $frm_main.matelist $frm_main.frmimage 1]]
		
		set level2 [hwtk::radiobutton $frm_mainfrm1.level2 -value 2 -variable ::CustomConnectors::str_level -text "Level-2" -command [list ::CustomConnectors::RadioLevelSelector $frm_main.matelist $frm_main.frmimage 2] -state disable]
		pack $level0 -side left -anchor nw -padx 2 -pady 2;
		pack $level1 -side left -anchor nw -padx 2 -pady 2;
		pack $level2 -side left -anchor nw -padx 2 -pady 2;
		
		#####Help button#########
		set img_help [image create photo imgHelp -file [file join $imagePath help-16.png]]
		set btn_help [hwtk::button $frm_mainfrm1.btn_help -image $img_help -command [list ::CustomConnectors::CallOnHelpButtons [set ::CustomConnectors::fl_help_${args}]]]
		pack $btn_help -side left -anchor ne -padx 2 -pady 2 -expand 1;
		#########################

		if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {Snaps}} {
		
			# set [namespace current]::spcCon 1
			Separator [set frm_main] Horizontal
			
			set frm_radioLoc [frame $frm_main.frm_radioLoc]
			pack $frm_radioLoc -side top -anchor nw -padx 2 -pady 2;
			
			set rad_spImpl [hwtk::radiobutton  $frm_radioLoc.spciali -value 1 -text "Implicit" -variable [namespace current]::spcCon -command ""]  
			
			set rad_spExpl [hwtk::radiobutton  $frm_radioLoc.spciale -text "Explicit" -value 3 -variable [namespace current]::spcCon -command ""] 
			
			pack $rad_spImpl -side left -anchor nw -padx 2 -pady 2;
			pack $rad_spExpl -side left -anchor nw -padx 2 -pady 2;
			
			if {$::g_profile_name == {Pamcrash2G}} {
				pack forget $rad_spImpl
				set [namespace current]::spcCon 3
			} elseif {$::g_profile_name == {Nastran} || $::g_profile_name == {OptiStruct}} {
				pack forget $rad_spExpl
				set [namespace current]::spcCon 1
			} elseif {$::g_profile_name == {LsDyna} && $::CustomConnectors::spcCon == 0} {
				if {[info exists ::CustomConnectors::spcCon_b4Loc]} {
					set ::CustomConnectors::spcCon $::CustomConnectors::spcCon_b4Loc
				} else {
					set ::CustomConnectors::spcCon 3
				}
			}
			
		}
	
		if {$::g_profile_name == {LsDyna} } {
			
			if {$str_combovalue == {Snaps}} {
				# set dynaExp [hwtk::radiobutton $frm_mainfrm1.level3 -value 3 -variable ::CustomConnectors::str_level -text "Dyna-Exp" -command [list ::CustomConnectors::LevelElemnts $frm_main.frmimage 3]]
				# pack $dynaExp -side left -anchor nw -padx 2 -pady 2;
				
				$level2 configure -state enable
				
			} elseif {$str_combovalue == {Hinge}} {
				$level2 configure -state disable
			}
		}
		if {$::g_profile_name == {Pamcrash2G}} {
			if {$str_combovalue == {UsWeld} || $str_combovalue == {RibWeld} || $str_combovalue == {Retainer}} {
				$level2 configure -state enable
			}
		}
		if {$::g_profile_name == {Nastran} || $::g_profile_name == {OptiStruct}} {
			if {$str_combovalue == {Hinge}} {
				# $level1 configure -state disable
				$level2 configure -state disable
			}
		}
		
		Separator [set frm_main] Horizontal
		set frm_mainfrm3 [frame $frm_main.frm_mainfrm3 ]
		pack $frm_mainfrm3 -side top -anchor nw -padx 2 -pady 2;
		
		set frm_auto [frame $frm_mainfrm3.frm_auto ]
		pack $frm_auto -side left -anchor nw -padx 2 -pady 2;
		
		set radio_auto [hwtk::radiobutton $frm_auto.radio_auto -value 1 -variable ::CustomConnectors::selectionType -text "Semiautomatic" -command ""]
		pack $radio_auto -side left -anchor nw -padx 2 -pady 2;

		# set frm_sep15 [frame $frm_mainfrm3.frm_sep15]
		# pack $frm_sep15 -side left -fill both;
		# Separator [set frm_sep15] Vertical

		# set frm_manual [frame $frm_mainfrm3.frm_manual ]
		# pack $frm_manual -side left -anchor nw -padx 2 -pady 2;
		
		set radio_manual [hwtk::radiobutton $frm_auto.radio_manual -value 0 -variable ::CustomConnectors::selectionType -text "Manual" -command ""]
		pack $radio_manual -side left -anchor nw -padx 2 -pady 2;
		
		if {$str_combovalue == {Snaps}} {
			set ::CustomConnectors::selectionType 0
		}

	Separator [set frm_main] Horizontal
		# set str_Cname ${str_combovalue}_
		
		##################
		set frm_mainfrm4 [frame $frm_main.frm_mainfrm4 ]
		pack $frm_mainfrm4 -side top -anchor nw -padx 2 -pady 2;
		
		###################
	
		# pack $lbl_1 -side left -anchor w  -pady 2;
		# pack $cb_1 -side left -anchor w  -pady 2;
		
		
		###################3333
		set frm_namewld [frame $frm_mainfrm4.frm_namewld ]
		pack $frm_namewld -side top -anchor nw -padx 2 -pady 2;
		
		set label_namewld [label $frm_namewld.label_namewld -text "Name of Weld Collector" ]
		pack $label_namewld -side left -anchor nw -padx 5 -pady 2;
		
		set entry_namewld [entry $frm_namewld.entry_namewld  -textvariable [namespace current]::str_Cname -state disable]
		pack $entry_namewld -side left -anchor w -padx 19 -pady 2;
		
		############
		set frm_selcomp [frame $frm_mainfrm4.frm_selcomp ]
		pack $frm_selcomp -side top -anchor nw  -pady 2;
		
		# set label_selcomp [label $frm_selcomp.label_selcomp -text "Select component" -width 20]
		# pack $label_selcomp -side left -anchor w  -pady 2;
		
		# set btn_selcomp [button $frm_selcomp.btn_selcomp  -text " Select " -command "::CustomConnectors::SelComps" ]
		# pack $btn_selcomp -side left -anchor w  -pady 2;
		
		##############
		set frm_numlayers [frame $frm_mainfrm4.frm_numlayers ]
		pack $frm_numlayers -side top -anchor nw -padx 2 -pady 2;
		
		set frm_selnd [frame $frm_main.frm_selnd ]
		pack $frm_selnd -side top -anchor nw -padx 2 -pady 2;
		
		set label_numlayers [label $frm_numlayers.label_numlayers -text "Number of connecting parts"]
		pack $label_numlayers -side left -anchor w -padx 5 -pady 2;
	
		
		# set entry_numlayers [hwtk::entry $frm_numlayers.entry_numlayers -textvariable "::CustomConnectors::numlayers" -inputtype unsignedinteger -justify center -width 5 ]
		
		# pack $entry_numlayers -side left -anchor w  -pady 2;
		# bind $entry_numlayers <KeyRelease> [list ::CustomConnectors::OnNmberLinks $frm_selnd]
			
			set ::CustomConnectors::numlayers 2
		
			set radio_2parts [hwtk::radiobutton $frm_numlayers.radio_2parts -value 2 -variable ::CustomConnectors::numlayers -text " 2" -command "::CustomConnectors::OnNmberLinks $frm_selnd"]
			pack $radio_2parts -side left -anchor nw -padx 2 -pady 2;
			
			set radio_3parts [hwtk::radiobutton $frm_numlayers.radio_3parts -value 3 -variable ::CustomConnectors::numlayers -text " 3" -command "::CustomConnectors::OnNmberLinks $frm_selnd"]
			# pack $radio_3parts -side left -anchor nw -padx 2 -pady 2;
			
			set radio_4parts [hwtk::radiobutton $frm_numlayers.radio_4parts -value 4 -variable ::CustomConnectors::numlayers -text " 4" -command "::CustomConnectors::OnNmberLinks $frm_selnd"]
			# pack $radio_4parts -side left -anchor nw -padx 2 -pady 2;
			
			if {$str_combovalue == {RibWeld}} {
				$radio_4parts configure -state disable;
			}
			
			if {$str_combovalue == "UsWeld" || $str_combovalue == "Screw" || $str_combovalue == "Grommet" || $str_combovalue == "RibWeld"} {
				pack $radio_3parts -side left -anchor nw -padx 2 -pady 2;
				pack $radio_4parts -side left -anchor nw -padx 2 -pady 2;
			} else {
				pack forget $radio_3parts
				pack forget $radio_4parts
			}
	
			::CustomConnectors::OnNmberLinks $frm_selnd
		
		set frm_localsys [frame $frm_mainfrm4.frm_localsys ]
		pack $frm_localsys -side top -anchor nw  -pady 2;	
			
			set chk_system [hwtk::checkbutton  $frm_localsys.cbutonsytyem -text "Create Local System" -variable [namespace current]::str_sytemopt]
			pack $chk_system -anchor w -padx 5 -pady 2;
			
			if {$str_combovalue == "Retainer" || $str_combovalue == "Screw" || $str_combovalue == "Crashclip"} {
			
				pack [hwtk::checkbutton  $frm_localsys.cbutonFreeEnd -text "Modeling with free End (Rigid BIW)" -variable [namespace current]::str_freeEnd] -anchor w -padx 5 -pady 2;
				
			} else {
				set ::CustomConnectors::str_freeEnd 0
			}
			
			if {$::CustomConnectors::str_freeEnd == 1 && $str_combovalue != "Screw"} {
				set ::CustomConnectors::numlayers 2
				pack forget $radio_3parts $radio_4parts
				::CustomConnectors::OnNmberLinks $frm_selnd
			}
		
		set frm_washer [frame $frm_mainfrm4.frm_washer ]
		pack $frm_washer -side left -anchor nw -padx 2 -pady 2;
		
		# set label_washer [hwtk::label $frm_washer.label_washer -text "Washer"]
		# pack $label_washer -side left -anchor nw -padx 5 -pady 3;
		
			set frm_washer [ttk::labelframe $frm_washer.lbMain1 -text "Washer Input" -labelanchor n]
			pack $frm_washer -side top -anchor nw  -pady 2
				
			set radio_no [hwtk::radiobutton $frm_washer.radio_no -value 0 -variable ::CustomConnectors::washerType -text " No Washer" -command ""]
			pack $radio_no -side left -anchor nw -padx 2 -pady 2;
			
			set radio_oneLayer [hwtk::radiobutton $frm_washer.radio_oneLayer -value 1 -variable ::CustomConnectors::washerType -text " 1-Layer" -command ""]
			pack $radio_oneLayer -side left -anchor nw -padx 2 -pady 2;
			
			set radio_twoLayer [hwtk::radiobutton $frm_washer.radio_twoLayer -value 2 -variable ::CustomConnectors::washerType -text " 2-Layers" -command ""]
			pack $radio_twoLayer -side left -anchor nw -padx 2 -pady 2;
		
			if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {Snaps}} {
				set ::CustomConnectors::washerType 0
				$radio_oneLayer configure -state disable
				$radio_twoLayer configure -state disable
			} else {
				set ::CustomConnectors::washerType 1
				$radio_oneLayer configure -state enable
				$radio_twoLayer configure -state enable
			}
	
		set frm_planeorentation [frame $frm_main.frm_planeorentation ]
		pack $frm_planeorentation -side top -anchor nw -padx 2 -pady 5p;
		
			set frm_orentation [frame $frm_planeorentation.frm_orentation ]
			pack $frm_orentation -side top -anchor nw;
			
			set frm_orentationNote [frame $frm_planeorentation.frm_orentationNote ]
			
				if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {RibWeld} || $str_combovalue == {Snaps}} {
					set lst_orientationstypes [list "Normal Selection" "Parallel Selection"]
					set ::CustomConnectors::nplanefine [lindex $lst_orientationstypes 0]
				} else {
					set lst_orientationstypes $::CustomConnectors::lstplane
					set ::CustomConnectors::nplanefine [lindex $lst_orientationstypes end]
				}

				# set lbl_plan [ttk::label $frm_orentation.lbl_selectcomp -text "Define Plane/\Vector" ]
				
				set cb_plane [hwtk::combobox $frm_orentation.cb_plane -textvariable "::CustomConnectors::nplanefine" -state readonly -values $lst_orientationstypes -width 10]
				set btn_selCon [::hwtk::button $frm_orentation.btn_selCon -image $img_selc  -command [list ::CustomConnectors::OnSelectCon]]
				
				set rad_plan [hwtk::radiobutton $frm_orentation.rad_plan -value 1 -variable ::CustomConnectors::planeCreationType -text "" -command [list ::CustomConnectors::OnClickPlaneCreation $cb_plane $btn_selCon $chk_system $frm_orentationNote]]
				
				set rad_selConn [hwtk::radiobutton $frm_orentation.rad_selConn -value 2 -variable ::CustomConnectors::planeCreationType -text "Use Existing Orientation" -command [list ::CustomConnectors::OnClickPlaneCreation $cb_plane $btn_selCon $chk_system $frm_orentationNote]]

				# pack $lbl_plan -side left -anchor nw -padx 5 -pady 2;
				pack $rad_plan -side left -anchor nw -padx 2 -pady 2;
				pack $cb_plane  -side left -anchor nw -padx 5 -pady 4;
				# $cb_plane configure -state disable
				pack $rad_selConn -side left -anchor nw -padx 2 -pady 2;
				
			
			set ::CustomConnectors::frm_sysID [frame $frm_planeorentation.frm_sysID ]
			# pack $frm_sysID -side top -anchor sw;
			
				set ent_sysID [hwtk::entry $::CustomConnectors::frm_sysID.ent_sysID  -textvariable [namespace current]::n_sysID -state disable -width 10]
				pack $ent_sysID -anchor nw -padx 5;
				
				if {[string match -nocase "Normal Selection" $::CustomConnectors::nplanefine]} {
					set str_orentationNote "Note: First 2 nodes will specify Z-axis and all 3 nodes will specify \nplane for X-axis of local co-ordinate system"
				} elseif {[string match -nocase "Parallel Selection" $::CustomConnectors::nplanefine]} {
					set str_orentationNote "Note: First 2 nodes will specify X-axis and 2nd & 3rd nodes will \nspecify Z-axis of local co-ordinate system"
				} else {
					set str_orentationNote ""
				}
	
				# set lbl_orentationNote [ttk::label $frm_orentationNote.lbl_orentationNote -text $str_orentationNote -font [list -underline true -weight bold -slant italic] -justify left]
				set lbl_orentationNote [hwtk::label $frm_orentationNote.lbl_orentationNote -text $str_orentationNote -justify left]
				pack $lbl_orentationNote -side left -anchor nw -padx 5p -pady 5p;
				
				if {$::CustomConnectors::planeCreationType == 2} {
					$cb_plane configure -state disable
					$chk_system configure -state disable
					pack $btn_selCon -side bottom -anchor nw -padx 5;
					pack $::CustomConnectors::frm_sysID -side top -anchor c;
					if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {RibWeld} || $str_combovalue == {Snaps}} {
						$cb_plane configure -width 15
						catch {pack forget $frm_orentationNote}
					}
				} elseif {$::CustomConnectors::planeCreationType == 1} {
					if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {RibWeld} || $str_combovalue == {Snaps}} {
						pack $frm_orentationNote -side top -anchor nw;
						$cb_plane configure -width 15
					}
				}
				
			bind $cb_plane <<ComboboxSelected>> [list ::CustomConnectors::InPaneDefination $frm_orentationNote] 
		

		if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {Snaps}} {
		
			set frm_special [frame $frm_main.special ]
			pack $frm_special -side top -anchor nw  -pady 2 -padx 5;
			
			# set frm_loca [frame $frm_main.locatfram ]
			# pack $frm_loca -side top -anchor nw  -pady 2;
			
			set frm_splabfram [ttk::labelframe $frm_special.lbMain1 -text "Edge to Edge Contact for Explicit" -labelanchor n]
			pack $frm_splabfram -side top -anchor nw  -pady 5
			
			set label_elems [label $frm_splabfram.label_elems -text "Contact Elems"]
			set btn_elems [button [set frm_splabfram].btn_elems -text "Elems" -command "::CustomConnectors::EidsForLocators elems" -bg yellow  -highlightcolor blue -width 6]
			pack $label_elems -side left -anchor nw  -pady 7 -padx 5;
			pack $btn_elems -side left -anchor nw  -pady 7 -padx 30;
			
			# set ::CustomConnectors::n_locator 0
			# set ::CustomConnectors::spcCon 3
			set chk_locator [hwtk::checkbutton  $frm_special.chk_locator -text "Add Locator Connection" -variable ::CustomConnectors::n_locator]
			pack $chk_locator -anchor w -padx 5 -pady 5;
			
			# set frm_splabfram [ttk::labelframe $frm_special.lbMain1 -text "Add Locator Connection" -labelanchor n]
			# pack $frm_splabfram -side top -anchor nw  -pady 2
			
			set frm_locabt [frame $frm_special.frm_locabt ]
			pack $frm_locabt -side top -anchor nw -padx 10 -pady 2;
			
			# set frm_radioLoc [frame $frm_locabt.frm_radioLoc]
			# pack $frm_radioLoc -side top -anchor nw -pady 2;
			
			# set frm_loca [frame $frm_locabt.locatfram ]
			# pack $frm_loca -side top -anchor nw  -pady 2;
			
			# set rad_spImpl [hwtk::radiobutton  $frm_radioLoc.spciali -value 1 -text "Implict" -variable [namespace current]::spcCon -command [list ::CustomConnectors::ForlocatorGUi1 $frm_loca]]  
			
			# set rad_spExpl [hwtk::radiobutton  $frm_radioLoc.spciale -text "Explict" -value 3 -variable [namespace current]::spcCon -command [list ::CustomConnectors::ForlocatorGUi1 $frm_loca]] 
			
			# set rad_spNone [hwtk::radiobutton  $frm_locabt.spcialn -text "None" -value 0 -variable [namespace current]::spcCon -command [list ::CustomConnectors::ForlocatorGUi1 $frm_loca ]] 
			
			# pack $rad_spImpl -side left -anchor nw -padx 5 -pady 2;
			# pack $rad_spExpl -side left -anchor nw -padx 5 -pady 2;
			# pack $rad_spNone -side left -anchor nw -padx 5 -pady 2;
			
			# if {$::g_profile_name == {Pamcrash2G}} {
				# pack forget $rad_spImpl
			# } elseif {$::g_profile_name == {Nastran}} {
				# pack forget $rad_spExpl
			# }
			
			# if {$::CustomConnectors::spcCon == 3} {
				# ::CustomConnectors::ForlocatorGUi1 $frm_loca
			# }
			
			bind $chk_locator <ButtonRelease-1> [list ::CustomConnectors::OnClickLocatorCheckButton $frm_locabt] 
			
		}
		# puts $frm_selnd--frm_selnd
		# bind $entry_numlayers <FocusOut> [list ::CustomConnectors::OnNmberLinks $::CustomConnectors::numlayers]

		# bind $entry_numlayers <FocusIn> [list ::CustomConnectors::OnNmberLinks $::CustomConnectors::numlayers]
		# Separator [set frm_main] Horizontal
		set frm_matlist [frame $frm_main.matelist ]
		pack $frm_matlist -side top -anchor nw -padx 2 -pady 2;
		
		::CustomConnectors::UpdateUnitPath $frm_matlist
		
		Separator [set frm_main] Horizontal
		
		set frm_repimage [frame $frm_main.frmimage ]
		pack $frm_repimage -side top -anchor nw -padx 2 -pady 2;
		
		# ::CustomConnectors::LevelElemnts $frm_image 0
		set frm_locators [frame $frm_main.frm_locators ]
		pack $frm_locators -side top -anchor nw -padx 2 -pady 2;
		
		Separator [set frm_main] Horizontal
		set frm_Create [frame $frm_main.create ]
		pack $frm_Create -side top -anchor nw -padx 2 -pady 2;
		
		
		
		pack [hwtk::button [set frm_Create].create -text "Create"  -command ::CustomConnectors::OnConnCreate -help "Create" -width 25] -side left
		pack [hwtk::button [set frm_Create].modify -text "Modify"  -command [list ::CustomConnectors::OnModify] -help "Opens rerealize panel to modify"] -side left
		pack [hwtk::button [set frm_Create].delete -text "Delete"  -command [list ::CustomConnectors::OnDelete] -help "Deletes the recently created connector"] -side right -padx 5
		
		::CustomConnectors::LevelElemnts $frm_main.frmimage $::CustomConnectors::str_level
		
		# if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {RibWeld} || $str_combovalue == {Snaps}} {
			::CustomConnectors::ImageForLevel1_orientation $::CustomConnectors::nplanefine
		# }
		
		bind [set frm_Create].create  <Control-KeyPress-q> {puts asjklsdajlslk}
		# [list ::CustomConnectors::OnConnCreate]
		# if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} } {
		
			# ::CustomConnectors::ForlocatorGUi1 $frm_locators $str_combovalue
		# }

	return
	
}

proc ::CustomConnectors::RadioLevelSelector {str_unitFrame str_imageFrame n_level args} {
	
	variable str_combovalue
	variable arr_levelStateHolder
	
	::CustomConnectors::UpdateUnitPath $str_unitFrame
	::CustomConnectors::LevelElemnts $str_imageFrame $n_level
	::CustomConnectors::ImageForLevel1_orientation $::CustomConnectors::nplanefine
	
	set arr_levelStateHolder($str_combovalue) $n_level
	
	return;
}

proc ::CustomConnectors::OnClickLocatorCheckButton {frm_main1 args} {
	
	variable arr_btn
	variable arr_inputNods
	
	# puts $::CustomConnectors::n_locator------------n_locator
	if {$::CustomConnectors::n_locator == 0} {
		
		pack $frm_main1 -side top -anchor nw -padx 15 -pady 2;
		catch {destroy $frm_main1.frm_mainfrm1}
		set frm_mainfrm1 [ttk::labelframe $frm_main1.frm_mainfrm1 -text "Nodes Input" -labelanchor n]
		pack $frm_mainfrm1 -side top -anchor nw  -pady 2 -padx 7;
		
		set frm_selnd [frame $frm_mainfrm1.frm_selnd ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal
		
		set label_X [label $frm_selnd.label_numlayers -text "X-Locator"]
		set arr_btn(x1) [button [set frm_selnd].btn_x1 -text "Part-1" -command "::CustomConnectors::NodeForLocators x1" -bg "#5FB5FF" -width 7]
		set arr_btn(x2) [button [set frm_selnd].btn_x2 -text "Part-2" -command "::CustomConnectors::NodeForLocators x2" -bg "#4775DE" -fg "white" -width 7]
		pack $label_X -side left -anchor nw  -pady 5 -padx 5;
		pack $arr_btn(x1) -side left -anchor nw  -pady 5 -padx 15;
		pack $arr_btn(x2) -side left -anchor nw  -pady 5 -padx 3;

		set frm_selnd [frame $frm_mainfrm1.frm_selnd1 ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal

		set label_X [label $frm_selnd.label_numlayers -text "Y-Locator"]
		set arr_btn(y1) [button [set frm_selnd].btn_x1 -text "Part-1" -command "::CustomConnectors::NodeForLocators y1" -bg "#FFB317" -width 7]
		set arr_btn(y2) [button [set frm_selnd].btn_x2 -text "Part-2" -command "::CustomConnectors::NodeForLocators y2" -bg "#835317" -fg "white" -width 7]
		pack $label_X -side left -anchor nw  -pady 5 -padx 5;
		pack $arr_btn(y1) -side left -anchor nw  -pady 5 -padx 15;
		pack $arr_btn(y2) -side left -anchor nw  -pady 5 -padx 3;

		set frm_selnd [frame $frm_mainfrm1.frm_selnd2 ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal

		set label_X [label $frm_selnd.label_numlayers -text "Z-Locator"]
		set arr_btn(z1) [button [set frm_selnd].btn_x1 -text "Part-1" -command "::CustomConnectors::NodeForLocators z1" -bg "#FC3EFF" -width 7]
		set arr_btn(z2) [button [set frm_selnd].btn_x2 -text "Part-2" -command "::CustomConnectors::NodeForLocators z2" -bg "#811B7E" -fg "white" -width 7]
		pack $label_X -side left -anchor nw  -pady 5 -padx 5;
		pack $arr_btn(z1) -side left -anchor nw  -pady 5 -padx 15;
		pack $arr_btn(z2) -side left -anchor nw  -pady 5 -padx 3;
		
	} elseif {$::CustomConnectors::n_locator == 1} {
	
		pack forget $frm_main1
		catch {
			$frm_main1 configure -height 1
			destroy $frm_main1.frm_mainfrm1
			unset arr_inputNods(x1,nids)
			unset arr_inputNods(x2,nids)
			unset arr_inputNods(y1,nids)
			unset arr_inputNods(y2,nids)
			unset arr_inputNods(z1,nids)
			unset arr_inputNods(z2,nids)
			unset arr_btn(x1)
			unset arr_btn(x2)
			unset arr_btn(y1)
			unset arr_btn(y2)
			unset arr_btn(z1)
			unset arr_btn(z2)
		}
	}
}

proc ::CustomConnectors::ForlocatorGUi1 {frm_main1 args} {
	
	# set args $::CustomConnectors::spcCon
	variable lstConnection
	variable str_combovalue
	variable str_Cname
	variable str_eids
	variable str_Relizeeids
	variable lstProps
	variable lstMAts
	variable str_sytemopt 
	variable arr_btn
	variable arr_inputNods
	# puts $args--args
	
	if {$::CustomConnectors::spcCon == 1} {
		
		catch {destroy $frm_main1.frm_mainfrm1}
		set frm_mainfrm1 [frame $frm_main1.frm_mainfrm1 ]
		pack $frm_mainfrm1 -side top -anchor nw  -pady 2 -padx 7;
		
		set frm_selnd [frame $frm_mainfrm1.frm_selnd ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal
		
		set label_X [label $frm_selnd.label_numlayers -text "X Dir Nodes"]
		set arr_btn(x1) [button [set frm_selnd].btn_x1 -text "Nodes-1" -command "::CustomConnectors::NodeForLocators x1" -bg skyblue  -highlightcolor blue]
		set arr_btn(x2) [button [set frm_selnd].btn_x2 -text "Nodes-2" -command "::CustomConnectors::NodeForLocators x2" -bg skyblue  -highlightcolor blue]
		pack $label_X -side left -anchor nw  -pady 2 -padx 5;
		pack $arr_btn(x1) -side left -anchor nw  -pady 2 -padx 15;
		pack $arr_btn(x2) -side left -anchor nw  -pady 2 -padx 3;

		set frm_selnd [frame $frm_mainfrm1.frm_selnd1 ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal

		set label_X [label $frm_selnd.label_numlayers -text "Y Dir Nodes"]
		set arr_btn(y1) [button [set frm_selnd].btn_x1 -text "Nodes-1" -command "::CustomConnectors::NodeForLocators y1" -bg orange  -highlightcolor blue]
		set arr_btn(y2) [button [set frm_selnd].btn_x2 -text "Nodes-2" -command "::CustomConnectors::NodeForLocators y2" -bg orange  -highlightcolor blue]
		pack $label_X -side left -anchor nw  -pady 2 -padx 5;
		pack $arr_btn(y1) -side left -anchor nw  -pady 2 -padx 15;
		pack $arr_btn(y2) -side left -anchor nw  -pady 2 -padx 3;

		set frm_selnd [frame $frm_mainfrm1.frm_selnd2 ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal

		set label_X [label $frm_selnd.label_numlayers -text "Z Dir Nodes"]
		set arr_btn(z1) [button [set frm_selnd].btn_x1 -text "Nodes-1" -command "::CustomConnectors::NodeForLocators z1" -bg pink  -highlightcolor blue]
		set arr_btn(z2) [button [set frm_selnd].btn_x2 -text "Nodes-2" -command "::CustomConnectors::NodeForLocators z2" -bg pink  -highlightcolor blue]
		pack $label_X -side left -anchor nw  -pady 2 -padx 5;
		pack $arr_btn(z1) -side left -anchor nw  -pady 2 -padx 15;
		pack $arr_btn(z2) -side left -anchor nw  -pady 2 -padx 3;

	} elseif {$::CustomConnectors::spcCon == 3} {
	
		catch {destroy $frm_main1.frm_mainfrm1}
		set frm_mainfrm1 [frame $frm_main1.frm_mainfrm1 ]
		pack $frm_mainfrm1 -side top -anchor nw  -pady 2 -padx 7;
		
		set frm_selnd [frame $frm_mainfrm1.frm_selnde ]
		pack $frm_selnd -side top -anchor nw  -pady 2;
		# Separator [set frm_selnd] Horizontal -fill x
		
		set label_X [label $frm_selnd.label_numlayers -text "Contact Elems"]
		set arr_btn(eids) [button [set frm_selnd].btn_x2 -text "Elems" -command "::CustomConnectors::EidsForLocators elems" -bg yellow  -highlightcolor blue -width 6]
		pack $label_X $arr_btn(eids)  -side left -anchor nw  -pady 2 -padx 5;
		
	} else {
	
		catch {
			$frm_main1 configure -height 1
			destroy $frm_main1.frm_mainfrm1
			unset arr_inputNods(x1,nids)
			unset arr_inputNods(x2,nids)
			unset arr_inputNods(y1,nids)
			unset arr_inputNods(y2,nids)
			unset arr_inputNods(z1,nids)
			unset arr_inputNods(z2,nids)
			unset arr_btn(x1)
			unset arr_btn(x2)
			unset arr_btn(y1)
			unset arr_btn(y2)
			unset arr_btn(z1)
			unset arr_btn(z2)
		}
	}
	
	return
}





proc ::CustomConnectors::ForlocatorGUi {frm_main1 args} {
	
	variable lstConnection
	variable fl_help_Locators
	variable imagePath
	variable str_combovalue
	variable str_Cname
	variable str_eids
	variable str_Relizeeids
	variable lstProps
	variable lstMAts
	variable str_sytemopt 
	variable arr_btn
	set ::CustomConnectors::str_level 1
	set ::CustomConnectors::spcCon_b4Loc $::CustomConnectors::spcCon
	set ::CustomConnectors::spcCon 0
	*clearmarkall 1
	*clearmarkall 2
	catch {unset arr_btn}

	
	set frm_unitSystem [frame $frm_main1.units ]
	pack $frm_unitSystem -side top -anchor nw -padx 2 -pady 2;
	set lb_Uit [ttk::label [set frm_unitSystem].inilab -text "Connector Unit System" -width 20]
	set cb_uit [hwtk::combobox $frm_unitSystem.unicb -textvariable "::CustomConnectors::unit" -state disabled -values $::CustomConnectors::unitSystem -width 15 ]
	pack $lb_Uit -side left -anchor nw -padx 2 -pady 2;
	pack $cb_uit -side left -anchor nw -padx 2 -pady 2;
	
	set frm_main [ttk::labelframe $frm_main1.lbMain1 -labelanchor n]
	pack $frm_main -side top -anchor n -padx 5 -pady 2
	

	set btnCreate [label [set frm_main].label -text "$args" -font [list -size 12 -weight bold]]
	$frm_main configure -labelwidget $btnCreate
	
	set frm_mainfrm1 [frame $frm_main.frm_mainfrm1 ]
	pack $frm_mainfrm1 -side top -anchor nw -padx 2 -pady 2 -fill x -expand 1;
	Separator [set frm_main] Horizontal
		set frm_mainfrm3 [frame $frm_main.frm_mainfrm3 ]
	pack $frm_mainfrm3 -side top -anchor nw -padx 2 -pady 2;
		

		# set level0 [hwtk::radiobutton $frm_mainfrm1.level0 -value 0 -variable ::CustomConnectors::str_level -text "Level-0" -command [list ::CustomConnectors::LevelElemnts $frm_main.frmimage 0]]
		set level1 [hwtk::radiobutton $frm_mainfrm1.level1 -value 1 -variable ::CustomConnectors::str_level -text "Implicit" -command [list ::CustomConnectors::LevelElemnts $frm_main.frmimage 1]]
		
		set dynaExp [hwtk::radiobutton $frm_mainfrm1.level3 -value 3 -variable ::CustomConnectors::str_level -text "Explicit" -command [list ::CustomConnectors::LevelElemnts $frm_main.frmimage 3]]
		
		
		pack $level1 -side left -anchor nw -padx 2 -pady 2;
		pack $dynaExp -side left -anchor nw -padx 2 -pady 2;
		
		# set level2 [hwtk::radiobutton $frm_mainfrm1.level2 -value 2 -variable ::CustomConnectors::str_level -text "Level-2" -command [list ::CustomConnectors::LevelElemnts $frm_main.frmimage 2] -state disable]
		# pack $level0 -side left -anchor nw -padx 2 -pady 2;
		# pack $level1 -side left -anchor nw -padx 2 -pady 2;
		# pack $level2 -side left -anchor nw -padx 2 -pady 2;
		
		#####Help button#########
		set img_help [image create photo imgHelp -file [file join $imagePath help-16.png]]
		set btn_help [hwtk::button $frm_mainfrm1.btn_help -image $img_help -command [list ::CustomConnectors::CallOnHelpButtons $fl_help_Locators]]
		pack $btn_help -side left -anchor ne -padx 2 -pady 2 -expand 1;
		#########################
		
		if {$::g_profile_name == {Nastran} || $::g_profile_name == {OptiStruct}} {
			pack forget $dynaExp
			set ::CustomConnectors::str_level 1
		} elseif {$::g_profile_name == {Pamcrash2G}} {
			pack forget $level1
			set ::CustomConnectors::str_level 3
		}

		set frm_auto [frame $frm_mainfrm3.frm_auto ]
		pack $frm_auto -side left -anchor nw -padx 2 -pady 2;
		
		# set radio_auto [hwtk::radiobutton $frm_auto.radio_auto -value 1 -variable ::CustomConnectors::selectionType -text "Semiautomatic" -command ""]
		# pack $radio_auto -side left -anchor nw -padx 2 -pady 2;
		
		# set frm_sep15 [frame $frm_mainfrm3.frm_sep15]
		# pack $frm_sep15 -side left -fill both;
		# Separator [set frm_sep15] Vertical

		# set frm_manual [frame $frm_mainfrm3.frm_manual ]
		# pack $frm_manual -side left -anchor nw -padx 2 -pady 2;
		set ::CustomConnectors::selectionType 0
		set radio_manual [hwtk::radiobutton $frm_auto.radio_manual -value 0 -variable ::CustomConnectors::selectionType -text "Manual" -command ""]
		pack $radio_manual -side left -anchor nw -padx 2 -pady 2;
		
		Separator [set frm_main] Horizontal
		# set str_Cname ${str_combovalue}_
		
		##################
		set frm_mainfrm4 [frame $frm_main.frm_mainfrm4 ]
		pack $frm_mainfrm4 -side top -anchor nw -padx 2 -pady 2;
		
		###################
	
		# pack $lbl_1 -side left -anchor w  -pady 2;
		# pack $cb_1 -side left -anchor w  -pady 2;
		
		
		###################3333
		set frm_namewld [frame $frm_mainfrm4.frm_namewld ]
		pack $frm_namewld -side top -anchor nw -padx 2 -pady 2;
		
		set label_namewld [label $frm_namewld.label_namewld -text "Name weld component" -width 20]
		pack $label_namewld -side left -anchor w -pady 2;
		
		set entry_namewld [entry $frm_namewld.entry_namewld  -textvariable [namespace current]::str_Cname -state disable]
		pack $entry_namewld -side left -anchor w -pady 2;
		
		############
		set frm_selcomp [frame $frm_mainfrm4.frm_selcomp ]
		pack $frm_selcomp -side top -anchor nw  -pady 2;
		
		# set label_selcomp [label $frm_selcomp.label_selcomp -text "Select component" -width 20]
		# pack $label_selcomp -side left -anchor w  -pady 2;
		
		# set btn_selcomp [button $frm_selcomp.btn_selcomp  -text " Select " -command "::CustomConnectors::SelComps" ]
		# pack $btn_selcomp -side left -anchor w  -pady 2;
		
		##############
		set frm_numlayers [ttk::labelframe $frm_main.frm_numlayers -text "Nodes Input" -labelanchor n]
		pack $frm_numlayers -side top -anchor nw -padx 2p -pady 5p;

		set frm_selnd [frame $frm_numlayers.frm_selnd ]
		pack $frm_selnd -side top -anchor nw -padx 2p -pady 2p;
		# Separator [set frm_selnd] Horizontal
		set label_X [label $frm_selnd.label_numlayers -text "X-Locator" -width 15]
		set arr_btn(x1) [button [set frm_selnd].btn_x1 -text "Part-1" -command "::CustomConnectors::NodeForLocators x1" -bg "#5FB5FF" -width 7]
		set arr_btn(x2) [button [set frm_selnd].btn_x2 -text "Part-2" -command "::CustomConnectors::NodeForLocators x2" -bg "#4775DE" -fg "white" -width 7]
		pack $label_X $arr_btn(x1) $arr_btn(x2) -side left -anchor w  -pady 2 -padx 5;
		
		
		set frm_selnd [frame $frm_numlayers.frm_selnd1 ]
		pack $frm_selnd -side top -anchor nw -padx 2p -pady 2p;
		Separator [set frm_selnd] Horizontal
		
		set label_X [label $frm_selnd.label_numlayers -text "Y-Locator" -width 15]
		set arr_btn(y1) [button [set frm_selnd].btn_x1 -text "Part-1" -command "::CustomConnectors::NodeForLocators y1" -bg "#FFB317" -width 7]
		set arr_btn(y2) [button [set frm_selnd].btn_x2 -text "Part-2" -command "::CustomConnectors::NodeForLocators y2" -bg "#835317" -fg "white" -width 7]
		pack $label_X $arr_btn(y1) $arr_btn(y2) -side left -anchor w  -pady 2 -padx 5;
		
		set frm_selnd [frame $frm_numlayers.frm_selnd2 ]
		pack $frm_selnd -side top -anchor nw -padx 2p -pady 2p;
		Separator [set frm_selnd] Horizontal
		
		set label_X [label $frm_selnd.label_numlayers -text "Z-Locator" -width 15]
		set arr_btn(z1) [button [set frm_selnd].btn_x1 -text "Part-1" -command "::CustomConnectors::NodeForLocators z1" -bg "#FC3EFF" -width 7]
		set arr_btn(z2) [button [set frm_selnd].btn_x2 -text "Part-2" -command "::CustomConnectors::NodeForLocators z2" -bg "#811B7E" -fg "white" -width 7]
		pack $label_X $arr_btn(z1) $arr_btn(z2) -side left -anchor w  -pady 2 -padx 5;
		
		set frm_selnd [frame $frm_main.frm_selnde ]
		pack $frm_selnd -side top -anchor nw -padx 2p -pady 2p;
		# Separator [set frm_selnd] Horizontal -fill x
		
		set label_X [label $frm_selnd.label_numlayers -text "Contact Elems" -width 15]
		set arr_btn(eids) [button [set frm_selnd].btn_x2 -text "Elems" -command "::CustomConnectors::EidsForLocators elems" -bg yellow -width 7]
		pack $label_X $arr_btn(eids)  -side left -anchor w  -pady 2 -padx 5;

		set frm_image [frame $frm_main.frmimage ]
		pack $frm_image -side top -anchor nw -padx 2 -pady 2;
		Separator [set frm_image] Horizontal
		Separator [set frm_main] Horizontal
		set frm_Create [frame $frm_main.create ]
		pack $frm_Create -side top -anchor nw -padx 2 -pady 2;
		pack [hwtk::button [set frm_Create].create -text "Create"  -command ::CustomConnectors::OnConnCreate -help "Create" -width 25] -side left
		pack [hwtk::button [set frm_Create].modify -text "Modify"  -command [list :::CustomConnectors::OnModify] -help "Opens rerealize panel to modify"] -side left
		pack [hwtk::button [set frm_Create].delete -text "Delete"  -command [list ::CustomConnectors::OnDelete] -help "Deletes the recently created connector"] -side right -padx 5
		
		::CustomConnectors::LevelElemnts $frm_main.frmimage $::CustomConnectors::str_level

	return
}

proc ::CustomConnectors::PlaneDefGUI {frm_1 args} {
	
	catch {destroy $frm_1.frm_nodeButtons}
	catch {pack $frm_1 -side top -anchor nw}
	set frm_nodeButtons [frame $frm_1.frm_nodeButtons]
	pack $frm_nodeButtons -side top -anchor nw -padx 5 -pady 5;
	
		for {set i 1} { $i <= 3} {incr i} {
			if {$i == 1} {
				set ncol green
			} elseif {$i == 2} {
				set ncol blue
			} elseif {$i == 3} {
				set ncol red
			}
			
			set arr_btn(Node-${i}) [button [set frm_nodeButtons].btn_$i  -text " N${i}" -command "::CustomConnectors::SelectNodes_vector [expr ($i + 10)]" -bg $ncol -width 10]
			pack $arr_btn(Node-${i}) -side left -anchor nw -pady 2;
		}
		
	return;
}

proc ::CustomConnectors::OnClickPlaneCreation {str_cbPath str_btnPath str_chksystem frm_orentationNote args} {
	
	variable str_sytemopt
	variable str_combovalue
	
	if {$::CustomConnectors::planeCreationType == 1} {
		catch {pack forget $::CustomConnectors::frm_sysID}
		pack forget $str_btnPath
		$str_cbPath configure -state readonly
		$str_chksystem configure -state enable
		set str_sytemopt 1
		if {$str_combovalue == {MetalClip} || $str_combovalue == {PlasticClip} || $str_combovalue == {RibWeld} || $str_combovalue == {Snaps}} {
			set lst_orientationstypes [list "Normal Selection" "Parallel Selection"]
			set ::CustomConnectors::nplanefine [lindex $lst_orientationstypes 0]
			$str_cbPath configure -values $lst_orientationstypes
			set str_orentationNote "Note: First 2 nodes will specify Z-axis and all 3 nodes will specify \nplane for X-axis of local co-ordinate system"
			set w $frm_orentationNote.lbl_orentationNote
			if {[winfo exists $w]} {
				$w configure -text $str_orentationNote
			}
			catch {pack $frm_orentationNote -side top -anchor nw;}
			::CustomConnectors::ImageForLevel1_orientation "Normal Selection"
		}
	} elseif {$::CustomConnectors::planeCreationType == 2} {
		catch {pack forget $frm_orentationNote}
		$str_cbPath configure -state disable
		$str_chksystem configure -state disable
		set str_sytemopt 0
		pack $::CustomConnectors::frm_sysID -side top -anchor c;
		pack $str_btnPath -side bottom -anchor nw -padx 5;
	}
}

proc ::CustomConnectors::OnClickPlaneCreation_Modify {str_type str_cbPath str_btnPath frm_orentationNote args} {
	
	if {$::CustomConnectors::planeCreationType_modify == 1} {
		pack forget $str_btnPath
		$str_cbPath configure -state readonly
		if {$str_type == {MetalClip} || $str_type == {PlasticClip} || $str_type == {RibWeld} || $str_type == {Snaps}} {
			set lst_orientationstypes [list "Normal Selection" "Parallel Selection"]
			set ::CustomConnectors::nplanefine_modify [lindex $lst_orientationstypes 0]
			$str_cbPath configure -values $lst_orientationstypes
			set str_orentationNote "Note: First 2 nodes will specify Z-axis and all 3 nodes will specify \nplane for X-axis of local co-ordinate system"
			set w $frm_orentationNote.lbl_orentationNote
			if {[winfo exists $w]} {
				$w configure -text $str_orentationNote
			}
			catch {pack $frm_orentationNote -side top -anchor nw;}
			# ::CustomConnectors::ImageForLevel1_orientation "Normal Selection"
		}
	} elseif {$::CustomConnectors::planeCreationType_modify == 2} {
		catch {pack forget $frm_orentationNote}
		catch {$str_cbPath configure -state disable
		pack $str_btnPath -side bottom -anchor nw -padx 5;}
	}
}

proc ::CustomConnectors::OnSelectCon {args} {
	
	variable n_sysExistingID;
	*createmarkpanel systems 1 "select the system with desired orientation"
	if {![hm_marklength systems 1]} {
		tk_messageBox -message "System is not selected." -type ok -icon warning 
		return
	}
	set n_sysExistingID [lindex [hm_getmark systems 1] 0]
	set ::CustomConnectors::n_sysID $n_sysExistingID
	
	# set ::CustomConnectors::nVector [::MetaData::GetMetadataByMark connectors $n_con vector]
	set ::CustomConnectors::nVector [hm_getvalue systems id=$n_sysExistingID dataname=xaxis]
	set ::CustomConnectors::n_yVector [hm_getvalue systems id=$n_sysExistingID dataname=yaxis]
	
	return;
}

proc ::CustomConnectors::OnSelectCon_Modify {n_con args} {
	
	*createmarkpanel systems 1 "select the system with desired orientation"
	if {![hm_marklength systems 1]} {
		tk_messageBox -message "System is not selected." -type ok -icon warning 
		return
	}
	
	set ::CustomConnectors::n_sysID_modify [lindex [hm_getmark systems 1] 0]
	set ::CustomConnectors::nVector [hm_getvalue systems id=$::CustomConnectors::n_sysID_modify dataname=xaxis]
	set n_yVector [hm_getvalue systems id=$::CustomConnectors::n_sysID_modify dataname=yaxis]
	# set lst_sysMeta [::MetaData::GetMetadataByMark connectors $n_con sysCre]
	# set lst_newSysMeta [lreplace $lst_sysMeta end end $::CustomConnectors::n_sysID_modify]
	set lst_newSysMeta [list 2 $::CustomConnectors::n_sysID_modify $n_yVector]
	::MetaData::CreateMetadata connectors $n_con sysCre $lst_newSysMeta
	::MetaData::CreateMetadata connectors $n_con vector $::CustomConnectors::nVector
	
	set str_conGroup "system_$::CustomConnectors::n_sysID_modify"
	if {[hm_entityinfo exist connectorgroup $str_conGroup]} {
		*createmark connectors 1 $n_con
		*movemark connectors 1 $str_conGroup
	}
	
	return;
}

proc ::CustomConnectors::MakePlane {args} {

	variable arr_inputNods
	variable nVector
	set lstnodes [list]
	foreach n [array name arr_inputNods *,vector_nodes] {
		# puts $n-----n
		lappend lstnodes $arr_inputNods($n)
	}
	if {[llength $lstnodes] > 2} {

		set vec1 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 0]]] [join [hm_nodevalue [lindex $lstnodes 1]]]]
		set vec2 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 1]]] [join [hm_nodevalue [lindex $lstnodes 2]]]]
		set ncVec [::hwat::math::VectorCrossProduct  $vec1 $vec2]
		set nVector [::hwat::math::VectorNormalize $ncVec]
	
	} else {
		
		set vec1 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 0]]] [join [hm_nodevalue [lindex $lstnodes 1]]]]
		set nVector [::hwat::math::VectorNormalize $vec1]
	}
	# puts "lstnodes-----$lstnodes  $nVector --------nVector"
	*clearmarkall 1
}

proc ::CustomConnectors::InPaneDefination {frm_orentationNote args} {

	variable nVector
	variable n_yVector
	
	set n_yVector 0;
	
	if {$::CustomConnectors::nplanefine == {X-Global}} {
		catch {pack forget $frm_orentationNote}
		set ::CustomConnectors::nVector {1.0 0.0 0.0}
	} elseif {$::CustomConnectors::nplanefine == {Y-Global}} {
		catch {pack forget $frm_orentationNote}
		set ::CustomConnectors::nVector {0.0 1.0 0.0}
	} elseif {$::CustomConnectors::nplanefine == {Z-Global}} {
		catch {pack forget $frm_orentationNote}
		set ::CustomConnectors::nVector {0.0 0.0 1.0}
	} elseif {[string match -nocase "Normal Selection" $::CustomConnectors::nplanefine]} {
		set str_orentationNote "Note: First 2 nodes will specify Z-axis and all 3 nodes will specify \nplane for X-axis of local co-ordinate system"
		set w $frm_orentationNote.lbl_orentationNote
		if {[winfo exists $w]} {
			$w configure -text $str_orentationNote
		}
		catch {pack $frm_orentationNote -side top -anchor nw;}
		::CustomConnectors::ImageForLevel1_orientation "Normal Selection"
		::CustomConnectors::MakeLocalCoordinateSystem "Normal Selection"
	} elseif {[string match -nocase "Parallel Selection" $::CustomConnectors::nplanefine]} {
		set str_orentationNote "Note: First 2 nodes will specify X-axis and 2nd & 3rd nodes will \nspecify Z-axis of local co-ordinate system"
		set w $frm_orentationNote.lbl_orentationNote
		if {[winfo exists $w]} {
			$w configure -text $str_orentationNote
		}
		catch {pack $frm_orentationNote -side top -anchor nw;}
		::CustomConnectors::ImageForLevel1_orientation "Parallel Selection"
		::CustomConnectors::MakeLocalCoordinateSystem "Parallel Selection"
	} else {
		catch {pack forget $frm_orentationNote}
		set nVector [join [hm_getdirectionpanel]]
		# set lst_nodeCoords [list]
		# lassign [hm_getdirectionpanel "Please define a direction" N1N2N3 1] nVector lst_nodeCoords
		# if {$::CustomConnectors::str_sytemopt} {
			# if {[llength $lst_nodeCoords] == 9} {
				# lassign $lst_nodeCoords x1 y1 z1 x2 y2 z2 x3 y3 z3
				# set n_yVector [::hwat::math::GetVector [list $x1 $y1 $z1] [list $x2 $y2 $z2]]
			# } else {
				# set n_yVector 0;
			# }
		# }
	}
	
	# if {$::CustomConnectors::str_sytemopt} {
		# set str_ret [tk_messageBox -title "Fixation Modelling Tool" \
								-message "Do you want to define the Y direction?" \
								-type yesno \
								-icon question]
			
		# if {$str_ret == "yes"} {
			# set n_yVector [join [hm_getdirectionpanel]]
		# }
		# puts $n_yVector----------n_yVector
	# }
	return;
}

proc ::CustomConnectors::InPaneDefinition_Modify {frm_orentationNote args} {

	variable nVector
	variable n_yVector
	
	set n_yVector 0;
	
	if {$::CustomConnectors::nplanefine_modify == {X-Global}} {
		catch {pack forget $frm_orentationNote}
		set ::CustomConnectors::nVector {1.0 0.0 0.0}
	} elseif {$::CustomConnectors::nplanefine_modify == {Y-Global}} {
		catch {pack forget $frm_orentationNote}
		set ::CustomConnectors::nVector {0.0 1.0 0.0}
	} elseif {$::CustomConnectors::nplanefine_modify == {Z-Global}} {
		catch {pack forget $frm_orentationNote}
		set ::CustomConnectors::nVector {0.0 0.0 1.0}
	} elseif {[string match -nocase "Normal Selection" $::CustomConnectors::nplanefine_modify]} {
		set str_orentationNote "Note: First 2 nodes will specify Z-axis and all 3 nodes will specify \nplane for X-axis of local co-ordinate system"
		set w $frm_orentationNote.lbl_orentationNote
		if {[winfo exists $w]} {
			$w configure -text $str_orentationNote
		}
		catch {pack $frm_orentationNote -side top -anchor nw;}
		# ::CustomConnectors::ImageForLevel1_orientation "Normal Selection"
		::CustomConnectors::MakeLocalCoordinateSystem "Normal Selection"
	} elseif {[string match -nocase "Parallel Selection" $::CustomConnectors::nplanefine_modify]} {
		set str_orentationNote "Note: First 2 nodes will specify X-axis and 2nd & 3rd nodes will \nspecify Z-axis of local co-ordinate system"
		set w $frm_orentationNote.lbl_orentationNote
		if {[winfo exists $w]} {
			$w configure -text $str_orentationNote
		}
		catch {pack $frm_orentationNote -side top -anchor nw;}
		# ::CustomConnectors::ImageForLevel1_orientation "Parallel Selection"
		::CustomConnectors::MakeLocalCoordinateSystem "Parallel Selection"
	} else {
		catch {pack forget $frm_orentationNote}
		set nVector [join [hm_getdirectionpanel]]
	}
	
	if {0} {
		set str_ret [tk_messageBox -title "Fixation Modelling Tool" \
								-message "Do you want to define the Y direction?" \
								-type yesno \
								-icon question]
			
		if {$str_ret == "yes"} {
			set n_yVector [join [hm_getdirectionpanel]]
		}
		#puts $n_yVector----------n_yVector
	}
	return;
}

proc ::CustomConnectors::GetPlaneRet {args} {
	
	# puts $args---args
	set ::CustomConnectors::nVector [join $args]
	if {[join $args] == {1.0 0.0 0.0}} {
		 set ::CustomConnectors::nplanefine X
	} elseif {[join $args] == {0.0 1.0 0.0}} {
		 set ::CustomConnectors::nplanefine Y
	} elseif {[join $args] == {0.0 0.0 1.0}} {
		 set ::CustomConnectors::nplanefine Z
	} else {
		set ::CustomConnectors::nplanefine [lindex $::CustomConnectors::lstplane end]
	}
}

proc ::CustomConnectors::OnModify {args} {
	
	variable str_combovalue
	# ::CustomConnectors::OnCreate2 Rerealize
	# set ncon [hm_latestentityid connector]
	# if {[hm_entityinfo exist connectors $ncon]} {
	
	# }
	# puts comaskjslk
	# set str_combovalue Rerealize
	# ::CustomConnectors::OnCreate2 
	
	set ncon [hm_latestentityid connector]
	if {![string is space $ncon] && $ncon != 0} {
		::CustomConnectors::GUIForUpdate $ncon $str_combovalue
	} else {
		tk_messageBox -message "No latest connector is found in the model..!"
	}
		
	return
}

proc ::CustomConnectors::OnDelete {args} {
	
	set ncon [hm_latestentityid connector]
	if {![string is space $ncon] && $ncon != 0} {
		set str_connType [::MetaData::GetMetadataByMark connectors $ncon ctype]
		set strVal [tk_messageBox -message "Are you sure you want to delete the last created connector?\n(Type - $str_connType and ID - $ncon)" -icon question -type yesno -title "Delete Connector"]
		if {$strVal == {no}} {
			return
		}
		::CustomConnectors::Unrealize $ncon
		eval *createmark connectors 1 $ncon
		if {[hm_marklength connectors 1]} {
			*deletemark connectors 1
		}
		*clearmark connectors 1
	} else {
		tk_messageBox -message "No latest connector is found in the model..!"
	}

	return
}

proc ::CustomConnectors::MakeLocalCoordinateSystem {str_type args} {
	
	variable nVector
	variable n_yVector
	variable lsttags
	variable lst_dirNodeTags
	set lstnodes [list]
	
	eval *createmark tags 1 [join $lst_dirNodeTags]
	if {[hm_marklength tags 1]} {
		*deletemark tags 1
	}
	set lst_dirNodeTags ""
	*clearlist nodes 1
	
	catch {*createlistpanel nodes 1 "Select 3 nodes"}
	set lstnodes [hm_getlist nodes 1]
	if {[llength $lstnodes] != 3} {
		tk_messageBox -message "Please select 3 nodes.\nCurrent selection = [llength $lstnodes] nodes." -icon error -type ok
		*clearlist nodes 1
		return
	}
	# puts $lstnodes-----lstnodes
	if {[llength $lstnodes] == 3} {
		if {$str_type == "Normal Selection"} {
			set vec1 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 0]]] [join [hm_nodevalue [lindex $lstnodes 1]]]]
			set vec2 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 1]]] [join [hm_nodevalue [lindex $lstnodes 2]]]]
			set ncVec [::hwat::math::VectorCrossProduct $vec1 $vec2]
			set nVector [::hwat::math::VectorNormalize $ncVec]
			set ncVec1 [::hwat::math::VectorCrossProduct $vec1 $nVector]
			set n_yVector [::hwat::math::VectorNormalize $ncVec1]
		} else {
			set vec1 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 0]]] [join [hm_nodevalue [lindex $lstnodes 1]]]]
			set nVector [::hwat::math::VectorNormalize $vec1]
			set vec2 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 1]]] [join [hm_nodevalue [lindex $lstnodes 2]]]]
			set ncVec [::hwat::math::VectorCrossProduct $vec2 $nVector]
			set n_yVector [::hwat::math::VectorNormalize $ncVec]
		}
		lappend lst_dirNodeTags [::CustomConnectors::TagCreateIcon1 [lindex $lstnodes 0] "N1" 4]
		lappend lst_dirNodeTags [::CustomConnectors::TagCreateIcon1 [lindex $lstnodes 1] "N2" 29]
		lappend lst_dirNodeTags [::CustomConnectors::TagCreateIcon1 [lindex $lstnodes 2] "N3" 3]
		eval lappend lsttags $lst_dirNodeTags
	} 
	
	# else {
		# set vec1 [::hwat::math::GetVector [join [hm_nodevalue [lindex $lstnodes 0]]] [join [hm_nodevalue [lindex $lstnodes 1]]]]
		# set nVector [::hwat::math::VectorNormalize $vec1]
		# set n_yVector 0
		# lappend lst_dirNodeTags [::CustomConnectors::TagCreateIcon1 [lindex $lstnodes 0] "N1" 4]
		# lappend lst_dirNodeTags [::CustomConnectors::TagCreateIcon1 [lindex $lstnodes 1] "N2" 29]
		# eval lappend lsttags $lst_dirNodeTags
	# }
	
	*clearlist nodes 1

	return
}


proc ::CustomConnectors::OnReRealize {frm_main1} {

	variable lstConnection
	variable str_combovalue
	variable str_Cname
	variable str_eids
	variable lstEidsRealize
	variable fl_help_manageFixaton
	
	# ::CustomConnectors::TogglePerformance "off"
	
	::CustomConnectors::CheckUnit
	
	set frm_unitSystem [frame $frm_main1.units ]
	pack $frm_unitSystem -side top -anchor nw -padx 2 -pady 2;
	set lb_Uit [ttk::label [set frm_unitSystem].inilab -text "Connector Unit System" -width 20]
	set cb_uit [hwtk::combobox $frm_unitSystem.unicb -textvariable "::CustomConnectors::unit" -state readonly -values $::CustomConnectors::unitSystem -width 15 ]
	# puts $cb_uit-----------cb_uit
	pack $lb_Uit -side left -anchor nw -padx 2 -pady 5;
	pack $cb_uit -side left -anchor nw -padx 2 -pady 5;
	
	#####Help button#########
	set img_help [image create photo imgHelp -file [file join $::CustomConnectors::imagePath help-16.png]]
	set btn_help [hwtk::button $frm_unitSystem.btn_help -image $img_help -command [list ::CustomConnectors::CallOnHelpButtons $fl_help_manageFixaton]]
	pack $btn_help -side left -anchor ne -padx 50p -pady 5 -expand 1;
	#########################
	
	set frm_locatorSel [frame $frm_main1.frm_locatorSel ]
	pack $frm_locatorSel -side top -anchor nw -padx 2 -pady 2;

	set frm_namewld [frame $frm_main1.eidType ]
	pack $frm_namewld -side top -anchor nw -padx 2 -pady 2;
	
	#added by : Swapnil Deotare (18 Dec 2019)-----------
	set frm_vibWld [frame $frm_main1.frm_vibWld ]
	pack $frm_vibWld -side top -anchor nw -padx 2 -pady 2;
	#----------------------------------------------------
	set frm_selectAll [frame $frm_main1.frm_selectAll]
	pack $frm_selectAll -side top -anchor nw -padx 2 -pady 2;
	
	# set frm_splabfram [ttk::labelframe $frm_main1.lbMain1 -text "Convert Special Locator Connection" -labelanchor n]
	# pack $frm_splabfram -side top -anchor nw  -pady 2
	# set frm_locabt [frame $frm_splabfram.frm_locabt ]
	# pack $frm_locabt -side top -anchor nw  -pady 2;
	# set frm_loca [frame $frm_splabfram.locatfram ]
	# pack $frm_loca -side top -anchor nw  -pady 2;
	
	# pack [hwtk::radiobutton  $frm_locabt.spciali -value 1 -text "Implict" -variable [namespace current]::spcCon ]  -side left -anchor nw -padx 5 -pady 2;
	# pack [hwtk::radiobutton  $frm_locabt.spciale -text "Explict" -value 3 -variable [namespace current]::spcCon ] -side left -anchor nw -padx 5 -pady 2;
	# pack [hwtk::radiobutton  $frm_locabt.spcialn -text "None" -value 0 -variable [namespace current]::spcCon] -side left -anchor nw -padx 5 -pady 2;
			
	set frm_sep14 [frame $frm_main1.rerealize ]
	pack $frm_sep14 -side top -anchor nw -padx 2 -pady 2;
	
		set rad_selectAll [hwtk::radiobutton $frm_selectAll.rad_selectAll -value all -variable ::CustomConnectors::str_level -text " All Connectors" -command [list ::CustomConnectors::OnRealizeLevel all $frm_sep14]]
		pack $rad_selectAll -side left -anchor nw -padx 2 -pady 2;
		
		# bind $rad_selectAll <ButtonPress>  [list ::CustomConnectors::OnSelectAll]
	
		set lbl_locators [ttk::label [set frm_locatorSel].lbl_locators -text "Locators" -width 20]
		pack $lbl_locators -side left -anchor nw -padx 2 -pady 2;
		set rad_implicit [hwtk::radiobutton $frm_locatorSel.rad_implicit -value implicit -variable ::CustomConnectors::str_level -text "Implicit " -command [list ::CustomConnectors::OnRealizeLevel implicit $frm_sep14]]
		set rad_explicit [hwtk::radiobutton $frm_locatorSel.rad_explicit -value explicit -variable ::CustomConnectors::str_level -text "Explicit" -command [list ::CustomConnectors::OnRealizeLevel explicit $frm_sep14]]
		
		pack $rad_implicit -side left -anchor nw -padx 2 -pady 2;
		pack $rad_explicit -side left -anchor nw -padx 2 -pady 2;
	
	
		
	
	# ::CustomConnectors::ImageButton $frm_ConType [list  ::CustomConnectors::ConnectorListBox $frm_sep14]
	
	bind $cb_uit <ButtonPress>  [list ::CustomConnectors::OnUnitChange]
	bind $cb_uit <<ComboboxSelected>>  [list ::CustomConnectors::OnNewUnitSelection $cb_uit]

	# set ::CustomConnectors::str_Relizeeids [lindex $lstEidsRealize 0]
	
	# set lbl_2 [ttk::label [set frm_namewld].lbl_1 -text "ElementType" -width 10]
	# set cb_2 [hwtk::combobox $frm_namewld.cb1 -textvariable "::CustomConnectors::str_Relizeeids" -state readonly -values $::CustomConnectors::lstEidsRealize -width 15]

	# pack $lbl_2 -side left -anchor nw -padx 2 -pady 2;
	# pack $cb_2 -side left -anchor nw -padx 2 -pady 2;
		
		set lbl_connectns [ttk::label [set frm_namewld].lbl_connectns -text "Connections" -width 20]
		pack $lbl_connectns -side left -anchor nw -padx 2 -pady 2;
		set level0 [hwtk::radiobutton $frm_namewld.level0 -value 0 -variable ::CustomConnectors::str_level -text "Level-0" -command [list ::CustomConnectors::OnRealizeLevel 0 $frm_sep14]]
		set level1 [hwtk::radiobutton $frm_namewld.level1 -value 1 -variable ::CustomConnectors::str_level -text "Level-1" -command [list ::CustomConnectors::OnRealizeLevel 1 $frm_sep14]]
		set level2 [hwtk::radiobutton $frm_namewld.level2 -value 2 -variable ::CustomConnectors::str_level -text "Level-2" -command [list ::CustomConnectors::OnRealizeLevel 2 $frm_sep14]]
		
		pack $level0 -side left -anchor nw -padx 2 -pady 2;
		pack $level1 -side left -anchor nw -padx 2 -pady 2;
		# pack $level2 -side left -anchor nw -padx 2 -pady 2;
		
		
		#added by : Swapnil Deotare (18 Dec 2019)-----------
		set lbl_connectnsVib [ttk::label [set frm_vibWld].lbl_connectnsVib -text "VibWeld" -width 20]
		pack $lbl_connectnsVib -side left -anchor nw -padx 2 -pady 2;
		set type1 [hwtk::radiobutton $frm_vibWld.type1 -value type1 -variable ::CustomConnectors::str_level -text "Type I" -command [list ::CustomConnectors::OnRealizeLevel type1 $frm_sep14]]
		set type2 [hwtk::radiobutton $frm_vibWld.type2 -value type2 -variable ::CustomConnectors::str_level -text "Type II" -command [list ::CustomConnectors::OnRealizeLevel type2 $frm_sep14]]
		
		pack $type1 -side left -anchor nw -padx 2 -pady 2;
		pack $type2 -side left -anchor nw -padx 2 -pady 2;
		#----------------------------------------------------
	
		if {$::g_profile_name == {LsDyna}} {
		
			# set dynaExp [hwtk::radiobutton $frm_namewld.level3 -value 3 -variable ::CustomConnectors::str_level -text "Dyna-Exp" -command [list ::CustomConnectors::OnRealizeLevel 3 $frm_sep14]]
			# pack $dynaExp -side left -anchor nw -padx 2 -pady 2;
			
			pack $level2 -side left -anchor nw -padx 2 -pady 2;
		
		}
	###################

	if {$::g_profile_name == {Pamcrash2G}} {
		pack $level2 -side left -anchor nw -padx 2 -pady 2;
		pack forget $rad_implicit
	} elseif {$::g_profile_name == {Nastran} || $::g_profile_name == {OptiStruct}} {
		pack forget $rad_explicit
		pack $level2 -side left -anchor nw -padx 2 -pady 2;
	}
	
	::CustomConnectors::OnRealizeLevel  $::CustomConnectors::str_level $frm_sep14
	# ::CustomConnectors::OnRealizeLevel  $::CustomConnectors::str_level 0
	# bind $cb_1 <FocusIn> [list  ::CustomConnectors::ConnectorListBox $frm_sep14]
	
	# ::CustomConnectors::TogglePerformance "on"
	
	return
	

	
}


proc ::CustomConnectors::OnRealizeLevel {val args} {
	
	::CustomConnectors::TogglePerformance "off"
	
	*clearmarkall 1
	*clearmarkall 2
	*createmark connectors 1
	set strval "Level0"
	if {$val == 0} {
		::CustomConnectors::LevelElemnts 0 0
		*appendmark connectors 1 "by metadata name" "Level0"
		*createmark connectors 2 "by metadata equal to value" ctype Locators
		*markdifference connectors 1 connectors 2 
		# *appendmark connectors 1 "by metadata name" "Level0"
		set strval "Level0"
	} elseif {$val == 1} {
		::CustomConnectors::LevelElemnts 0 1
		*appendmark connectors 1 "by metadata name" "Level1"
		*createmark connectors 2 "by metadata equal to value" ctype Locators
		*markdifference connectors 1 connectors 2 
		# *appendmark connectors 1 "by metadata name" "Level1"
		# *appendmark connectors 1 "by metadata name" "Level1"
		set strval "Level1"
	} elseif {$val == 2} {
		::CustomConnectors::LevelElemnts 0 2
		*appendmark connectors 1 "by metadata name" "Level2"
		*createmark connectors 2 "by metadata equal to value" ctype Locators
		*markdifference connectors 1 connectors 2 
		# *appendmark connectors 1 "by metadata name" "Level1"
		# *appendmark connectors 1 "by metadata name" "Level1"
		set strval "Level2"
	} elseif {$val == 3} {
		::CustomConnectors::LevelElemnts 0 3
		*appendmark connectors 1 "by metadata name" "Level3"
		set ::CustomConnectors::str_level "explicit"
		# *createmark connectors 2 "by metadata equal to value" ctype Locators
		# *markdifference connectors 1 connectors 2 
		set strval "Level3"
	} elseif {$val == "implicit"} {
		::CustomConnectors::LevelElemnts 0 0
		*appendmark connectors 1 "by metadata equal to value" ctype Locators
		*createmark connectors 2 "by metadata name" "Level0"
		*appendmark connectors 2 "by metadata name" "Level1"
		*markintersection connectors 1 connectors 2
		*appendmark connectors 1 "by metadata equal to value" LocEtype MPC
		*appendmark connectors 1 "by metadata equal to value" LocEtype ConNode
		# puts "implicit selected--------[hm_getmark connectors 1]"
		set strval "implicit"
		# return
	} elseif {$val == "explicit"} {
		::CustomConnectors::LevelElemnts 0 1
		*appendmark connectors 1 "by metadata equal to value" ctype Locators
		*createmark connectors 2 "by metadata name" "Level3"
		*markintersection connectors 1 connectors 2 
		*appendmark connectors 1 "by metadata equal to value" LocEtype CNTAC46
		*appendmark connectors 1 "by metadata equal to value" LocEtype EdgeTOEdge
		# puts "explicit selected--------[hm_getmark connectors 1]"
		set strval "explicit"
		# return
	} elseif {$val == "all"} {
		*appendmark connectors 1 all
		set strval "all"
		#added by : Swapnil Deotare (18 Dec 2019)-----------
	} elseif {$val == "type1"} {
		set ::CustomConnectors::str_Relizeeids ""
		*createmark connectors 1 "by metadata equal to value" "type" "Type I"
		set strval "type"
		
	}  elseif {$val == "type2"} { 
		*createmark connectors 1 "by metadata equal to value" "type" "Type II"
		set strval "type"
		#---------------------------------------------
	}
	
	# ::CustomConnectors::ConnectorListBox $args "" $strval
	if {![hm_marklength connectors 1]} {
		::CustomConnectors::ConnectorListBox $args "" $strval
		::CustomConnectors::TogglePerformance "on"
		return
	}	
	set lstCOn  [lsort -unique [hm_getmark connectors 1]]
	# set ::CustomConnectors::unit [::MetaData::GetMetadataByMark connector [lindex $lstCOn 0] Unit]
	::CustomConnectors::ConnectorListBox $args $lstCOn $strval
	
	::CustomConnectors::TogglePerformance "on"
	
	return;
}

proc ::CustomConnectors::RightClickMenuListBox {args} {
	
	variable lBox
	set rcm $lBox.rcmenu
	if {[winfo exists $rcm]} {
		destroy $rcm
	}
	hwtk::menu $rcm
	$rcm item view -caption "View" -command "::CustomConnectors::OnselectList $lBox"
	tk_popup $rcm [winfo pointerx .] [winfo pointery .]
}

proc ::CustomConnectors::SelectionClickListBox {args} {
	
	variable lBox
	set lstBox [$lBox selectionget]
	if {[string is space $lstBox]} {
		*clearmark connectors 1
		return
	}
	set lstconne ""
	foreach con $lstBox {
		set cid [lindex [$lBox rowcget $con -values]  1]
		lappend lstconne $cid		
	}
	eval *createmark connectors 1 $lstconne
	hm_highlightmark connectors 1 l
	
	return;
}


proc ::CustomConnectors::ConnectorListBox {str_frame lstCOn val} {

	variable lBox
	variable imagePath
	variable btn_ReviewOrient
	variable btn_changeOrient
	set vibflag 0
	catch {destroy $str_frame.frm1}
	set img_selc [image create photo imgSel -file [file join $imagePath select-24.png]]
	set img_rel [image create photo img_M -file [file join $imagePath Unrel-Reali.png]]
	set img_unreal [image create photo img_unreal -file [file join $imagePath rel_unrel.png]]
	set img_1to2 [image create photo img_1to2 -file [file join $imagePath 1to2.png]]
	set img_1to0 [image create photo img_1to0 -file [file join $imagePath 1to0.png]]
	set img_0to1 [image create photo img_0to1 -file [file join $imagePath 0to1.png]]
	set img_0to2 [image create photo img_0to2 -file [file join $imagePath 0to2.png]]
	set img_2to1 [image create photo img_2to1 -file [file join $imagePath 2to1.png]]
	set img_2to0 [image create photo img_2to0 -file [file join $imagePath 2to0.png]]
	set img_ftor [image create photo img_ftor -file [file join $imagePath ftor.png]]
	set img_rtof [image create photo img_rtof -file [file join $imagePath rtof.png]]
	set img_del [image create photo img_del -file [file join $imagePath delete-30.png]]
	set img_mod [image create photo img_mod -file [file join $imagePath edit-30.png]]
	
	set n_height 300
	set n_lboxHeight [llength $lstCOn]
	if {$n_lboxHeight == 0} {
		set n_lboxHeight $n_height
	} else {
		set n_lboxHeight [expr ($n_lboxHeight * 20)]
	}
	# puts $n_lboxHeight-------------n_lboxHeight
	if {$n_lboxHeight > 500} {
		set n_lboxHeight 500
	} elseif {$n_lboxHeight < 300} {
		set n_lboxHeight 300
	}
	
	set lf1 [frame $str_frame.frm1]
	pack $lf1 -side top -anchor nw -padx 1 -pady 1 -fill both
	
	set lfs4 [frame $lf1.lfs4]
	pack $lfs4 -side top -anchor nw -padx 1 -pady 1 -fill both
	# Separator [set lf1] Horizontal 
	set lf2 [frame $lfs4.frml ]
	pack $lf2 -side left -anchor nw -padx 1 -pady 1 -fill both
	set lf3 [frame $lfs4.lf3]
	pack $lf3 -side top -anchor nw -padx 10 -pady 5 -fill both
	# set lf_conv [frame $lfs4.lf_conv]
	# pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
	# set lf_fr [frame $lfs4.lf_fr]
	# pack $lf_fr -side top -anchor nw -padx 10 -pady 5 -fill both
	# set lf_md [frame $lfs4.lf_md]
	# pack $lf_md -side top -anchor nw -padx 10 -pady 5 -fill both
	
	set lf4 [frame $lf1.lf4]
	pack $lf4 -side top -anchor nw -padx 1 -pady 1 -fill both
	
	set lBox [hwtk::selectlist $lf2.sl -stripes 1 -selectmode multiple -selectcommand "" -width 280p -height ${n_lboxHeight}p]
	pack $lBox -fill both -expand true
	# $lBox element create entityname str -editable 0

	$lBox columnadd entities -text Con-Ids
	$lBox columnadd cType -text Con_Type
	$lBox columnadd etype -text Level
	$lBox columnadd locator -text Locator
	$lBox columnadd unitSys -text UnitSys
	$lBox columnadd state -text State 
	set lvPut $val
	# puts $lstCOn---
	set i 1
	foreach n $lstCOn {
		if {[hm_entityinfo exist connector $n]} {
		
			set sta [hm_ce_info $n state]
			set metdata [::MetaData::GetMetadataByMark connector $n $val]
			if {$metdata == ""} {
				set metdata [::MetaData::GetMetadataByMark connector $n Level0]
				set lvPut "Level0"
				if {$metdata == ""} {
					set metdata [::MetaData::GetMetadataByMark connector $n Level1]
					set lvPut "Level1"
					if {$metdata == ""} {
						set metdata [::MetaData::GetMetadataByMark connector $n Level2]
						set lvPut "Level2"
						if {$metdata == ""} {
							set metdata [::MetaData::GetMetadataByMark connector $n Level3]
							set lvPut "Explict"
						}
					}
				}
			}
			set ct [::MetaData::GetMetadataByMark connector $n ctype]
			#added by : Swapnil Deotare (18 Dec 2019)-----------
			if  {$ct == "VIBRATION"} { 
				if {$val == "type"} {
					set lvPut [::MetaData::GetMetadataByMark connector $n $val]
				} elseif {$val == "all"} {
					set lvPut [::MetaData::GetMetadataByMark connector $n type]
				}
				set vibflag 1
			}
			#----------------------------------------------------------------
			if {$ct == "Locators"} { 
				if {$lvPut == "Level0" || $lvPut == "Level1"} {
					set lvPut "Implicit"
				} elseif {$lvPut == "Level3"} {
					set lvPut "Explict"
				}
			}
			set uSys [::MetaData::GetMetadataByMark connector $n Unit]
			# set loc_cords [::MetaData::GetMetadataByMark connector $n ContECord]
			set con_Loc [::MetaData::GetMetadataByMark connector $n LocEtype]
			# puts $loc_cords--loc_cords
			if {$con_Loc == ""} {
				set con_Loc "no"
			} else {
				# set nset [::MetaData::GetMetadataByMark connector $n gSets]
				########### Added as per the request from Eric on 25-2-2020 ##############
				if {$con_Loc == "ConNode" || $con_Loc == "MPC"} {
					set con_Loc "Implicit"
				} else {
					set con_Loc "Explicit"
				}
				#########################################
			}
			# puts "ct--$ct    i----$i"
			$lBox rowadd $i -values [list entities $n cType $ct etype $lvPut locator $con_Loc unitSys $uSys state $sta]
			incr i
		}
		# $lBox fittocontent
	}
	
	$lBox sort 1
	
	bind $lBox <ButtonRelease-3> {::CustomConnectors::RightClickMenuListBox}
	bind $lBox <ButtonRelease-1> {::CustomConnectors::SelectionClickListBox}
	
	set m [hwtk::menu $lBox.menu]
	$m item modify -caption "Modify" -command [list ::CustomConnectors::RelModify $lBox m];
	$lBox configure -menu $m; 
	
	pack [::hwtk::button $lf3.sel -image $img_selc  -command [list ::CustomConnectors::onSelctor $lBox] -width 5] -side top -pady 10
	pack [::hwtk::button $lf3.u -image $img_unreal  -command [list ::CustomConnectors::RelModify $lBox u] -help "Unrealize the connectors" ] -side top
	pack [::hwtk::button $lf3.re -image $img_rel  -command [list ::CustomConnectors::RelModify $lBox r] -help "Rerealize the connectors" ] -side top

	if {$val == {Level0} } {
		
		set lf_conv [frame $lfs4.lf_conv]
		pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
		set lf_fr [frame $lfs4.lf_fr]
		pack $lf_fr -side top -anchor nw -padx 10 -pady 5 -fill both
	
		pack [::hwtk::button $lf_conv.m -image $img_0to1  -command [list ::CustomConnectors::RelModify $lBox 1] -help "Convert level 0 to level 1"] -side top
		
		if {$::g_profile_name == {Pamcrash2G}  || $::g_profile_name == {LsDyna}} {		
			pack [::hwtk::button $lf_conv.m2 -image $img_0to2  -command [list ::CustomConnectors::RelModify $lBox 2] -help "Convert level 0 to level 2"] -side top   
		
		}
		# ::CustomConnectors::ImageForLevel $lf4 0
		
		pack [::hwtk::button $lf_fr.fr -image $img_ftor  -command [list ::CustomConnectors::RelModify $lBox fr] -help "Convert Free end to Closed end"] -side top
		pack [::hwtk::button $lf_fr.rf -image $img_rtof  -command [list ::CustomConnectors::RelModify $lBox rf] -help "Convert Closed end to Free end"] -side top
		
	} elseif {$val == {Level1} } {
		
		set lf_conv [frame $lfs4.lf_conv]
		pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
		set lf_fr [frame $lfs4.lf_fr]
		pack $lf_fr -side top -anchor nw -padx 10 -pady 5 -fill both
	
		pack [::hwtk::button $lf_conv.m -image $img_1to0  -command [list ::CustomConnectors::RelModify $lBox 0] -help "Convert level 1 to level 0"] -side top
		
		if {$::g_profile_name == {Pamcrash2G}  || $::g_profile_name == {LsDyna}} {		
			pack [::hwtk::button $lf_conv.m2 -image $img_1to2  -command [list ::CustomConnectors::RelModify $lBox 2] -help "Convert level 1 to level 2"] -side top   
		}
		# ::CustomConnectors::ImageForLevel $lf4 1
		
		pack [::hwtk::button $lf_fr.fr -image $img_ftor  -command [list ::CustomConnectors::RelModify $lBox fr] -help "Convert Free end to Closed end"] -side top
		pack [::hwtk::button $lf_fr.rf -image $img_rtof  -command [list ::CustomConnectors::RelModify $lBox rf] -help "Convert Closed end to Free end"] -side top
		
	} elseif {$val == {Level2} } {
		
		set lf_conv [frame $lfs4.lf_conv]
		pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
	
		pack [::hwtk::button $lf_conv.m -image $img_2to0  -command [list ::CustomConnectors::RelModify $lBox 0] -help "Convert level 2 to level 0"] -side top
		
		# if {$::g_profile_name == {Pamcrash2G} || $::g_profile_name == {LsDyna}} {		
			pack [::hwtk::button $lf_conv.m2 -image $img_2to1  -command [list ::CustomConnectors::RelModify $lBox 1] -help "Convert level 2 to level 1"] -side top
		# }
		# ::CustomConnectors::ImageForLevel $lf4 1
		
	} elseif {$val == {implicit}} {
		
		set lf_conv [frame $lfs4.lf_conv]
		pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
		
		if {$::g_profile_name == {LsDyna}} {
			pack [::hwtk::button $lf_conv.me -text "Expl"  -command [list ::CustomConnectors::RelModify $lBox e] -width 5 -help "Convert Implicit to Explict connection"] -side top  
		}
		
	} elseif {$val == {explicit}} {
		
		set lf_conv [frame $lfs4.lf_conv]
		pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
		
		if {$::g_profile_name == {LsDyna}} {
			pack [::hwtk::button $lf_conv.m1 -text "Impl"  -command [list ::CustomConnectors::RelModify $lBox i1] -width 5 -help "Convert Explict to Implicit"] -side top  
		}
		
	} elseif {$val == {Level3} } {
		
		# set lf_conv [frame $lfs4.lf_conv]
		# pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
		
		# pack [::hwtk::button $lf_conv.m1 -text "1"  -command [list ::CustomConnectors::RelModify $lBox i1] -width 5 -help "Convert Explict to level 1 implicit"] -side top 
		
		# pack [::hwtk::button $lf_conv.m2 -text "0"  -command [list ::CustomConnectors::RelModify $lBox i0] -width 5 -help "Convert Explict to level 0 implicit"] -side top  
		
		set lf_conv [frame $lfs4.lf_conv]
		pack $lf_conv -side top -anchor nw -padx 10 -pady 5 -fill both
		
		if {$::g_profile_name == {LsDyna}} {
			pack [::hwtk::button $lf_conv.m1 -text "Impl"  -command [list ::CustomConnectors::RelModify $lBox i1] -width 5 -help "Convert Explict to Implicit"] -side top  
		}
		
	}
	
	set lf_md [frame $lfs4.lf_md]
	pack $lf_md -side top -anchor nw -padx 10 -pady 5 -fill both
	
	pack [::hwtk::button $lf_md.modify -image $img_mod -command [list ::CustomConnectors::RelModify $lBox m] -width 5 -help "Modify the connectors" ] -side top
	pack [::hwtk::button $lf_md.delete -image $img_del -command [list ::CustomConnectors::RelModify $lBox d] -width 5 -help "Delete the connectors" ] -side top
	
	
	if {$vibflag == 1} {
		set padyVar 2
		set padxVar 20
		set widthVar 25
		
		set sep_bottom [ttk::separator $lf1.sep -orient horizontal];
		pack $sep_bottom -side top -fill x -expand 1;
		
		## Orientation Check

		set frm_orientbtn [frame $lf1.frm_orientbtn] ;
		pack $frm_orientbtn -side top -anchor nw -pady 7 -padx 2;
		
			set lbl_ReviewOrien [label $frm_orientbtn.lbl_ReviewOrien -text "Vib-Weld Orientation Check:" -anchor nw -font {verdana 8 bold} -width $widthVar];
			pack $lbl_ReviewOrien -side left -anchor nw -padx 5 -pady $padyVar;
			
			set btn_ReviewOrient [hwtk::button $frm_orientbtn.btn_ReviewOrient -text "Check" -width 10\
			-help "Check orientation of hex elements." -command "::EsgCMAT::OnReviewOrientationBtn"];
			pack $btn_ReviewOrient -side left -anchor nw -padx {20 2};	
			
			set btn_changeOrient [hwtk::button $frm_orientbtn.btn_changeOrient -text "Adjust" -state disabled -width 10\
			-help "Adjust orientation of hex elements." \
			-command "::EsgCMAT::OrientaionCheck::OrientationElem Cohesive_Elements_Type_1 Cohesive_Elements_Type_2"];
			pack $btn_changeOrient -side right -anchor nw -padx {2 20};
			
		
	
		
		# Tie Contact Check
		set frm_fileEntry [frame $lf1.frm_fileEntry ];
		pack $frm_fileEntry -side top -anchor nw -padx 2 -pady 7;
		
			set lbl_file [label $frm_fileEntry.lbl_file -text "Vib-Weld TIE Contact Check:" -font {verdana 8 bold} -width [expr $widthVar-2]];
			pack $lbl_file -side left -anchor nw -padx 5 -pady $padyVar;
				
			set str_fileTypes [::EsgCMAT::entryFileOutType]
			
			set ::EsgCMAT::str_FilePath ""
			set ent_resultFile [hwtk::openfileentry $frm_fileEntry.ent_resultFile -buttonpos right -width 12 -filetypes $str_fileTypes\
			-help "Select out file to read and review." -state readonly -textvariable ::EsgCMAT::str_FilePath -validate key]
			pack $ent_resultFile -side left -anchor nw -padx {20 2};

		# set frm_createbtnSet [frame $lf1.frm_createbtnSet ] ;
		# pack $frm_createbtnSet -side top -anchor nw -padx 15 -pady 2 ;
			
			# set lbl_ReviewUnTied [label $frm_createbtnSet.lbl_ReviewUnTied -text "" -anchor nw -font {verdana 8 bold} -width $widthVar];
			# pack $lbl_ReviewUnTied -side left -anchor nw -padx 5 ;
			
			set btn_CreateSet [hwtk::button $frm_fileEntry.btn_CreateSet -text "Read" -width 7 \
			-help "Read out file to create untied nod set." -command "::EsgCMAT::ReadOutFile::Main"];
			pack $btn_CreateSet -side left -anchor nw -padx 2 -pady 1;
			
			set btn_Review [hwtk::button $frm_fileEntry.btn_Review -text "Review" -width 7 \
			-help "Review untied nodes."	-command "::EsgCMAT::OnReviewUntiedNodeBtn"];
			pack $btn_Review -anchor nw -side right -padx {2 20} -pady 1;
	
	}
	
	# if {$val == {Level2}} {
	
		# if {$::g_profile_name == {Pamcrash2G} || $::g_profile_name == {LsDyna}} {		
			# set btn_unreg [::hwtk::button $lf3.unreg -text "U-Reg"  -command [list ::CustomConnectors::UnregisterElems $lBox $lf3 unreg] -width 5 -help "Un-Register all the elements from connector"] 
			# pack $btn_unreg -side top
			# set btn_reg [::hwtk::button $lf3.reg -text "Reg"  -command [list ::CustomConnectors::UnregisterElems $lBox $lf3 reg] -width 5 -help "Register elements to connector"]
			
		# }
		
	# }
	
	if {$val == {all}} {
		# pack forget $lf3.sel
		pack forget $lf_md.modify
		# pack forget $lf3.delete
	}
	
	*createmark connectors 1 all
	if {[hm_marklength connectors 1]} { hm_highlightmark connectors 1 "normal"}
	

	return
	
}


proc ::CustomConnectors::RelModify {box args} {

# puts "$box ==  $args"
	if {$args == {d}} {
		set lst_cons [list]
		set lstBox [$box selectionget]
		if {[string is space $lstBox]} {
			return
		}
		set strVal [tk_messageBox -message "Are you sure you want to delete the selected connectors?" -icon error -type yesno -title "Delete Connector"]
		if {$strVal == {no}} {
			return
		}
	}
	
	*saveviewmask "Custom_Con" 1
	::CustomConnectors::TogglePerformance "off"
	
	if {$args == 0} {
		
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			if {[llength $lstBox] > 30} {
				set str_reply [tk_messageBox -title "Connector Conversion" -message "Note : Please make sure that all components associated with\nconnections are displayed.\n\nContinue with conversion?" -icon question -type yesno]
				if {$str_reply == "no"} {
					::CustomConnectors::TogglePerformance "on"
					*restoreviewmask "Custom_Con" 1
					return;
				}
			}
			
			set lst_orderedSelection [::CustomConnectors::OrderConnectionsAccToSystem $lstBox $box]
			# return
			set lst_rowsToDel [list]
			set lst_unrealizedConns [list]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Conversion to Level-0 under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lst_orderedSelection]}]
			set i 1
			
			foreach con $lst_orderedSelection {
				set cid [lindex [$box rowcget $con -values] 1]
				::CustomConnectors::RealizelistCOnnectors $cid 0
				
				if {[hm_ce_state $cid] == "realized"} {
					lappend lst_rowsToDel $con
				} else {
					lappend lst_unrealizedConns $cid
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
				# lappend lst_rowsToDel $con
				
				set pvalue [expr {$i*$pivalue}]
				$pbar SetProgress $pvalue
				$pbar SetMessage "Conversion to Level-0 under progress... ($i out of [llength $lst_orderedSelection])"
				incr i
				# $box rowdelete $con
			}
			foreach con $lst_rowsToDel {
				$box rowdelete $con
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
			
			if {[llength $lst_unrealizedConns] != 0} {
				tk_messageBox -title "Connector Conversion" -message "Conversion failed for [llength $lst_unrealizedConns] connectors with ids = [join $lst_unrealizedConns ,]." -icon warning -type ok
			}
		}
		
	} elseif {$args == 1} {
		
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			if {[llength $lstBox] > 30} {
				set str_reply [tk_messageBox -title "Connector Conversion" -message "Note : Please make sure that all components associated with\nconnections are displayed.\n\nContinue with conversion?" -icon question -type yesno]
				if {$str_reply == "no"} {
					::CustomConnectors::TogglePerformance "on"
					*restoreviewmask "Custom_Con" 1
					return;
				}
			}
			
			set lst_orderedSelection [::CustomConnectors::OrderConnectionsAccToSystem $lstBox $box]
			# puts $lst_orderedSelection-----lst_orderedSelection
			# return
			set lst_rowsToDel [list]
			set lst_unrealizedConns [list]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Conversion to Level-1 under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lst_orderedSelection]}]
			set i 1
			
			foreach con $lst_orderedSelection {
				set cid [lindex [$box rowcget $con -values] 1]
				::CustomConnectors::RealizelistCOnnectors $cid 1
				if {[hm_ce_state $cid] == "realized"} {
					lappend lst_rowsToDel $con
				} else {
					lappend lst_unrealizedConns $cid
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
				# lappend lst_rowsToDel $con
				
				set pvalue [expr {$i*$pivalue}]
				$pbar SetProgress $pvalue
				$pbar SetMessage "Conversion to Level-1 under progress... ($i out of [llength $lst_orderedSelection])"
				incr i
				# $box rowdelete $con
			}
			foreach con $lst_rowsToDel {
				$box rowdelete $con
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
			
			if {[llength $lst_unrealizedConns] != 0} {
				tk_messageBox -title "Connector Conversion" -message "Conversion failed for [llength $lst_unrealizedConns] connectors with ids = [join $lst_unrealizedConns ,]." -icon warning -type ok
			}
		}
		
	} elseif {$args == 2} {
		
		set lst_unconvertedPam [list]
		set lst_unconvertedDyna [list]
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			if {[llength $lstBox] > 30} {
				set str_reply [tk_messageBox -title "Connector Conversion" -message "Note : Please make sure that all components associated with\nconnections are displayed.\n\nContinue with conversion?" -icon question -type yesno]
				if {$str_reply == "no"} {
					::CustomConnectors::TogglePerformance "on"
					*restoreviewmask "Custom_Con" 1
					return;
				}
			}
			
			set lst_orderedSelection [::CustomConnectors::OrderConnectionsAccToSystem $lstBox $box]
			# puts $lst_orderedSelection-----lst_orderedSelection
			# return
			set lst_rowsToDel [list]
			set lst_unrealizedConns [list]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Conversion to Level-2 under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lst_orderedSelection]}]
			set i 1
			
			foreach con $lst_orderedSelection {
				set cid [lindex [$box rowcget $con -values] 1]
				set contype [lindex [$box rowcget $con -values] 3]
				# puts $contype-----contype
				if {$::g_profile_name == {LsDyna} && $contype == {Snaps}} {
					::CustomConnectors::RealizelistCOnnectors $cid 2
					if {[hm_ce_state $cid] == "realized"} {
						lappend lst_rowsToDel $con
					} else {
						lappend lst_unrealizedConns $cid
					}
					$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
					# lappend lst_rowsToDel $con
					
					set pvalue [expr {$i*$pivalue}]
					$pbar SetProgress $pvalue
					$pbar SetMessage "Conversion to Level-2 under progress... ($i out of [llength $lst_orderedSelection])"
					incr i
				} elseif {$::g_profile_name == {Pamcrash2G}} {
					if {$contype == {UsWeld} || $contype == {RibWeld} || $contype == {Retainer}} {
						::CustomConnectors::RealizelistCOnnectors $cid 2
						if {[hm_ce_state $cid] == "realized"} {
							lappend lst_rowsToDel $con
						} else {
							lappend lst_unrealizedConns $cid
						}
						$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
						# lappend lst_rowsToDel $con
						
						set pvalue [expr {$i*$pivalue}]
						$pbar SetProgress $pvalue
						$pbar SetMessage "Conversion to Level-2 under progress... ($i out of [llength $lst_orderedSelection])"
						incr i
					} else {
						lappend lst_unconvertedPam $cid
					}
				} elseif {$::g_profile_name == {LsDyna} && $contype != {Snaps}} {
					lappend lst_unconvertedDyna $cid
				}
				
			}
			
			foreach con $lst_rowsToDel {
				$box rowdelete $con
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
			
			if {[llength $lst_unconvertedPam] != 0} {
				tk_messageBox -message "Level-2 conversion is only available for UsWeld, RibWeld and Retainer in Pamcrash profile..! \nSkipped conversion of connectors with id : [join $lst_unconvertedPam ,]" -type ok -icon warning -title "Connector Conversion"
			}
			if {[llength $lst_unconvertedDyna] != 0} {
				tk_messageBox -message "Level-2 conversion is only available for Snaps in LsDyna profile..! \nSkipped conversion of connectors with id : [join $lst_unconvertedDyna ,]" -type ok -icon warning -title "Connector Conversion"
			}
			if {[llength $lst_unrealizedConns] != 0} {
				tk_messageBox -title "Connector Conversion" -message "Conversion failed for [llength $lst_unrealizedConns] connectors with ids = [join $lst_unrealizedConns ,]." -icon warning -type ok
			}
		}

	} elseif {$args == {u}} {
		
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			set lstconne ""
			foreach con $lstBox {
				set cid [lindex [$box rowcget $con -values] 1]
				lappend lstconne $cid
				$box rowconfigure $con -values [list state Unrealize]
				
			}
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Unrealizing Connectors.."
			$pbar SetProgress 30
			
			::CustomConnectors::Unrealize $lstconne
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
		}
		
	} elseif {$args == {r}} {
		
		# puts cksjljsdaljsljkl
		set lst_unrealizedConnsLevel2 [list]
		set lst_unrealizedConnsSnaps [list]
		set lst_unrealizedConns [list]
		
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			if {[llength $lstBox] > 30} {
				set str_reply [tk_messageBox -title "Connector Rerealize" -message "Note : Please make sure that all components associated with\nconnections are displayed.\n\nContinue with rerealize?" -icon question -type yesno]
				if {$str_reply == "no"} {
					::CustomConnectors::TogglePerformance "on"
					*restoreviewmask "Custom_Con" 1
					return;
				}
			}
			
			set lst_orderedSelection [::CustomConnectors::OrderConnectionsAccToSystem $lstBox $box]
			# puts $lst_orderedSelection-----lst_orderedSelection
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Rerealizing Connectors.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lst_orderedSelection]}]
			set i 1
			
			foreach con $lst_orderedSelection {
				set cid [lindex [$box rowcget $con -values] 1]
				lassign [::CustomConnectors::RealizelistCOnnectors $cid] n_unrealizedConn1 n_unrealizedConn2
				if {[hm_ce_state $cid] != "realized"} {
					lappend lst_unrealizedConns $cid
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
				
				set pvalue [expr {$i*$pivalue}]
				$pbar SetProgress $pvalue
				$pbar SetMessage "Rerealizing Connectors under progress... ($i out of [llength $lst_orderedSelection])"
				incr i
				
				if {$n_unrealizedConn1 != ""} {
					lappend lst_unrealizedConnsLevel2 $n_unrealizedConn1
				}
				if {$n_unrealizedConn2 != ""} {
					lappend lst_unrealizedConnsSnaps $n_unrealizedConn2
				}
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
			
			if {[llength $lst_unrealizedConnsLevel2] != 0} {
				tk_messageBox -title "Connector Rerealize" -message "Convert level 2 connections, connector ids = [join $lst_unrealizedConnsLevel2 ,] to level 1 connections first & then rerealize." -icon warning -type ok
			}
			if {[llength $lst_unrealizedConnsSnaps] != 0} {
				tk_messageBox -title "Connector Rerealize" -message "Convert level 2 connection Snaps, connector ids = [join $lst_unrealizedConnsSnaps ,] to level 1 connections first & then rerealize." -icon warning -type ok
			}
			if {[llength $lst_unrealizedConns] != 0} {
				tk_messageBox -title "Connector Rerealize" -message "Rerealize failed for [llength $lst_unrealizedConns] connectors with ids = [join $lst_unrealizedConns ,]." -icon warning -type ok
			}
		}
		
	} elseif {$args == {e}} {
	
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			if {[llength $lstBox] > 30} {
				set str_reply [tk_messageBox -title "Connector Conversion" -message "Note : Please make sure that all components associated with\nconnections are displayed.\n\nContinue with conversion?" -icon question -type yesno]
				if {$str_reply == "no"} {
					::CustomConnectors::TogglePerformance "on"
					*restoreviewmask "Custom_Con" 1
					return;
				}
			}
			
			set lst_rowsToDel [list]
			set lst_unrealizedConns [list]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Implicit to Explicit conversion under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lstBox]}]
			set i 1
			
			foreach con $lstBox {
				set cid [lindex [$box rowcget $con -values] 1]
				::CustomConnectors::RealizelistCOnnectors $cid expl
				if {[hm_ce_state $cid] == "realized"} {
					lappend lst_rowsToDel $con
				} else {
					lappend lst_unrealizedConns $cid
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
				# lappend lst_rowsToDel $con
				
				set pvalue [expr {$i*$pivalue}]
				$pbar SetProgress $pvalue
				$pbar SetMessage "Implicit to Explicit conversion under progress... ($i out of [llength $lstBox])"
				incr i
			}
			
			foreach con $lst_rowsToDel {
				$box rowdelete $con
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
			
			if {[llength $lst_unrealizedConns] != 0} {
				tk_messageBox -title "Connector Conversion" -message "Conversion failed for [llength $lst_unrealizedConns] connectors with ids = [join $lst_unrealizedConns ,]." -icon warning -type ok
			}
		}
	
	} elseif {$args == {i0}} {	
	
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			set lst_rowsToDel [list]
			set lst_unrealizedConns [list]
			foreach con $lstBox {
				set cid [lindex [$box rowcget $con -values] 1]
				::CustomConnectors::RealizelistCOnnectors $cid 0
				if {[hm_ce_state $cid] == "realized"} {
					lappend lst_rowsToDel $con
				} else {
					lappend lst_unrealizedConns $cid
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
				# lappend lst_rowsToDel $con
				# $box rowdelete $con
			}
			foreach con $lst_rowsToDel {
				$box rowdelete $con
			}
		}
		
	} elseif {$args == {i1}} {	
	
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			
			if {[llength $lstBox] > 30} {
				set str_reply [tk_messageBox -title "Connector Conversion" -message "Note : Please make sure that all components associated with\nconnections are displayed.\n\nContinue with conversion?" -icon question -type yesno]
				if {$str_reply == "no"} {
					::CustomConnectors::TogglePerformance "on"
					*restoreviewmask "Custom_Con" 1
					return;
				}
			}
			
			set lst_rowsToDel [list]
			set lst_unrealizedConns [list]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Explicit to Implicit conversion under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lstBox]}]
			set i 1
			
			foreach con $lstBox {
				set cid [lindex [$box rowcget $con -values] 1]
				::CustomConnectors::RealizelistCOnnectors $cid impl 
				if {[hm_ce_state $cid] == "realized"} {
					lappend lst_rowsToDel $con
				} else {
					lappend lst_unrealizedConns $cid
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
				# lappend lst_rowsToDel $con
				
				set pvalue [expr {$i*$pivalue}]
				$pbar SetProgress $pvalue
				$pbar SetMessage "Explicit to Implicit conversion under progress... ($i out of [llength $lstBox])"
				incr i
			}
			foreach con $lst_rowsToDel {
				$box rowdelete $con
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
			
			if {[llength $lst_unrealizedConns] != 0} {
				tk_messageBox -title "Connector Conversion" -message "Conversion failed for [llength $lst_unrealizedConns] connectors with ids = [join $lst_unrealizedConns ,]." -icon warning -type ok
			}
		}
		
	} elseif {$args == {m}} {	
		
		set lst_cids [list]
		set lst_Comvalue [list]
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			foreach con $lstBox {
				set cid [lindex [$box rowcget $con -values] 1]
				set strComvalue [::MetaData::GetMetadataByMark connectors $cid ctype]
				lappend lst_cids $cid
				lappend lst_Comvalue $strComvalue
			}
			# puts "$lst_cids $lst_Comvalue"
			#added by : anirudv (23-09-21)-----------for vibration tool update
			if {[string match -nocase "*vibration*" $lst_Comvalue]} {
				::EsgCMAT::ModifyGUI 1 $lst_cids
			} else {
				set rupdate [::CustomConnectors::GUIForUpdate $lst_cids $lst_Comvalue]
			}
			# if {[llength $lst_cids] == 1} {
				# set rupdate [::CustomConnectors::GUIForUpdate $lst_cids $lst_Comvalue]
			# }
		}
		
	} elseif {$args == {d}} {
	
		set lst_cons [list]
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			foreach con $lstBox {
				set cid [lindex [$box rowcget $con -values] 1]
				lappend lst_cons $cid
			}
			if {[llength $lst_cons]} {
				
				set pbar [::CustomConnectors::TDProgressBar #auto]
				$pbar Create
				$pbar SetTitle "Fixation Modelling Tool"
				$pbar SetMessage "Deleting Connectors.."
				$pbar SetProgress 20
			
				::CustomConnectors::Unrealize $lst_cons
				$pbar SetProgress 60
				eval *createmark connectors 1 $lst_cons
				if {[hm_marklength connectors 1]} {
					*deletemark connectors 1
				}
				
				$pbar SetProgress 90
				
				foreach con $lstBox {
					$box rowdelete $con
				}
				
				$pbar SetProgress 100
				::itcl::delete obj $pbar;
			}
		}
		
	} elseif {$args == {fr}} {
	
		set lst_cons [list]
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			set lst_orderedSelection [::CustomConnectors::OrderConnectionsAccToSystem $lstBox $box]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Free end to Closed end conversion under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lst_orderedSelection]}]
			set i 1
			
			foreach con $lst_orderedSelection {
				set cid [lindex [$box rowcget $con -values] 1]
				set n_freeEnd [::MetaData::GetMetadataByMark connectors $cid FreeEnd]
				set str_conType [::MetaData::GetMetadataByMark connectors $cid ctype]
				if {$str_conType == "Retainer" || $str_conType == "Screw" || $str_conType == "Crashclip"} {
					if {$n_freeEnd == 1} {
						::MetaData::CreateMetadata connectors $cid FreeEnd 0
						# ::CustomConnectors::Unrealize $cid
						::CustomConnectors::RealizelistCOnnectors $cid
						
						set pvalue [expr {$i*$pivalue}]
						$pbar SetProgress $pvalue
						$pbar SetMessage "Free end to Closed end conversion under progress... ($i out of [llength $lst_orderedSelection])"
						incr i
					}
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
		}
		
	} elseif {$args == {rf}} {
	
		set lst_cons [list]
		set lstBox [$box selectionget]
		if {![string is space $lstBox]} {
			set lst_orderedSelection [::CustomConnectors::OrderConnectionsAccToSystem $lstBox $box]
			
			set pbar [::CustomConnectors::TDProgressBar #auto]
			$pbar Create
			$pbar SetTitle "Fixation Modelling Tool"
			$pbar SetMessage "Closed end to Free end conversion under progress.."
			$pbar SetProgress 1
			set pivalue [expr {99.0/[llength $lst_orderedSelection]}]
			set i 1
			
			foreach con $lst_orderedSelection {
				set cid [lindex [$box rowcget $con -values] 1]
				set n_freeEnd [::MetaData::GetMetadataByMark connectors $cid FreeEnd]
				set str_conType [::MetaData::GetMetadataByMark connectors $cid ctype]
				if {$str_conType == "Retainer" || $str_conType == "Screw" || $str_conType == "Crashclip"} {
					if {$n_freeEnd == 0} {
						::MetaData::CreateMetadata connectors $cid FreeEnd 1
						# ::CustomConnectors::Unrealize $cid
						::CustomConnectors::RealizelistCOnnectors $cid
						
						set pvalue [expr {$i*$pivalue}]
						$pbar SetProgress $pvalue
						$pbar SetMessage "Closed end to Free end conversion under progress... ($i out of [llength $lst_orderedSelection])"
						incr i
					}
				}
				$box rowconfigure $con -values [list state [hm_ce_info $cid state]]
			}
			
			$pbar SetProgress 100
			::itcl::delete obj $pbar;
		}
	}
	
	::CustomConnectors::TogglePerformance "on"
	*restoreviewmask "Custom_Con" 1
}

proc ::CustomConnectors::UnregisterElems {box frm_path args} {
	
	*saveviewmask "Custom_Con" 1
	
	if {$args == "unreg"} {
	
		set lstBox [$box selectionget]
		if {[string is space $lstBox]} {
			return
		} elseif {[llength $lstBox] > 1} {
			tk_messageBox -title "Connector Register" -message "Select only one connector and try again." -icon warning -type ok
			return
		}
		set cid [lindex [$box rowcget [lindex $lstBox 0] -values] 1]
		*createmark connectors 1 $cid
		*duplicatemark connectors 1 0
		set n_dupCon [hm_latestentityid connectors]
		*CE_FE_GlobalFlags 0 0
		*clearmark connectors 1
		# puts "$n_dupCon---------n_dupCon--------$cid------cid"
		*createmark connectors 1 $cid
		if {[hm_marklength connectors 1]} {
			*deletemark connectors 1
			*setvalue connectors id=$n_dupCon id={connectors $cid}
		}
		*clearmark connectors 1
		if {[winfo exists $frm_path.unreg]} {
			pack forget $frm_path.unreg
			pack $frm_path.reg -side top
		}
		
		$box rowconfigure [lindex $lstBox 0] -values [list state [hm_ce_info $cid state]]
		tk_messageBox -title "Connector Register" -message "Elements have unregistered from the connector." -icon info -type ok
		
		
	} elseif {$args == "reg"} {
	
		set lstBox [$box selectionget]
		if {[string is space $lstBox]} {
			return
		} elseif {[llength $lstBox] > 1} {
			tk_messageBox -title "Connector Register" -message "Select only one connector and try again." -icon warning -type ok
			return
		}
		*createmarkpanel elems 1
		if {[hm_marklength elems 1] == 0} {
			tk_messageBox -title "Connector Register" -message "Select elements to register with connector and try again." -icon warning -type ok
			return
		}
		set cid [lindex [$box rowcget [lindex $lstBox 0] -values] 1]
		::CustomConnectors::RegEntitiesToCon $cid [hm_getmark elems 1] elems
		$box rowconfigure [lindex $lstBox 0] -values [list state [hm_ce_info $cid state]]
		*clearmark elems 1
		
		if {[winfo exists $frm_path.reg]} {
			pack forget $frm_path.reg
			pack $frm_path.unreg -side top
		}
		$box rowconfigure [lindex $lstBox 0] -values [list state [hm_ce_info $cid state]]
		tk_messageBox -title "Connector Register" -message "Selected elements have registered to the connector." -icon info -type ok
	}
	
	*restoreviewmask "Custom_Con" 1
}

proc  ::CustomConnectors::OnExport {frm_main1} {
	
	variable fl_help_export;
	
	set export [image create photo img_export -file [file join $::CustomConnectors::imagePath fileExportConnect.png]]
	set frm_main [frame $frm_main1.export]
	pack $frm_main -side top -anchor nw -padx 5 -pady 2
	set btnGrp [hwtk::buttongroup $frm_main.bt1]
	$btnGrp add b2 -text "Export" -image $export -compound right -help "Export Connectors in CSV format" -command [list ::CustomConnectors::GetConnecdataForCsv]
	pack $btnGrp -side left
	
	#####Help button#########
	set img_help [image create photo imgHelp -file [file join $::CustomConnectors::imagePath help-16.png]]
	set btn_help [hwtk::button $frm_main.btn_help -image $img_help -command [list ::CustomConnectors::CallOnHelpButtons $fl_help_export]]
	pack $btn_help -side left -anchor ne -padx 50p -pady 2p -expand 1;
	#########################
	
	return
	
}





proc  ::CustomConnectors::OnImport {frm_main1} {
	
	variable fl_help_import;
	
	set import [image create photo img_import -file [file join $::CustomConnectors::imagePath fileImportConnect.png]]
	set frm_main [frame $frm_main1.import]
	pack $frm_main -side top -anchor nw -padx 5 -pady 2
	set btnGrp [hwtk::buttongroup $frm_main.bt1]
	$btnGrp add b2 -text "Import" -image $import -compound right -help "Import Connector" -command [list ::CustomConnectors::ReaCsvCreateConencte]
	pack $btnGrp -side left
	
	#####Help button#########
	set img_help [image create photo imgHelp -file [file join $::CustomConnectors::imagePath help-16.png]]
	set btn_help [hwtk::button $frm_main.btn_help -image $img_help -command [list ::CustomConnectors::CallOnHelpButtons $fl_help_import]]
	pack $btn_help -side left -anchor ne -padx 50p -pady 2p -expand 1;
	#########################
	
	*nodecleartempmark 
	return
	
}

proc ::CustomConnectors::ForButon {args1 args} {

	variable str_combovalue
	set str_combovalue $args1
	::CustomConnectors::OnCreate2 $args
}


proc ::CustomConnectors::ImageButton1 {strFram nComan fram} {
	
	foreach  l $::CustomConnectors::lstConnection {

		set imge_$l [image create photo img_$l -file [file join $::CustomConnectors::imagePath $l.png]]
		
		if {$l == {Rerealize}} {
			
			pack [hwtk::button ${strFram}.c$l -text "Manage \nFixation" -image [set imge_$l] -compound right -width 12 -command [list $nComan $l] -help "Realize or modify the connectors"] -side top -pady 20 -padx 0
		} elseif {$l == {fileExportConnect}} {
			
			pack [hwtk::button ${strFram}.c$l -text Export -image [set imge_$l] -compound right -width 12 -command [list $nComan $l] -help "Export the connector"] -side top -pady 1 -padx 0
			
		} elseif {$l == {fileImportConnect}} {
			pack [hwtk::button ${strFram}.c$l -text Import -image [set imge_$l]  -compound right -width 12 -command [list $nComan $l] -help "Import the connectors"] -side top -pady 1 -padx 0
			
		} elseif {$l == {Antolin}} {
			pack [hwtk::button ${strFram}.c$l -text $l -image [set imge_$l] -compound right -width 10 -command [list $nComan $l] -help "Antolin connection methodology"] -side top -pady 1 -padx 0
		} else {
		# puts $l
			pack [hwtk::button ${strFram}.c$l -text $l -image [set imge_$l] -compound right -width 12	 -command [list $nComan $l] -help "Antolin connection conversion"] -side top -pady 1 -padx 0
		}
	}
	
	return
       
}

proc ::CustomConnectors::ImageButton {strFram nComan fram} {

	foreach  l $::CustomConnectors::lstConnection {

		set imge_$l [image create photo img_$l -file [file join $::CustomConnectors::imagePath $l.png]]
		
		if {$l == {Rerealize}} {
			
			pack [hwtk::statebutton ${strFram}.c$l -image [set imge_$l] -variable ::CustomConnectors::str_combovalue -onvalue $l -command [list $nComan $l] -help "Realize or modify the connectors"] -side top -pady 4 -padx 2
		} elseif {$l == {fileExportConnect}} {
			
			pack [hwtk::statebutton ${strFram}.c$l -image [set imge_$l] -variable ::CustomConnectors::str_combovalue -onvalue $l -command [list $nComan $l] -help "Export the connector"] -side top -pady 4 -padx 2
			
		} elseif {$l == {fileImportConnect}} {
			pack [hwtk::statebutton ${strFram}.c$l -image [set imge_$l] -variable ::CustomConnectors::str_combovalue -onvalue $l -command [list $nComan $l] -help "Import the connectors"] -side top -pady 4 -padx 2
			
		} else {
			pack [hwtk::statebutton ${strFram}.c$l -image [set imge_$l] -variable ::CustomConnectors::str_combovalue -onvalue $l -command [list $nComan $l] -help "Create $l type of connectors"] -side top -pady 4 -padx 2
		}
	}
	
	return
       
}

proc ::CustomConnectors::VibrationWelding {subfram} {
	
	::EsgCMAT::Gui $subfram
}

proc ::CustomConnectors::ConnectorListBox1 {str_fram lstCOn val} {


	variable lbbox
	variable str_combovalue
	# puts coming3
	catch {destroy $str_fram.frm1}
	set frm1 [frame $str_fram.frm1]
	pack $frm1 -side top -anchor nw -padx 5 -pady 5 -fill both -expand 1
	
	
	set frmleft [frame $frm1.frmleft]
	pack $frmleft -side left -anchor nw -padx 5 -pady 5 -fill both -expand 1
	
	set frmright [frame $frm1.frmright]
	pack $frmright -side left -anchor nw -padx 5 -pady 5 -fill both -expand 1
	set lbbox [hwtk::listbox $frmleft.lb -headertext "$val Connectors" -selectmode multiple]
	pack $lbbox -fill both -expand true

    bind $lbbox <Double-ButtonRelease-1>  "CustomConnectors::COnFitView $lbbox"
    # bind $lbbox <ButtonPress-3> "::CusFordsafeConnector::RightClikEidt $lbbox"
	
	# set m [hwtk::menu $lbbox.menu]
	# $m item create -caption "Unrealize" -command [list ::CustomConnectors::ModifyOrDel Unrealize ]
	# $m item modify -caption "ReRealize" -command [list ::CustomConnectors::ModifyOrDel ReRealize ];
	# $m item delete -caption "Delete" -command  [list ::CustomConnectors::ModifyOrDel Delete ];
	# $lbbox configure -menu $m; 
	
	set i 1

	# puts $lstCOn---lstCOn
	foreach data $lstCOn {
	# puts $data---data
	if {[string is space $data]} {continue}
		# puts "$lbbox---lbbox ==$i==$data "
			$lbbox add r$i $data 
			
		incr i
	}
	
	return

}


proc ::CustomConnectors::OnselectList {W} {
	

	set bid [$W selectionget]
	if {[string is space $bid]} {return}
	if {[llength $bid] > 1} { return}
	set cid [lindex [$W rowcget $bid -values] 1]
	if {[hm_entityinfo exist connectors $cid]} {
		lassign [hm_ce_getcords $cid]  x y
		::Utils::ViewSet $x $y

	
	}
		
}


proc ::CustomConnectors::onSelctor {args} {

	*createmarkpanel connector 1 "select connector to review"
	if {![hm_marklength connector 1]} {
		return
	}
	set ncon [lindex [hm_getmark connector 1] 0]
	# $args selectionclear 
	set lstRow [$args rowlist]
	foreach n $lstRow {
		
		set id [lindex [$args rowcget $n -values] 1]
		if {$ncon == $id } {
			$args setactiveitem $n
			break
		}
	}


	
	return
	
}


proc ::CustomConnectors::ModifyOrDel {args} {
	
	variable lbbox
	set lstboxItem [$lbbox selection get]
	set lstCOnnecots ""
	
	foreach item $lstboxItem {
		if {[string is space $item]} {break}
		if {[$lbbox exists $item] > 0} {
			lappend lstCOnnecots [$lbbox itemcget $item -text]
	 
		}
	}
	
	
	if {$args == {ReRealize}} {
	
		::CustomConnectors::RealizelistCOnnectors $lstCOnnecots
	} elseif {$args == {Unrealize}} {
		
		::CustomConnectors::Unrealize $lstCOnnecots
	} else {
	
	}
	
	return
	# puts $item---$args
}

proc  ::CustomConnectors::UpdateEidOnpChnage {args} {
	
	 
	puts RegiestProc
	
	return
}

proc ::CustomConnectors::COnFitView {lbbox} {

	set item [lindex [$lbbox selection get] 0]
	if {[string is space $item]} {return}
	
	if {[$lbbox exists $item] > 0} {
		set cid [$lbbox itemcget $item -text]
	   set ncode [lindex $cid 0] 
	   
	   lassign [hm_ce_getcords $ncode] x y z
	   ::Utils::ViewSet $x $y
	 }
   
   return
}



proc ::CustomConnectors::ComboName {args} {
	
	variable str_combovalue
	variable str_Cname
	
	set name [split $str_Cname _]
	set name [join [lrange $name 1 end] _]
	set str_Cname ${str_combovalue}_$name
	
	
	return
}

proc ::CustomConnectors::ComponetIds {lstIds} {
	
	variable str_combovalue
	variable str_Cname
	
	set name1 [split $str_Cname _]
	set name [join $lstIds _]
	set str_Cname [lindex $name1 0]_$name
	
	
	return
}




proc ::CustomConnectors::OnNmberLinks {args} {
	
	catch {unset arr_inputNods}
	variable arr_inputNods
	variable arr_btn
	variable str_combovalue
	variable str_freeEnd
	catch {unset arr_btn}
	# puts $::CustomConnectors::numlayers 
	# if {$::CustomConnectors::numlayers < 5} {
		
		
		# if {$::CustomConnectors::numlayers == 1} {	
			# set ::CustomConnectors::numlayers 2
		# }
	# } else {
		# set ::CustomConnectors::numlayers 2
		
	# }
	# puts $args--args
	
	# return;
	catch {destroy $args.nodFrm}
	set nodeFrame [ttk::labelframe $args.nodFrm -text "Nodes Input" -labelanchor n]
	pack $nodeFrame -side top -anchor nw -padx 2 -pady 2;
	
	if {$str_combovalue == "UsWeld" || $str_combovalue == "Screw" || $str_combovalue == "Grommet" || $str_combovalue == "RibWeld"} {

		set ncol yellow
		if {$str_combovalue == "UsWeld"} {
			set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_biw  -text " Weld Cylinder " -command "::CustomConnectors::SelectNodes 1" -bg $ncol  -highlightcolor blue]
			pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		} elseif {$str_combovalue == "Screw"} {
			set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_biw  -text " Screwboss /Nut/BIW " -command "::CustomConnectors::SelectNodes 1" -bg $ncol  -highlightcolor blue]
			pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		} elseif {$str_combovalue == "Grommet"} {
			set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_biw  -text " Grommet Hole " -command "::CustomConnectors::SelectNodes 1" -bg $ncol  -highlightcolor blue]
			pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		} elseif {$str_combovalue == "RibWeld"} {
			set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_biw  -text " RIB " -command "::CustomConnectors::SelectNodes 1" -bg $ncol  -highlightcolor blue]
			pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		}
		
		for {set i 1} { $i < $::CustomConnectors::numlayers} {incr i} {
		
			if {$i == 1} {
				set ncol skyblue
			} elseif {$i == 2} {
				set ncol pink
			} elseif {$i == 3} {
				set ncol orange
			} else { 
				set ncol grey
			}
			
			set arr_btn(Link-${i}-Nodes) [button [set nodeFrame].btn_$i  -text " Hole-${i} " -command "::CustomConnectors::SelectNodes [expr ($i + 1)]" -bg $ncol  -highlightcolor blue]
			
			pack $arr_btn(Link-${i}-Nodes) -side left -anchor nw -padx 5 -pady 5;
		}
		
		return
	
	} elseif {$str_combovalue == "Retainer" || $str_combovalue == "Crashclip"} {
	
		set arr_btn(Hole-1-Nodes) [button [set nodeFrame].btn_1  -text " BIW " -command "::CustomConnectors::SelectNodes 1" -bg yellow  -highlightcolor blue]
		pack $arr_btn(Hole-1-Nodes) -side left -anchor nw -padx 5 -pady 5;
		
		set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_2  -text " Doghouse " -command "::CustomConnectors::SelectNodes 2" -bg skyblue  -highlightcolor blue]
		pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		
		return
		
	} elseif {$str_combovalue == "MetalClip" || $str_combovalue == "PlasticClip" || $str_combovalue == "Snaps"} {
		
		set arr_btn(Hole-1-Nodes) [button [set nodeFrame].btn_1  -text " Hole " -command "::CustomConnectors::SelectNodes 1" -bg yellow  -highlightcolor blue]
		pack $arr_btn(Hole-1-Nodes) -side left -anchor nw -padx 5 -pady 5;
		
		set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_2  -text " Clip Tower " -command "::CustomConnectors::SelectNodes 2" -bg skyblue  -highlightcolor blue]
		pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		
		return
		
	} elseif {$str_combovalue == "Hinge"} {
		
		set arr_btn(Hole-1-Nodes) [button [set nodeFrame].btn_1  -text " Part-1 " -command "::CustomConnectors::SelectNodes 1" -bg yellow  -highlightcolor blue]
		pack $arr_btn(Hole-1-Nodes) -side left -anchor nw -padx 5 -pady 5;
		
		set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_2  -text " Part-2 " -command "::CustomConnectors::SelectNodes 2" -bg skyblue  -highlightcolor blue]
		pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
		
		return
		
	}
	
	if {$str_combovalue == "RibWeld"} {
	
		if {$::CustomConnectors::numlayers == 2} {
		
			set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_2  -text " Rib-Nodes " -command "::CustomConnectors::SelectNodes 1" -bg yellow -highlightcolor blue]
			pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
			
			set arr_btn(Hole-1-Nodes) [button [set nodeFrame].btn_1  -text " Hole-1-Nodes " -command "::CustomConnectors::SelectNodes 2" -bg skyblue  -highlightcolor blue]
			pack $arr_btn(Hole-1-Nodes) -side left -anchor nw -padx 5 -pady 5;
			
			return
			
		} elseif {$::CustomConnectors::numlayers == 3} {
			
			set arr_btn(Rib-Nodes) [button [set nodeFrame].btn_3  -text " Rib-Nodes " -command "::CustomConnectors::SelectNodes 1" -bg yellow  -highlightcolor blue]
			pack $arr_btn(Rib-Nodes) -side left -anchor nw -padx 5 -pady 5;
			
			set arr_btn(Hole-1-Nodes) [button [set nodeFrame].btn_1  -text " Hole-1-Nodes " -command "::CustomConnectors::SelectNodes 2" -bg skyblue -highlightcolor blue]
			pack $arr_btn(Hole-1-Nodes) -side left -anchor nw -padx 5 -pady 5;
			
			set arr_btn(Hole-2-Nodes) [button [set nodeFrame].btn_2  -text " Hole-2-Nodes " -command "::CustomConnectors::SelectNodes 3" -bg pink  -highlightcolor blue]
			pack $arr_btn(Hole-2-Nodes) -side left -anchor nw -padx 5 -pady 5;
			
			return
		}
	}
	
	if {![string is space $::CustomConnectors::numlayers]} {
		
		# puts comklajksj
		for {set i 1} { $i <= $::CustomConnectors::numlayers} {incr i} {
			if {$i == 1} {
				set ncol yellow
			} elseif {$i == 2} {
				set ncol skyblue
			} elseif {$i == 3} {
				set ncol pink
			} elseif {$i == 4} {
				set ncol orange
			} else { 
				set ncol grey
			}
			# set ncol yellow
			set arr_btn(Link-${i}-Nodes) [button [set nodeFrame].btn_$i  -text " Link-${i}-Nodes " -command "::CustomConnectors::SelectNodes $i" -bg $ncol  -highlightcolor blue]
			
			pack $arr_btn(Link-${i}-Nodes) -side left -anchor nw -padx 5 -pady 5;
		}
		
		while {$i < 6} {
			
			catch {unset arr_inputNods($i,nids)}
			incr i
		
		}
	}
	
	
	return
}


proc ::CustomConnectors::btnEnableDis {args} {

	variable arr_btn
	
	if {$args ==1} {
		set strVal disable
	} else {
		set strVal normal
	}
	foreach name [array name arr_btn] {
		if {[info exist $arr_btn($name)]} {
			$arr_btn($name) configure -state $strVal
		}
	}
	
	return
}



proc ::CustomConnectors::AddTabToframework {str_TabName str_mainTabFrame} {
	
	::CustomConnectors::RemoveTab $str_TabName
    set frm_main $str_mainTabFrame
    if {[winfo exists $frm_main]} {
        destroy $frm_main
    }
    frame $frm_main -bd 2 -relief  ridge;
    set currentTabs [hm_framework getalltabs]
   
	if {[lsearch $currentTabs "$str_TabName"] == -1} {
       hm_framework addtab $str_TabName $frm_main
	   hm_framework resizetab $str_TabName 700
	} else {
       hm_framework activatetab $str_TabName
	}
	return $frm_main
	
}

proc ::CustomConnectors::RemoveTab {str_TabName} {
	
	if { ![catch {hm_framework removetab $str_TabName};]} {
		return 1;
	} else {
		return 0;
	}
	
}

proc ::CustomConnectors::destroyall {frame_name tab_name} {

	# hm_framework unregisterproc ::CustomConnectors::UpdateEidOnpChnage 
	if { ![catch {hm_framework removetab $tab_name};]} {
		return 1;
	} else {
		return 0;
	}
	
}



proc ::CustomConnectors::ConfigReg {args} {

	global env	
	set cpath [file join $::CustomConnectors::scriFPath Config.cfg]
	set str_fordFEconfigDir  $::CustomConnectors::scriFPath	
	set lstenvies [array names env]	
	set postVari {HW_CONFIG_PATH}
	if { [file exists $cpath] } {
        if { [catch { *CE_FE_LoadFeConfig $cpath 1 1; } err ] } { 
              tk_messageBox -message "Error while loading the connector config file";
              return 1;
        }
    } else {
        tk_messageBox -message "Not able to find the connector config file to realize connectors $cpath";
        return 1;
    }
 
	if {[info exists ::env(HW_CONFIG_PATH)]} {		
		set lst_values [split $::env(HW_CONFIG_PATH) ";"]	
		# puts "$lst_values == $str_fordFEconfigDir"
		if {[lsearch $lst_values $str_fordFEconfigDir] == -1} {		
			
			exec cmd.exe /c setx HW_CONFIG_PATH "%HW_CONFIG_PATH%;$str_fordFEconfigDir"
			
			return 2
		}	
	} else {
			
		exec cmd.exe /c setx HW_CONFIG_PATH $str_fordFEconfigDir
		
		return 2
	}
	
	return 0
    
}


proc ::CustomConnectors::Main {args} {
	
	# set nRetun [::CustomConnectors::ConfigReg]
	 
	# if {$nRetun == 2} {
		# tk_messageBox -message "The Config path is set now, Please relunch the Hm session";
		# return;
	# }
	
	variable frm_create;
	
	set userProfile [lindex [hm_framework getuserprofile] 0];
	if {$userProfile == "Abaqus" || $userProfile == "LsDyna" || $userProfile == "Nastran" || $userProfile == "Pamcrash2G" || $userProfile == {OptiStruct}} {
			
		variable arr_levelStateHolder
		catch {array unset arr_levelStateHolder}
		array set arr_levelStateHolder [list]
	
		::CustomConnectors::Deltag1
		::CustomConnectors::Deltag_vector
		::CustomConnectors::SetElemnetsType
		::CustomConnectors::MainGui $args
		
		if {$userProfile == "Abaqus" } {
			foreach  l $::CustomConnectors::lstConnection {
				if {$l != {Antolin} && $l != {Convert}} {
					${frm_create}.c$l configure -state disabled;
				}
			}
			tk_messageBox -title "Fixation Modelling Tool" -message "Click on 'Antolin button' to create Abaqus connections" -icon info;
		}
	
	} else {
		catch {pack forget .fcustom}
		tk_messageBox -title "Fixation Modelling Tool" -message "User profile not supported for Fixation Modelling Tool..! Supported ones are LsDyna, Nastran, OptiStruct, Abaqus and Pamcrash." -icon error;
		
		return;
	}
	
	
}

proc ::CustomConnectors::Log {flag message} {
	
	variable username	
	switch $flag {
		
		0 {
			set fp [open $::CustomConnectors::log_filepath w] 
			puts $fp "\[[clock format [clock seconds] -format %D::%H:%M:%S]\]Info : $message"
			close $fp
		} 
		1 {
			set fp [open $::CustomConnectors::log_filepath a] 
			puts $fp "\[[clock format [clock seconds] -format %D::%H:%M:%S]\]Info : $message"
			close $fp
		}
	
	}
}

proc ::CustomConnectors::Log_antolin {flag message} {
	
	variable username	
	switch $flag {
		
		0 {
			set fp [open $::CustomConnectors::log_filepath_antolin w] 
			puts $fp "\[[clock format [clock seconds] -format %D::%H:%M:%S]\]Info : $message"
			close $fp
		} 
		1 {
			set fp [open $::CustomConnectors::log_filepath_antolin a] 
			puts $fp "\[[clock format [clock seconds] -format %D::%H:%M:%S]\]Info : $message"
			close $fp
		}
	
	}
}

proc ::CustomConnectors::GetLogPath {filepath} {
	
	variable username
	
	set str_configFile $filepath
	set fp [open $str_configFile r]
	set file_data [read $fp]
	close $fp
	set data [join [split $file_data "\n"]]
	
	set d_m_y [string map {/ "_"} [clock format [clock seconds] -format {%d-%m-%Y}]];
	set altair_logpath [file join $data ${username}_connector_Log_${d_m_y}_altair.txt];
	set antolin_logpath [file join $data ${username}_connector_Log_${d_m_y}_antolin.txt];

	return [list $altair_logpath $antolin_logpath]
	
}


proc ::CustomConnectors::main_fun {} {
	
	set userdata [ exec whoami]
	
	#check internet connectivity and tool validity here 
	set filePath [file join $::CustomConnectors::path_materialdata validity.txt]
	set ret [::antolin::license::checkPAValidity $filePath];
	set log_file_paths [::CustomConnectors::GetLogPath [file join $::CustomConnectors::path_materialdata log_config.txt]]
	set ::CustomConnectors::log_filepath [lindex $log_file_paths 0];
	set ::CustomConnectors::log_filepath_antolin [lindex $log_file_paths 1];
	#set ret 0
	if {$ret == 0} {
	
		tk_messageBox -title "Connection modelling" -message "Please prioritize the 'Antolin' option. It has been tailored to meet Antolin standards. \nIn the event you encounter any constraints or limitations with this choice, we recommend exploring other available options" -icon info;
		
		# puts "#call function to launch connection tool "  
		set lst_regProcs [hm_framework getregisteredprocs after_userprofile]
		set n_procs [llength [lsearch -all $lst_regProcs "::CustomConnectors::Main"]]
		if {$n_procs != ""} {
			for {set i 1} {$i <= $n_procs} {incr i} {
				hm_framework unregisterproc ::CustomConnectors::Main after_userprofile
			}
		}
		
		hm_framework registerproc ::CustomConnectors::Main after_userprofile
		::CustomConnectors::Main;
		
		if {![file exists $::CustomConnectors::log_filepath]} {
			catch {file mk dir [file dir $::CustomConnectors::log_filepath]}
			::CustomConnectors::Log 0 "Connector Modelling Tool Invoked"
			::CustomConnectors::Log 1 "USER - $userdata"	
		} else {
			#::CustomConnectors::Log 1 "Connector Modelling Tool Invoked"
		}
		
		if {![file exists $::CustomConnectors::log_filepath_antolin]} {
			catch {file mk dir [file dir $::CustomConnectors::log_filepath_antolin]}
			::CustomConnectors::Log_antolin 0 "Connector Modelling Tool Invoked"
			::CustomConnectors::Log_antolin 1 "USER - $userdata"	
		} else {
			#::CustomConnectors::Log_antolin 1 "Connector Modelling Tool Invoked"
		}
		
		
	} elseif {$ret == 1} {
		::CustomConnectors::Log_antolin 1 "Automation validity is over. Kindly contact 'Antolin Design and Business Services Pvt Ltd'"
		tk_messageBox -message "Automation validity is over. Kindly contact 'Antolin Design and Business Services Pvt Ltd'" -icon error;
		return;
	} else {
		::CustomConnectors::Log_antolin 1 "Kindly check your internet connection and try again"
		tk_messageBox -message "Kindly check your internet connection and try again" -icon error;
		return;
	}
}

::CustomConnectors::main_fun 

