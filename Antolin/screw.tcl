
if {[namespace exists ::screw]} {
	namespace delete ::screw
}

namespace eval ::screw {

	set ::screw::scriptDir [file dirname [info script]];
	if {[file exists [file join $::screw::scriptDir Welds.tbc]]} {
		source [file join $::screw::scriptDir Welds.tbc];
	} else {
		source [file join $::screw::scriptDir Welds.tcl];
	}
	if {[file exists [file join $::screw::scriptDir utils.tbc]]} {
		source [file join $::screw::scriptDir utils.tbc];
	} else {
		source [file join $::screw::scriptDir utils.tcl];
	}
	if {[file exists [file join $::screw::scriptDir create_RP.tbc]]} {
		source [file join $::screw::scriptDir create_RP.tbc];
	} else {
		source [file join $::screw::scriptDir create_RP.tcl];
	}
	if {[file exists [file join $::screw::scriptDir screw_sandwich_weld.tbc]]} {
		source [file join $::screw::scriptDir screw_sandwich_weld.tbc];
	} else {
		source [file join $::screw::scriptDir screw_sandwich_weld.tcl];
	}
	
	set ::screw::profile [hm_info templatetype];
}

proc ::screw::rad_MaterialBtn_callback {arg} {

	if { $arg == "plastic_plastic"} {
		set ::connector::screw_radiobtn_material 1;
	}
	if { $arg == "plastic_biw"} {
		tk_messageBox -message "Select element(s) on screwing face for \"Plastic - BIW\" connections" -icon info -title "Antolin"
		set ::connector::screw_radiobtn_material 2;
	}
}

proc ::screw::rad_WasherBtn_callback {arg} {

	if { $arg == "zerolayer"} {
		set ::connector::screw_radiobtn_washer 1;
	}
	if { $arg == "onelayer"} {
		set ::connector::screw_radiobtn_washer 2;
	}
}

proc ::screw::rad_MethodBtn_callback {arg sub_frm1} {

	if { $arg == "r_b_r"} {
		# joint length
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state normal;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state normal;
		#joint on slave 
		if {$::connector::profile == "pamcrash2g"} {
			$::connector::slaveJoint_frm config -state normal;
		} else {
			$::connector::slaveJoint_frm config -state disabled;
		}
		#washer
		$::connector::screw_washer_radioBtn1 config -state normal;
		$::connector::screw_washer_radioBtn2 config -state normal;
				
		set ::connector::screw_radiobtn_methods 1;
		::connection::help::displayScrewImage $sub_frm1;
	}
	if { $arg == "rigid_patch"} {
		# joint length
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state normal;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state normal;
		#joint on slave 
		if {$::connector::profile == "pamcrash2g"} {
			$::connector::slaveJoint_frm config -state normal;
		} else {
			$::connector::slaveJoint_frm config -state disabled;
		}
		#washer
		$::connector::screw_washer_radioBtn1 config -state 	;
		$::connector::screw_washer_radioBtn2 config -state disabled;
				
		set ::connector::screw_radiobtn_methods 2;
		::connection::help::displayScrewImage $sub_frm1;
	}
	if { $arg == "Skoda"} {
		# joint length
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state disabled;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state disabled;
		#joint on slave 
		$::connector::slaveJoint_frm config -state disabled;
		
				
		#washer
		$::connector::screw_washer_radioBtn1 config -state disabled;
		$::connector::screw_washer_radioBtn2 config -state disabled;
		
		set ::connector::screw_radiobtn_methods 3;
		::connection::help::displayScrewImage $sub_frm1;
	}
	
	if { $arg == "Audi"} {
		set ::connector::screw_radiobtn_methods 4;
		::connection::help::displayScrewImage $sub_frm1;
	}
	
	if { $arg == "collar"} {
		# joint length
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state normal;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state normal;
		#joint on slave 
		if {$::connector::profile == "pamcrash2g"} {
			$::connector::slaveJoint_frm config -state normal;
		} else {
			$::connector::slaveJoint_frm config -state disabled;
		}
		#washer
		$::connector::screw_washer_radioBtn1 config -state normal;
		$::connector::screw_washer_radioBtn2 config -state normal;
				
		set ::connector::screw_radiobtn_methods 5;
		::connection::help::displayScrewImage $sub_frm1;
	}
}

