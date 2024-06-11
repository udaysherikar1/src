
catch {namespace delete ::convert}

namespace eval ::convert {

	set ::convert::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::convert::scriptDir coupKin_to_B31_RigidBeam.tbc]]} {
		source [file join $::convert::scriptDir coupKin_to_B31_RigidBeam.tbc];
	} else {
		source [file join $::convert::scriptDir coupKin_to_B31_RigidBeam.tcl];
	}
}

proc ::convert::getDisplacementElems {} {

	*createmark elems 1 "displayed";
	set beam_elems [hm_getmark elems 1];
	
	return $beam_elems	
}

proc ::convert::createNewComponent {beamId} {

	set beam_compId [hm_getvalue elem id=$beamId dataname=component];
	set beam_compName [hm_getvalue comp id=$beam_compId dataname=name];
	
	set newCompName [lindex [split $beam_compName "_"] 0];
	set newCompName ${newCompName}_Rigid
	
	if {![hm_entityinfo exist comps $newCompName] } {
		*createentity comps cardimage=Part name=$newCompName;
	}
		
	*currentcollector components $newCompName
}


proc ::convert::createRigids {rigidNodeIds} {
	*elementtype 5 2
	eval *createmark nodes 2 $rigidNodeIds;
	*rigidlinkinodecalandcreate 2 0 1 123456
}

proc ::convert::deleteBeams {beamId} {

	eval *createmark elems 1 $beamId;
	*deletemark elems 1;
}

proc ::convert::deleteRigids {rigidsElems} {
	foreach regidId $rigidsElems {
		set elem_config [hm_getvalue element id=$regidId dataname=config];
		if {$elem_config == 55} {
			*createmark elems 1 $regidId;
			*deletemark elems 1;
		}
	}
}

proc ::convert::convertConnections {beam_elems} {

	set ::connector::connection_log_var  [list]
	set ::connector::connection_log_var [list [list "Converted R-B-R To Rigid" "=" [llength $beam_elems] "connector(s)"]];
	
	::hwat::utils::BlockMessages "On"
	foreach beamId $beam_elems {
	
		set elem_config [hm_getvalue element id=$beamId dataname=config	];
		if {$elem_config > 100} {
			# skip elements other than 1d
			continue
		}
				
		::convert::createNewComponent $beamId;
		
		set beam_nodeIds [hm_getvalue element id=$beamId dataname=nodes];
		
		#find rigids attached to beams
		*createmark element 1 $beamId;
		*findmark elements 1 257 1 elements 0 2
		set rigidsElems [hm_getmark elements 2];
				
		*clearmark nodes 1
		*clearmark nodes 2
		
		#get rigid nodes
		foreach rigidId $rigidsElems {
			*appendmark node 2 "by elem" $rigidId;
		}
		set rigidNodeIds [hm_getmark node 2];
				
		
		#find shells attached to rigid elements
		eval *createmark elements 1 $rigidsElems
		*findmark elements 1 257 1 elements 0 2;
		set shells_attached_rigids [hm_getmark elems 2];
		
		::convert::deleteBeams $beamId;
		
		#get shell nodes 
		eval *createmark elements 1 $shells_attached_rigids;
		*findmark elements 1 1 1 nodes 0 2
		set shell_nodes [hm_getmark nodes 2];
				
		*clearmark nodes 1
		*clearmark nodes 2
		
		eval *createmark node 1 $shell_nodes;
		eval *createmark node 2 $rigidNodeIds;
		
		*markintersection  node 1 node 2;
		set filered_rigidNodeIds [hm_getmark node 2];
		set filered_rigidNodeIds [lremove $filered_rigidNodeIds $beam_nodeIds];
					
		::convert::createRigids $filered_rigidNodeIds;
		
		::convert::deleteRigids $rigidsElems;
		
	}	
	
	::hwat::utils::BlockMessages "Off"
	::connector::log_files_write;
}


proc ::convert::ExecuteConnectionConvert {} {
		
	set ::convert::profile [hm_info templatetype];
	
	if {$::convertGUI::str_parrentElement == "Rigid-Beam-Rigid" && $::convertGUI::str_convertElem == "Rigid"} {
		set ans [tk_messageBox -message "Keep only \"BEAM\" elements on display for Rigid creation.  Do you want to proceed?" -type yesno];
		if {$ans == "no"} {
			return
		}
		set beam_elems [::convert::getDisplacementElems];
		::convert::convertConnections $beam_elems;
	}
	
	if {$::convertGUI::str_parrentElement == "COUP_KIN"} {
		if {$::convert::profile != "abaqus"} {
			tk_messageBox -message "\"COUP_KIN\" conversion supported only for ABAQUS" -icon error;
			return
		}
		
		set ans [tk_messageBox -message "Keep only \"COUP_KIN\" elements on display.  Do you want to proceed?" -type yesno];
		if {$ans == "no"} {
			return
		}
		
		if {$::convertGUI::str_convertElem == "B31"} {
			# create property
			set propId [::abaqus::coupKin_to_B31::createProp];
			set COUP_KIN_elems [::convert::getDisplacementElems];
			::abaqus::coupKin_to_B31::convert_To_B31 $COUP_KIN_elems $propId;
		
		} elseif {$::convertGUI::str_convertElem == "Rigid_BEAM"} {
			set COUP_KIN_elems [::convert::getDisplacementElems];
			::abaqus::coupKin_to_rigidBeam::convert_To_RigidBeam $COUP_KIN_elems;
				
		}
	}
	#*unmaskall2;
}

#::convert::ExecuteConnectionConvert