proc ::screw::SandwichWeld { collar_usweld_radioBtn skoda_usweld_radioBtn sub_frm1 } {
	
	if {$::connector::sandwichConnection_flag == 1} {
		$collar_usweld_radioBtn config -state disabled
		if {$::connector::profile == "pamcrash2g"} {
			$skoda_usweld_radioBtn config -state disabled
		}
	} else {
		$collar_usweld_radioBtn config -state normal
		if {$::connector::profile == "pamcrash2g"} {
			$skoda_usweld_radioBtn config -state normal
		}
	}
	
	if {$::connector::screw_radiobtn_methods == 5} {
		#if collar weld selected, reselect to r-b-r
		set ::connector::screw_radiobtn_methods 1;
	}
	
	::connection::help::displayScrewImage $sub_frm1;
}

proc ::screw::getCirleCenter {hole_nodes} {

	# *createcenternode [lindex $hole_nodes 0] [lindex $hole_nodes 1] [lindex $hole_nodes 2];
	eval *createmark nodes 1 $hole_nodes;
	*createbestcirclecenternode nodes 1 0 1 0;
	set circle_center [::hwat::utils::GetEntityMaxId node];
	set circle_x [hm_getvalue node id=$circle_center dataname=x];
	set circle_y [hm_getvalue node id=$circle_center dataname=y];
	set circle_z [hm_getvalue node id=$circle_center dataname=z];

	#*createnode $circle_x $circle_y $circle_z;
	#set center [::hwat::utils::GetEntityMaxId node]
	*nodecleartempmark;
	return [list $circle_x $circle_y $circle_z];

}

proc ::screw::getNodesOnCircle {lst_closed_nodeloop nodeId} {

	set hole_nodes "";
	foreach nodeloop $lst_closed_nodeloop {
		if {[lsearch $nodeloop $nodeId] != -1} {
			set hole_nodes $nodeloop;
			break;
		}
	}
	set hole_nodes [lsort -increasing -real [lsort -unique $hole_nodes]];
	set hole_nodes [lrange $hole_nodes 1 end];

	return $hole_nodes;
}

proc ::screw::getNodesOnBossCircle {f_nodes compId} {
	#this function search closest node from female part center to boss top node layer
	set cir_center [::screw::getCirleCenter $f_nodes];
	set circle_x [lindex $cir_center 0];
	set circle_y [lindex $cir_center 1];
	set circle_z [lindex $cir_center 2];

	*createmark node 1 "by comp" $compId;

	set i 1;
	set boss_node_list [list]
	set total_distance 0;
	set avg_distance 0;
	while {$i <= 15} {
		set boss_nodeId [hm_getclosestnode $circle_x $circle_y $circle_z 0 1];
		
		if {$i == 1} {
			lappend boss_node_list $boss_nodeId;
			#get comp id of 1st closest node
			*createmark elem 1 "by node" $boss_nodeId;
			#set main_bossComp_Id [hm_getvalue elem id=[lindex [hm_getmark elem 1] 0] dataname=component];
			set main_bossComp_Id [hm_getvalue elem markid=1 dataname=component];
			set main_bossComp_Id [lsort -unique $main_bossComp_Id];
			if {[llength $main_bossComp_Id]>1} {
				#neglect boss node if associated with  2 comps
				*appendmark node 1 $boss_nodeId;
				*createmark elem 1 "by node" $boss_nodeId;
				set boss_nodeId [hm_getclosestnode $circle_x $circle_y $circle_z 0 1];
				
				*createmark elem 1 "by node" $boss_nodeId;
				set main_bossComp_Id [hm_getvalue elem id=[lindex [hm_getmark elem 1] 0] dataname=component];
				#set main_bossComp_Id [hm_getvalue elem markid=1 dataname=component];
				set main_bossComp_Id [lsort -unique $main_bossComp_Id];
			}
		}
		
		#to neglect this node "boss_nodeId" in next loop
		*appendmark node 1 $boss_nodeId;
		set x2 [hm_getvalue node id=$boss_nodeId dataname=x];
		set y2 [hm_getvalue node id=$boss_nodeId dataname=y];
		set z2 [hm_getvalue node id=$boss_nodeId dataname=z];
		set distance [::antolin::connection::utils::getDistanceFromCordinates $circle_x $circle_y $circle_z $x2 $y2 $z2];

		if {$i <=4 } {
			#calculate avg distace for closest 4 nodes (assuming boss has minimum 4 elements)
			set total_distance [expr $total_distance+$distance];
			set avg_distance [expr [expr $total_distance/${i}.0] * 1.3];
		}
		
		if {$i > 4 && $distance > $avg_distance} {
			incr i
			continue;
		}
		
		*createmark elem 1 "by node" $boss_nodeId;
		#set comp_Id [hm_getvalue elem id=[lindex [hm_getmark elem 1] 0] dataname=component];
		set boss_comp_Ids [hm_getvalue elem markid=1 dataname=component];
		set boss_comp_Ids [lsort -unique $boss_comp_Ids];
		
		eval *createmark comp 1 $boss_comp_Ids;
		eval *createmark comp 2 $main_bossComp_Id;
		*markintersection comp 1 comp 2;
		set common_comp_id [hm_getmark comp 1];
		
		if {[llength $common_comp_id] != 1} {
			# dont take nodes if they are not in same component
			incr i
			continue
		}
			
		lappend boss_node_list $boss_nodeId;

		incr i
	}

	::hwat::utils::ClearMark nodes 1;
	set boss_node_list [lsort -unique $boss_node_list];
	
	return $boss_node_list
	
}

proc ::screw::getBottomLayerNodes {toplayerNodes unit_vector} {

	#set elem_layer [list];
	set node_bottom_layers [list];
	foreach nodeId $toplayerNodes {

		set bottom_nodeId "";

		*createmark elem 1 "by node" $nodeId;
		
		set elems [hm_getmark elem 1];
		set attachedNodes [lsort -unique [join [hm_getvalue elem mark=1 dataname=nodes]]];
				
		set angle 360;
		foreach attachedNodeId $attachedNodes {
			if {$attachedNodeId == $nodeId} {
				continue;
			}
			set temp_unit_vector [::antolin::connection::utils::calculateUnitVector $nodeId $attachedNodeId];
			set n_angle [::hwat::math::AngleBetweenVectors $unit_vector $temp_unit_vector];
			
			if {$n_angle <= $angle} {
				set angle $n_angle;
				set bottom_nodeId $attachedNodeId;
			}
			
		}	
		
		lappend node_bottom_layers $bottom_nodeId;
	}
	
	eval *createmark node 1 $node_bottom_layers;
	eval *createmark node 2 $toplayerNodes;
	*markdifference node 1 node 2;
	set node_bottom_layers [hm_getmark node 1];
	set node_bottom_layers [lsort -unique [join $node_bottom_layers]];

	return $node_bottom_layers;
}

proc ::screw::getNodeLayersOnBoss {circle_x circle_y circle_z boss_nodes} {

	#female part center node
	*createnode $circle_x $circle_y $circle_z;
	set centernode1 [::hwat::utils::GetEntityMaxId node];

	#boss center node
	eval *createmark nodes 1 $boss_nodes;
	*createbestcirclecenternode nodes 1 0 1 0;
	#*createcenternode [lindex $boss_nodes 0] [lindex $boss_nodes 1] [lindex $boss_nodes 2];
	set centernode2 [::hwat::utils::GetEntityMaxId node];
	# vector   center-1 to center - 2
	set unit_vector [::antolin::connection::utils::calculateUnitVector $centernode1 $centernode2];

	*nodecleartempmark;

	set all_boss_nodes $boss_nodes;
	set bottom_layer_nodes $boss_nodes;
	set i 1;
	while {$i <= $::connector::element_layers} {
		set bottom_layer_nodes [::screw::getBottomLayerNodes $bottom_layer_nodes $unit_vector];
		lappend all_boss_nodes $bottom_layer_nodes;
		incr i;
	}
	set all_boss_nodes [lsort -unique [join $all_boss_nodes]];
	
	return [list $all_boss_nodes $unit_vector];

}

proc ::screw::Assign_prop_mat_to_beam {weldCollectorName} {

	set prop_Id [::welds::assignProperty $weldCollectorName];
	set mat_Id [::welds::assignMaterial $weldCollectorName];

	#assign prop and mat to comp
	*createmark comps 1 $weldCollectorName;
	set comp_Id [hm_getmark comp 1];
	*setvalue comps id=$comp_Id propertyid={props $prop_Id}
	*setvalue props id=$prop_Id STATUS=2 materialid={mats $mat_Id}
}


proc ::screw::getComponentThickness {compId} {

	set comp_thickness 0;
	catch {set comp_thickness [hm_getvalue comp id=$compId dataname=thickness]};

	if {$comp_thickness == 0} {
		tk_messageBox -message "Thickness not assigned to component id = $compId" -icon error;
		continue
	}

	if {$::screw::profile == "pamcrash2g" && $comp_thickness >= 99.0} {
		set comp_thickness 0;

		*createmark element 1 "by comp" $compId;
		set comp_elems [hm_getmark elem 1]
		catch {set comp_thickness [hm_getvalue elem id=[lindex $comp_elems 0] dataname=thickness]};
		if {$comp_thickness == 0} {
			tk_messageBox -message "Element thickness or component thickness not assigned to component id = $compId" -icon error;
			continue
		}
	}
	
	return $comp_thickness
}


# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  PLASTIC - PLASTIC
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

proc ::screw::createScrewRepresentation_plastic_plastic {adjacent_elem boss_nodes_top_layer f_nodes f_washerNodes boss_nodes\
													weldCollectorName comp_thickness avg_elem_size unit_vector vector} {

	#create rigids in correct collector
	*currentcollector components "Screw_rigids"

	if {$::screw::profile == "lsdyna"} {
		#common boss for both options in lsdyna
		::antolin::connection::utils::createRbody_lsdyna $boss_nodes;
	}

	if {$::screw::profile == "pamcrash2g" || $::screw::profile == "abaqus"} {
		#common boss for both options in pamcrash
		::welds::createRigids $boss_nodes "Screw_rigids";
	}
	set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
	lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			
	#if {$::connector::normal_flag == 1} {
	#	set vector "[expr [lindex $vector 0]*-1] [expr [lindex $vector 1]*-1] [expr [lindex $vector 2]*-1]"
	#}
	
	if {$::connector::screw_radiobtn_methods == 1 || $::connector::screw_radiobtn_methods == 5 } {
		#create rigids on female component

		if {$::screw::profile == "lsdyna"} {
			::antolin::connection::utils::createRbody_lsdyna $f_washerNodes;
		}
		if {$::screw::profile == "pamcrash2g" || $::screw::profile == "abaqus"} {
			::welds::createRigids $f_washerNodes "Screw_rigids";
		}

		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
		#aling boss master node wrt female part master node
		set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
				
		#set vector [::antolin::connection::utils::calculateUnitVector $rigid_centerNodeId_1 $rigid_centerNodeId_2];
				
		::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
		if {$::screw::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
			#joint on slave is ON
			set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_1 $f_washerNodes $rigid_centerNodeId_2 $boss_nodes $vector];
			set rigid_centerNodeId_1 [lindex $ret 0];
			set rigid_centerNodeId_2 [lindex $ret 1];
			
			#set avg_dist 0.5
		}
		::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
		::screw::Assign_prop_mat_to_beam $weldCollectorName;

	} elseif {$::connector::screw_radiobtn_methods == 2 } {

		#create fake patch element or rigid patch above female component
		set RP_comp "Screw_Rigid_Patch"
		set RP_elems [::circularRP::createRP_main $f_nodes $rigid_centerNodeId_2 $RP_comp $comp_thickness $avg_elem_size];
		
		if {$::screw::profile == "lsdyna"} {
			set RP_periphery_elem_comp_name "Screw_Tied_Nullbeam"
			set null_beam_compId [::antolin::connection::utils::create_bars_on_edges $RP_elems $RP_periphery_elem_comp_name $::screw::profile];
			set null_beam_propId [::antolin::connection::utils::createNullBeamProps $RP_periphery_elem_comp_name $::screw::profile];
			#assign prop to component 
			*setvalue comps id=$null_beam_compId propertyid={props $null_beam_propId}
		}
		if {$::screw::profile == "pamcrash2g"} {
			set RP_periphery_elem_comp_name "Screw_Tied_Bar"
			::antolin::connection::utils::create_bars_on_edges $RP_elems $RP_periphery_elem_comp_name $::screw::profile;
		}
		
		lappend ::connector::recentlyCreatedEntity $RP_elems
		set ::connector::recentlyCreatedEntity [join $::connector::recentlyCreatedEntity];

		*currentcollector components "Screw_rigids"
		#get RP nodes
		eval *createmark elem 1 $RP_elems;
		set RP_nodes [hm_getvalue elem mark=1 dataname=nodes];
		set RP_nodes [lsort -unique [join $RP_nodes]];
		if {$::screw::profile == "lsdyna"} {
			::antolin::connection::utils::createRbody_lsdyna $RP_nodes;
			set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		}
		if {$::screw::profile == "pamcrash2g" || $::screw::profile == "abaqus"} {
			::welds::createRigids $RP_nodes "Screw_rigids";
			set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		}

		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
		#aling boss master node wrt female part master node
		set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];

		#set vector [::antolin::connection::utils::calculateUnitVector $rigid_centerNodeId_1 $rigid_centerNodeId_2];
		#puts "rigid centers vector --  $vector"
		
		::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
		if {$::screw::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
			#joint on slave is ON
			set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_1 $RP_nodes $rigid_centerNodeId_2 $boss_nodes $vector];
			set rigid_centerNodeId_1 [lindex $ret 0];
			set rigid_centerNodeId_2 [lindex $ret 1];
			
			#set avg_dist 0.5
		}
		
		::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
		::screw::Assign_prop_mat_to_beam $weldCollectorName;

	}
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::screw::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="Screw_rigids" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}
	
	*nodecleartempmark;
}



proc ::screw::exec_screw_plastic_plastic_subfunction {f_nodes compId comp_thickness adjacent_elem} {

	#get boss part edge nodes
	#from female part center node, closest node is on boss only
	set cir_center [::screw::getCirleCenter $f_nodes];
	set circle_x [lindex $cir_center 0];
	set circle_y [lindex $cir_center 1];
	set circle_z [lindex $cir_center 2];
	*createmark node 1 "by comp" $compId
	set boss_nodeId [hm_getclosestnode $circle_x $circle_y $circle_z 0 1];
		
	::hwat::utils::ClearMark nodes 1;
		
	#workaround function to get pamcrash top layer nodes. HM API dont return correct boss node loop for few cases
	set boss_nodes_top_layer [::screw::getNodesOnBossCircle $f_nodes $compId];
	if {[ llength $boss_nodes_top_layer ] == 0} {
		return
	}

	set ret [::screw::getNodeLayersOnBoss $circle_x $circle_y $circle_z $boss_nodes_top_layer];
	set all_boss_nodes [lindex $ret 0];
	set unit_vector [lindex $ret 1];
	
	if {$::connector::element_layers == 0 && $::connector::screw_radiobtn_washer == 2} {
		# use case if user want to select washer on boss and hole
		set ret [::antolin::connection::utils::GetWasherNodeIds $all_boss_nodes];
		set f_boss_washerElements [lindex $ret 0];
		set all_boss_nodes [lindex $ret 1];
	}
	::hwat::utils::ClearMark nodes 1;
		
	set ret [::antolin::connection::utils::GetWasherNodeIds $f_nodes];
	set f_washerElements [lindex $ret 0];
	set f_washerNodes [lindex $ret 1];
	
	set vector [::antolin::connection::utils::getAvgElementNormals $f_washerElements];
	eval *createmark elem 1 $f_washerElements;
	set avg_elem_size [hm_getaverageelemsize 1]
		
	if {$::connector::screw_radiobtn_washer == 1} {
		#dont consider waster nodes for rigid creations
		set f_washerNodes $f_nodes;
	}
	
	
	#------------------------------------------------------------------------------------------	
	#------------------------------------------------------------------------------------------	
	# SKODA methodology
	if {$::connector::screw_radiobtn_methods == 3} {
						
		#create comp collector for rigids
		set weldCollectorName "Skoda_Rigids_connections";
		if {![hm_entityinfo exist comps $weldCollectorName] } {
			*createentity comps cardimage=Part name=$weldCollectorName;
		}

		set m_node_set_name "SECFO_Screw_Boss_Nodes_LOC_1"
		set m_elem_set_name "SECFO_Screw_Boss_Elem_LOC_1"
		set f_node_set_name "SECFO_Screw_Hole_Nodes_LOC_1"
		set f_elem_set_name "SECFO_Screw_Hole_Elem_LOC_1"
		set m_section_name "SECFO_Screw_Boss_LOC_1"
		set f_section_name "SECFO_Screw_Hole_LOC_1"
		
		::skoda::connection::main $weldCollectorName $boss_nodes_top_layer $all_boss_nodes $f_nodes $m_node_set_name\
								$m_elem_set_name $f_node_set_name $f_elem_set_name $m_section_name $f_section_name "screw";
		
		
	} elseif {$::connector::sandwichConnection_flag == 1} {
		#sandwich connection 
		set weldCollectorName [::antolin::connection::utils::createWeldCollector "SCREW_PLASTIC" "PLASTIC" "Screw_rigids" "_XXSCR" 0];
		::screw::sandwich::Main $adjacent_elem $boss_nodes_top_layer $f_nodes $f_washerNodes\
														$weldCollectorName $comp_thickness $avg_elem_size $vector
	
	} else {
		# GENERAL 	methodology	
		set weldCollectorName [::antolin::connection::utils::createWeldCollector "SCREW_PLASTIC" "PLASTIC" "Screw_rigids" "_XXSCR" 0];
		::screw::createScrewRepresentation_plastic_plastic $adjacent_elem $boss_nodes_top_layer $f_nodes $f_washerNodes\
														$all_boss_nodes $weldCollectorName $comp_thickness $avg_elem_size $unit_vector $vector;
																					
	}
}

proc ::screw::exec_screw_plastic_plastic_collar {} {
	
	*createmarkpanel nodes 1 "Select node(s) for screw creation" 7;
	set screw_edgeNodeIds [hm_getmark nodes 1];
	if {$screw_edgeNodeIds == "" } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return
	}
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
	
	*createmark elem 1 "by node" $screw_edgeNodeIds;
	set adjacent_elem [hm_getmark elem 1];
	#puts "adjacent_elem -- $adjacent_elem"
	set compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
	
	set comp_thickness [::screw::getComponentThickness $compId];
	
	if {$comp_thickness == 0} {
		continue;
	}
	
	set ::connector::connection_log_var [list [list "Screw collar" "=" 1 "connector(s)"]];
	
	set f_nodes $screw_edgeNodeIds;
	
	::screw::exec_screw_plastic_plastic_subfunction $f_nodes $compId $comp_thickness $adjacent_elem
	
	::hwat::utils::ClearMark nodes 1;
	::hwat::utils::ClearMark elements 1;

}

proc ::screw::exec_screw_plastic_plastic {} {

	*createmarkpanel nodes 1 "Select node(s) for screw creation";
	set screw_nodeIds [hm_getmark nodes 1];
	if {$screw_nodeIds == "" } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return
	}
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];

	eval *createmark nodes 1 $screw_nodeIds;
	*findmark nodes 1 257 1 elements 0 2
	set neibhour_elems [hm_getmark elems 2];

	set ::connector::connection_log_var [list [list "Screw" "=" [llength $screw_nodeIds] "connector(s)"]];
	
	eval *createmark elems 1 $neibhour_elems;
	hm_getnearbyentities inputentitytype=elems inputentitymark=1 outputentitytypes={elems} outputentitymark=2 radius=25 nearby_search_method=sphere
	set lst_closed_nodeloop [hm_getedgeloops2 element  markid=2 looptype=3];

	foreach nodeId $screw_nodeIds {

		*createmark elem 1 "by node" $nodeId;
		set adjacent_elem [hm_getmark elem 1];
		#puts "adjacent_elem -- $adjacent_elem"
		set compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
		
		set comp_thickness [::screw::getComponentThickness $compId];
		
		if {$comp_thickness == 0} {
			continue;
		}		
		#get female part edge nodes
		set f_nodes [::screw::getNodesOnCircle $lst_closed_nodeloop $nodeId];
		if {[ llength $f_nodes ] == 0} {
			continue
		}
		::screw::exec_screw_plastic_plastic_subfunction $f_nodes $compId $comp_thickness $adjacent_elem

		::hwat::utils::ClearMark nodes 1;
		::hwat::utils::ClearMark elements 1;
	}
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# PLASTIC - BIW
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

proc ::screw::getScrewFaceElems_plastic_biw_plane {screw_elemId compId} {

	set elem_nodeIds [hm_getvalue element id=$screw_elemId dataname=nodes];
				
	*createmark components 2 $compId
	*createstringarray 2 "elements_on" "geometry_on"
	*isolateonlyentitybymark 2 1 2
	
	set x [hm_getvalue nodes id=[lindex $elem_nodeIds 0] dataname=x];
	set y [hm_getvalue nodes id=[lindex $elem_nodeIds 1] dataname=y];
	set z [hm_getvalue nodes id=[lindex $elem_nodeIds 2] dataname=z];
	set vector [hm_getelementnormal $screw_elemId edge 1 ];
	*createmark elem 1 "on plane" $x $y $z [lindex $vector 0] [lindex $vector 1] [lindex $vector 2] 0.5 1 0
	set screw_plane_elem_ids [hm_getmark elem 1];
	
	*createmark elem 1 $screw_elemId
	*appendmark elem 1 "by face"
	set screw_face_elem_ids [hm_getmark elem 1];
	
	eval *createmark elem 1 $screw_face_elem_ids;
	eval *createmark elem 2 $screw_plane_elem_ids;
	*markintersection elems 1 elems 2
	set screw_filtered_face_elm [hm_getmark elem 1];
		
	return $screw_filtered_face_elm
}

proc ::screw::getScrewFaceElems_plastic_biw_edgeNodes {compId elem_nodeId} {

	*createmark components 2 $compId
	*createstringarray 2 "elements_on" "geometry_on"
	*isolateonlyentitybymark 2 1 2
	*createmark elems 2 "by comp" $compId;
	set lst_closed_nodeloop [hm_getedgeloops2 element  markid=2 looptype=3];
	
	set screw_edge_nodes [::screw::getNodesOnCircle $lst_closed_nodeloop $elem_nodeId];
	
	eval *createmark nodes 1 $screw_edge_nodes;
	*findmark nodes 1 257 1 elements 0 2
	set screw_filtered_face_elm [lsort -unique [hm_getmark elems 2]];
	
	return $screw_edge_nodes;
	
}


proc ::screw::createScrewRepresentation_plastic_biw { screw_face_nodes } {

	set comp_name [::antolin::connection::utils::getCompNameFromNodeId [lindex $screw_face_nodes 0]];
	
	set weldCollectorName [::antolin::connection::utils::createWeldCollector "SCREW_PLASTIC" "BIW" "Screw_rigids" "_XXSCR" 0];
	
	#create rigids in correct collector
	*currentcollector components "Screw_rigids"

	
	#create rigid on selected surface
	if {$::screw::profile == "lsdyna"} {
		::antolin::connection::utils::createRbody_lsdyna $screw_face_nodes;
	}
}

proc ::screw::exec_screw_plastic_biw { } {

	*createmarkpanel elements 1 "Select elements(s) on screwing face";
	set screw_elemIds [hm_getmark elements 1];
	if {$screw_elemIds == "" } {
		tk_messageBox -message "Please select elements(s) on screwing face" -icon error;
		return
	}
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
	
	#save view
	*saveviewmask "temp_view" 0
	
	foreach screw_elemId $screw_elemIds {
	
		set compId [hm_getvalue elem id=$screw_elemId dataname=component];
		#puts "compId -- $compId"
		
		set screw_filtered_face_elm [::screw::getScrewFaceElems_plastic_biw_plane $screw_elemId $compId];
		
		set elem_nodes [hm_getvalue element id=$screw_elemId dataname=nodes];
		set screw_edge_nodes [::screw::getScrewFaceElems_plastic_biw_edgeNodes $compId [lindex $elem_nodes 0]];
		
		
		#puts "screw_filtered_face_elm -- $screw_filtered_face_elm"
		#puts "screw_edge_nodes -- $screw_edge_nodes"
		
		if {[llength $screw_filtered_face_elm] == 0} {
			puts "face elements not identified for selected element  \"component id = $compId\" \"element id = $screw_elemId\""
			continue
		}
		eval *createmark element 1 $screw_filtered_face_elm;
		*findmark elements 1 1 1 nodes 0 2;
		set screw_face_nodes  [lsort -unique [hm_getmark node 2]];
		#puts "screw_face_nodes -- $screw_face_nodes"
		
		::screw::createScrewRepresentation_plastic_biw $screw_face_nodes
		
	}
	
	#retrive view
	*restoreviewmask "temp_view" 0;
	*removeview "temp_view";
	
}


proc ::screw::exec_screws_main {} {
	
	set ::screw::profile [hm_info templatetype];
	
	if {$::connector::slave_joint_flag == 1 && $::connector::profile != "pamcrash2g" } {
		tk_messageBox -message "\"Joint On Slave\" supported only for \"PAMCRASH\" profile" -icon error;
		return
	}
	
	::hwat::utils::BlockMessages "On"
	
	set ::connector::connection_log_var  [list]
		
	if {$::connector::screw_radiobtn_material == 1} {
		puts "plastic-plastic"
		if {$::connector::screw_radiobtn_methods == 5} {
			::screw::exec_screw_plastic_plastic_collar;
		} else {
			::screw::exec_screw_plastic_plastic;
		}
		
	
	} else {
		puts "plastic-biw"
		::screw::exec_screw_plastic_biw;
	
	}
	
	::hwat::utils::BlockMessages "Off"
	
	::connector::log_files_write;
}

