if {[namespace exists ::ribweld]} {
	namespace delete ::ribweld
}

namespace eval ::ribweld {
	set ::ribweld::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::ribweld::scriptDir clips_metals.tbc]]} {
		source [file join $::ribweld::scriptDir clips_metals.tbc];
	} else {
		source [file join $::ribweld::scriptDir clips_metals.tcl];
	}
	if {[file exists [file join $::ribweld::scriptDir arrang_nodes_clockwise.tbc]]} {
		source [file join $::ribweld::scriptDir arrang_nodes_clockwise.tbc];
	} else {
		source [file join $::ribweld::scriptDir arrang_nodes_clockwise.tcl];
	}
	if {[file exists [file join $::ribweld::scriptDir RP_Ribweld.tbc]]} {
		source [file join $::ribweld::scriptDir RP_Ribweld.tbc];
	} else {
		source [file join $::ribweld::scriptDir RP_Ribweld.tcl];
	}
}


proc ::ribweld::rad_WasherBtn_callback {arg} {

	if { $arg == "zerolayer"} {
		set ::connector::ribweld_radiobtn_washer 1;
	}
	if { $arg == "onelayer"} {
		set ::connector::ribweld_radiobtn_washer 2;
	}
}

proc ::ribweld::rad_MethodBtn_callback {arg sub_frm1} {

	if { $arg == "r_b_r"} {
		#washer
		$::connector::rib_washer_radioBtn1 config -state normal;
		$::connector::rib_washer_radioBtn2 config -state normal;
		#joint on slave 
		if {$::connector::profile == "pamcrash2g"} {
			$::connector::slaveJoint_frm config -state normal;
		} else {
			$::connector::slaveJoint_frm config -state disabled;
		}
		
		set ::connector::ribweld_radiobtn_methods 1;
		#update help images
		::connection::help::displayWeldRibImage $sub_frm1
	}
	if { $arg == "rigid_patch"} {
		#washer
		$::connector::rib_washer_radioBtn1 config -state disabled;
		$::connector::rib_washer_radioBtn2 config -state disabled;
		#joint on slave 
		if {$::connector::profile == "pamcrash2g"} {
			$::connector::slaveJoint_frm config -state normal;
		} else {
			$::connector::slaveJoint_frm config -state disabled;
		}
		
		set ::connector::ribweld_radiobtn_methods 2;
		#update help images
		::connection::help::displayWeldRibImage $sub_frm1
	}
	if { $arg == "Skoda"} {
		#washer
		$::connector::rib_washer_radioBtn1 config -state disabled;
		$::connector::rib_washer_radioBtn2 config -state disabled;
		#joint on slave 
		$::connector::slaveJoint_frm config -state disabled;
		
		set ::connector::ribweld_radiobtn_methods 3;
		#update help images
		::connection::help::displayWeldRibImage $sub_frm1
	}
	if { $arg == "Audi"} {
		#washer
		$::connector::rib_washer_radioBtn1 config -state normal;
		$::connector::rib_washer_radioBtn2 config -state normal;
		
		#joint on slave 
		$::connector::slaveJoint_frm config -state normal;
		
		set ::connector::ribweld_radiobtn_methods 4;
		#update help images
		::connection::help::displayWeldRibImage $sub_frm1
	}
	
}


proc ::ribweld::Assign_prop_mat_to_beam {weldCollectorName} {

	set prop_Id [::welds::assignProperty $weldCollectorName];
	set mat_Id [::welds::assignMaterial $weldCollectorName];

	#assign prop and mat to comp
	*createmark comps 1 $weldCollectorName;
	set comp_Id [hm_getmark comp 1];
	*setvalue comps id=$comp_Id propertyid={props $prop_Id}
	*setvalue props id=$prop_Id STATUS=2 materialid={mats $mat_Id}
}

proc ::ribweld::getThree_farest_nodes_of_slot {centerNode nodeList} {
	catch {array set arr_dist}
	foreach nodeId $nodeList {
		set dist [lindex [hm_getdistance node $centerNode $nodeId 0] 0];
		set arr_dist($dist) $nodeId;
	}
		
	set lst_dist [lsort -decreasing -real [array names arr_dist]];
	
	set n1 [set arr_dist([lindex $lst_dist 0])];
	set n2 [set arr_dist([lindex $lst_dist 1])];
	set n3 [set arr_dist([lindex $lst_dist 2])];
	
	#manage clockwise and anticlockwise node for correct vector
	#here always take anti-closkwise nodes 
	set dist1 [lindex [hm_getdistance node $n1 $n2 0] 0];
	set dist2 [lindex [hm_getdistance node $n1 $n3 0] 0];

	return [list $n1 $n2 $n3];
}

proc ::ribweld::getClosestNodeOnSlot {nodeId compId comp_of_1d_elems} {

	#get attached comps to selected node comp
	set lst_attaced_comps [::antolin::connection::utils::getAttachedComps $compId $comp_of_1d_elems];
	
	#get node on clip slot
	set x1 [hm_getvalue nodes id=$nodeId dataname=x];
	set y1 [hm_getvalue nodes id=$nodeId dataname=y];
	set z1 [hm_getvalue nodes id=$nodeId dataname=z];
			
	eval *createmark nodes 1 "by comp" $lst_attaced_comps;
	set closestNodeOnSlot [hm_getclosestnode $x1 $y1 $z1 0 1];
	
	return $closestNodeOnSlot

}

proc ::ribweld::push_rib_rigid_materNode_down {adjacent_elem rib_freeEdgeNodes rigid_centerNodeId_1 rigid_centerNodeId_2} {
	
	#set elem_nodes [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=nodes];
	eval *createmark elem 1 $adjacent_elem;
	set elem_nodes [hm_getvalue elem markid=1 dataname=nodes];
	set elem_nodes [lsort -unique [join $elem_nodes]];
	
	eval *createmark nodes 1 $rib_freeEdgeNodes;
	eval *createmark nodes 2 $elem_nodes;
	*markdifference nodes 2 nodes 1;
	set elem_bottom_nodes [hm_getmark nodes 2];
	
	#get node on clip slot
	set x1 [hm_getvalue nodes id=$rigid_centerNodeId_2 dataname=x];
	set y1 [hm_getvalue nodes id=$rigid_centerNodeId_2 dataname=y];
	set z1 [hm_getvalue nodes id=$rigid_centerNodeId_2 dataname=z];
	
	eval *createmark nodes 1 "by comp" $rib_freeEdgeNodes;
	set closestNodeOnRib [hm_getclosestnode $x1 $y1 $z1 0 1];
	
	*createmark nodes 1 $rigid_centerNodeId_2
	#*alignnode3 [lindex $elem_bottom_nodes 0] [lindex $elem_bottom_nodes 1] 1
	*alignnode3 $rigid_centerNodeId_1 $closestNodeOnRib 1
	

}

proc ::ribweld::centroid_calc_nodes { face_nodes_attached } {

	set sum_x_node 0
	set sum_y_node 0
	set sum_z_node 0
	set number_of_face_nodes [ llength $face_nodes_attached ]
	##puts $number_of_face_nodes

	foreach face_node $face_nodes_attached {
		set X_face_Node [hm_getentityvalue NODE $face_node "globalx" 0]
		set Y_face_Node [hm_getentityvalue NODE $face_node "globaly" 0]
		set Z_face_Node [hm_getentityvalue NODE $face_node "globalz" 0]
		
		set sum_x_node [ expr { $X_face_Node + $sum_x_node } ]
		set sum_y_node [ expr { $Y_face_Node + $sum_y_node } ]
		set sum_z_node [ expr { $Z_face_Node + $sum_z_node } ]
	}
	
	set x_centroid [ expr { $sum_x_node / $number_of_face_nodes }]
	set y_centroid [ expr { $sum_y_node / $number_of_face_nodes }]
	set z_centroid [ expr { $sum_z_node / $number_of_face_nodes }]
	
	#*createnode $x_centroid $y_centroid $z_centroid  0 0 0
	
	set return_coord $x_centroid
	append return_coord " "
	append return_coord $y_centroid
	append return_coord " "
	append return_coord $z_centroid

    return $return_coord
}


proc ::ribweld::getCompFreeEdges { compIds } {

	#find free edges and create plotal elements on free edges 
	eval *createmark comp 1 $compIds;
	*findedges1 comp 1 0 0 0 5;
	
	*createmark elements 1 "by comp name" "^edges"
	set freeEdgePlotalElems [hm_getmark elems 1];
	
	return $freeEdgePlotalElems

}

proc ::ribweld::getPlotalAttachedToNode { all_freeEdgePlotalElems nodeId } {

	#loop identify plots on free edge associated with selected node
	set freeEdgePlotalsAttachedToNode [list];
	foreach freeEdgeElems $all_freeEdgePlotalElems {
		set freeEdgeElemNodeIds [hm_getvalue elements id=$freeEdgeElems dataname=nodes];
		if {[lsearch $freeEdgeElemNodeIds $nodeId] != -1} {
			lappend freeEdgePlotalsAttachedToNode $freeEdgeElems;
		}
	}
	
	return $freeEdgePlotalsAttachedToNode;
}

proc ::ribweld::checkAngleBetweenNodes {freeEdgePlotalsAttachedToNode nodeId} {
	#selected node is at T-junction.  ie two ribs meet at this position
	#if angle at selected node and other two node <=90 >> T-junction node
	#if angle at selected node and other two node == 180 >> colliner vector
	
	eval *createmark elem 1 $freeEdgePlotalsAttachedToNode;
	set lst_plotalNodes [lsort -unique [join [hm_getvalue element markid=1 dataname=nodes]]];
	set lst_plotalNodes [lremove $lst_plotalNodes $nodeId]
	set nodal_angle 0;
	set colliner_nodeId_1 "";
	set colliner_nodeId_2 "";
	foreach mainloopNodeId $lst_plotalNodes {
		set v1 [::antolin::connection::utils::calculateUnitVector $nodeId $mainloopNodeId];
		foreach subloopNodeId $lst_plotalNodes {
			if {$mainloopNodeId == $subloopNodeId} {
				continue
			}
			set v2 [::antolin::connection::utils::calculateUnitVector $nodeId $subloopNodeId];
			set vectorAngle [::hwat::math::AngleBetweenVectors $v1 $v2];			
			if {$vectorAngle > $nodal_angle} {
				set nodal_angle $vectorAngle;
				set colliner_nodeId_1 $mainloopNodeId;
				set colliner_nodeId_2 $subloopNodeId;
			}
		
		}
	}	
	return [list $colliner_nodeId_1 $colliner_nodeId_2];
}

proc ::ribweld::getFreeEdgeNodes {compIds nodeId} {
	
	#create and get free edge element on component
	set all_freeEdgePlotalElems [::ribweld::getCompFreeEdges $compIds];
	#free edge  plot element associated with selected node
	set freeEdgePlotalsAttachedToNode [::ribweld::getPlotalAttachedToNode $all_freeEdgePlotalElems $nodeId];
	
	if {[llength $freeEdgePlotalsAttachedToNode] > 2} {
		#selected node is at T-junction.  ie two ribs meet at this position
		set ret [::ribweld::checkAngleBetweenNodes $freeEdgePlotalsAttachedToNode $nodeId];
		set colliner_nodeId_1 [lindex $ret 0];
		set colliner_nodeId_2 [lindex $ret 1];
		set unitVector [::antolin::connection::utils::calculateUnitVector $colliner_nodeId_1 $colliner_nodeId_2]
	} else {
	
		#unit vector along free edge plotels 
		set unitVector [::antolin::connection::utils::calculatePlotalElemVector [lindex $freeEdgePlotalsAttachedToNode 0]];
	}
	set filtered_freeEdgePlotalElems [list];
	lappend filtered_freeEdgePlotalElems $freeEdgePlotalsAttachedToNode;
	set filtered_freeEdgePlotalElems [join $filtered_freeEdgePlotalElems]
	set i 0
	while {$i <= 20 } {
		#attached plotels to plotels
		set attachedPlotals [::antolin::connection::utils::findPlotalsAttachedToPlotal $filtered_freeEdgePlotalElems];
		foreach plotId $attachedPlotals {
			#vector along plotel 
			set vector [::antolin::connection::utils::calculatePlotalElemVector $plotId];
			set vectorAngle [::hwat::math::AngleBetweenVectors $unitVector $vector];
			#vector should be parallel to each other	
			if {$vectorAngle > 90} {
				set vectorAngle [expr 180-$vectorAngle];
			}
			if {$vectorAngle > 40} {
				continue
			}
			lappend filtered_freeEdgePlotalElems $plotId;
		}
		incr i
	}	
	set filtered_freeEdgePlotalElems [lsort -unique [join $filtered_freeEdgePlotalElems]];
				
	eval *createmark elem 1 $filtered_freeEdgePlotalElems;
	set cliptower_freeEdgeNodes [hm_getvalue elem markid=1 dataname=nodes];
	set cliptower_freeEdgeNodes [lsort -unique [join $cliptower_freeEdgeNodes]]

	#delete ^edge component
	*createmark components 1 "^edges"
	catch {*deletemark components 1}
		
	#rearrange the list such that selected node at begining
	set a [lremove $cliptower_freeEdgeNodes $nodeId];
	set cliptower_freeEdgeNodes [concat $nodeId $a]
			
	return $cliptower_freeEdgeNodes;
}

proc ::ribweld::exec_ribweld {} {
	
	*createmarkpanel nodes 1 "Select node(s) for ribweld creation";
	set ribweld_nodeIds [hm_getmark nodes 1];
	if {$ribweld_nodeIds == "" } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return
	}
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
	
	set ::connector::connection_log_var [list [list "Rib welds" "=" [llength $ribweld_nodeIds] "connector(s)"]];
		
	eval *createmark nodes 1 $ribweld_nodeIds;
	*findmark nodes 1 257 1 elements 0 2
	set neibhour_elems [hm_getmark elems 2];
	eval *createmark elems 1 $neibhour_elems;
	hm_getnearbyentities inputentitytype=elems inputentitymark=1 outputentitytypes={elems} outputentitymark=2 radius=25 nearby_search_method=sphere
	set lst_closed_nodeloop [hm_getedgeloops2 element  markid=2 looptype=3];
	
	#store current view 
	set t [clock click];
	*saveviewmask View_$t 0;
	
	foreach nodeId $ribweld_nodeIds {
			
		set elem_1d_list [::antolin::connection::utils::get_1D_elements];
		set comp_of_1d_elems [::antolin::connection::utils::get_1D_elem_components $elem_1d_list];
	
		#get component id
		*createmark elem 1 "by node" $nodeId;
		set adjacent_elem [hm_getmark elem 1];
		#set ribCompId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
		set ribCompIds [hm_getvalue element markid=1 dataname=component];
		set ribCompIds [lsort -unique $ribCompIds];
		
		set ribCompId [lindex $ribCompIds 0];
		#function identify and return free edge nodes of rib weld
		set rib_freeEdgeNodes [::ribweld::getFreeEdgeNodes $ribCompIds $nodeId];
		
		set closestNodeOnSlot [::ribweld::getClosestNodeOnSlot $nodeId $ribCompId $comp_of_1d_elems];
		set slot_edge_nodes [::metal_clips::getSlotEdgeNodes $closestNodeOnSlot];
		#------------------------------------------------------------------------------------------
		#get washer nodes and average element size
		set ret [::antolin::connection::utils::GetWasherNodeIds $slot_edge_nodes];
		set slot_washerElements [lindex $ret 0];
		set slot_washerNodes [lindex $ret 1];
		eval *createmark elem 1 $slot_washerElements;
		set avg_elem_size [hm_getaverageelemsize 1]
			
		#------------------------------------------------------------------------------------------
		#get slot component thickness
		
		*createmark elem 1 "by node" $closestNodeOnSlot;
		set slot_adjacent_elem [hm_getmark elem 1];
		set slotCompId [hm_getvalue elem id=[lindex $slot_adjacent_elem 0] dataname=component];
				
		set comp_thickness 0;
		catch {set comp_thickness [hm_getvalue comp id=$slotCompId dataname=thickness]};
		
		if {$comp_thickness == 0} {
			tk_messageBox -message "Thickness not assigned to component id = $slotCompId" -icon error;
			continue
		}
		if {$::ribweld::profile == "pamcrash2g" && $comp_thickness >= 99.0} {
			set comp_thickness 0;
			#*createmark element 1 "by comp" $slotCompId;
			#set comp_elems [hm_getmark elem 1]
			catch {set comp_thickness [hm_getvalue elem id=[lindex $slot_washerElements 0] dataname=thickness]};
			if {$comp_thickness == 0} {
				tk_messageBox -message "Element thickness or component thickness not assigned to component id = $slotCompId" -icon error;
				continue
			}
		}
			
		#------------------------------------------------------------------------------------------
		#create collrectors
		*createmark elem 1 "by node" $closestNodeOnSlot;
		set f_compId [hm_getvalue elem id=[lindex [hm_getmark elem 1] 0] dataname=component];
		set f_CompName [hm_getvalue comp id=$f_compId dataname=name];
		set f_MatId [hm_getvalue comp id=$f_compId dataname=material];
		set f_MatName [hm_getvalue material id=$f_MatId dataname=name];
		
		set rib_compName [hm_getvalue comp id=$ribCompId dataname=name];
		set rib_MatId [hm_getvalue comp id=$ribCompId dataname=material];
		set rib_MatName [hm_getvalue material id=$rib_MatId dataname=name];
		
		set weldCollectorName [::antolin::connection::utils::createWeldCollector "RIBWELD_$rib_MatName" $f_MatName "Ribweld_rigids" "_XXRW" 0];
		
		#------------------------------------------------------------------------------------------
		#calculate vector 	
		set master_id [ ::ribweld::centroid_calc_nodes $slot_edge_nodes ]			
		*createnode [lindex $master_id 0] [lindex $master_id 1] [lindex $master_id 2] 0 0 0
		set master_id [::hwat::utils::GetEntityMaxId node];
		set three_planer_nodes [::ribweld::getThree_farest_nodes_of_slot $master_id $slot_edge_nodes];
		set three_planer_nodes [::arrange::nodes::arrangeClockwise $three_planer_nodes];
		set vector [::antolin::connection::utils::calculate_normal_vector_to_three_points [lindex $three_planer_nodes 0] [lindex $three_planer_nodes 1] [lindex $three_planer_nodes 2]];
				
		#create rigids in correct collector
		*currentcollector components "Ribweld_rigids"
		if {$::connector::ribweld_radiobtn_methods == 1 } {
		
			if {$::ribweld::profile == "lsdyna"} {
				#common boss for both options in lsdyna			
				::antolin::connection::utils::createRbody_lsdyna $slot_edge_nodes;
				set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
				
				::antolin::connection::utils::createRbody_lsdyna $rib_freeEdgeNodes;
				set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			}

			if {$::ribweld::profile == "pamcrash2g" || $::ribweld::profile == "abaqus"} {
				#common boss for both options in pamcrash
				::welds::createRigids $slot_edge_nodes "Ribweld_rigids";
				set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
				
				::welds::createRigids $rib_freeEdgeNodes "Ribweld_rigids";
				set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			}
						
			::ribweld::push_rib_rigid_materNode_down $adjacent_elem $rib_freeEdgeNodes $rigid_centerNodeId_1 $rigid_centerNodeId_2
			
			#aling boss master node wrt female part master node
			set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
			set vector [::antolin::connection::utils::calculateUnitVector $rigid_centerNodeId_1 $rigid_centerNodeId_2];
			::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
						
			if {$::ribweld::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
				#joint on slave is ON
				set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_1 $slot_edge_nodes $rigid_centerNodeId_2 $rib_freeEdgeNodes $vector];
				set rigid_centerNodeId_1 [lindex $ret 0];
				set rigid_centerNodeId_2 [lindex $ret 1];
				
				*nodecleartempmark;
			}
			::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
			::ribweld::Assign_prop_mat_to_beam $weldCollectorName;	
			
		} elseif {$::connector::ribweld_radiobtn_methods == 2 } {
			
			#create rigid for ribs
			if {$::ribweld::profile == "lsdyna"} {
				::antolin::connection::utils::createRbody_lsdyna $rib_freeEdgeNodes;
				set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			}
		
			if {$::ribweld::profile == "pamcrash2g" || $::ribweld::profile == "abaqus"} {
				::welds::createRigids $rib_freeEdgeNodes "Ribweld_rigids";
				set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			}
			
			#duplicate rigid master node
			*createmark nodes 1 $rigid_centerNodeId_2;
			*duplicatemark nodes 1 1;
			set rigid_centerNodeId_2_temp [::hwat::utils::GetEntityMaxId node];
			#push down rib  master node down and aling
			::ribweld::push_rib_rigid_materNode_down $adjacent_elem $rib_freeEdgeNodes $rigid_centerNodeId_1 $rigid_centerNodeId_2;
			#vector from top to bottom
			set vector [::antolin::connection::utils::calculateUnitVector $rigid_centerNodeId_2 $rigid_centerNodeId_2_temp];
						
			#create rigid patch
			set RP_comp "Ribweld_Rigid_Patch"
			set trans_dist [expr ($comp_thickness+1)/2.0]
			set ret [::ribweld::patch::create_Slot_Patch $slot_edge_nodes $trans_dist $vector $master_id $avg_elem_size $RP_comp];
			set RP_nodes_for_rigid [lindex $ret 0];
			set RP_elems [lindex $ret 1];
			
			#create rigids for slot
			if {$::ribweld::profile == "lsdyna"} {
				::antolin::connection::utils::createRbody_lsdyna $RP_nodes_for_rigid;
				set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
				
				set RP_periphery_elem_comp_name "Ribweld_Tied_Nullbeam"
				set null_beam_compId [::antolin::connection::utils::create_bars_on_edges $RP_elems $RP_periphery_elem_comp_name $::ribweld::profile];
				set null_beam_propId [::antolin::connection::utils::createNullBeamProps $RP_periphery_elem_comp_name $::ribweld::profile];
				#assign prop to component 
				*setvalue comps id=$null_beam_compId propertyid={props $null_beam_propId}
				
			}
			
			if {$::ribweld::profile == "pamcrash2g" || $::ribweld::profile == "abaqus"} {
				::welds::createRigids $RP_nodes_for_rigid "Ribweld_rigids";
				set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
				lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
								
				set RP_periphery_elem_comp_name "Ribweld_Tied_Bar"
				::antolin::connection::utils::create_bars_on_edges $RP_elems $RP_periphery_elem_comp_name $::ribweld::profile;
			}
			
			#to delete recently created RP elements
			lappend ::connector::recentlyCreatedEntity $RP_elems
			set ::connector::recentlyCreatedEntity [join $::connector::recentlyCreatedEntity];
			
			#aling boss master node wrt female part master node
			set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
			::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
			
			if {$::ribweld::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
				#joint on slave is ON
				set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_2 $rib_freeEdgeNodes $rigid_centerNodeId_1 $RP_nodes_for_rigid $vector];
				set rigid_centerNodeId_1 [lindex $ret 0];
				set rigid_centerNodeId_2 [lindex $ret 1];
				
				*nodecleartempmark;
			}
						
			::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
			::ribweld::Assign_prop_mat_to_beam $weldCollectorName;	
			
			*nodecleartempmark;
		} elseif {$::connector::ribweld_radiobtn_methods == 3 } {
			puts "skoda method"
			#create comp collector for rigids
			set weldCollectorName "Skoda_Rigids_connections";
			if {![hm_entityinfo exist comps $weldCollectorName] } {
				*createentity comps cardimage=Part name=$weldCollectorName;
			}
			set m_node_set_name "SECFO_Ribweld_Rib_Nodes_LOC_1"
			set m_elem_set_name "SECFO_Ribweld_Rib_Elem_LOC_1"
			set f_node_set_name "SECFO_Ribweld_Hole_Nodes_LOC_1"
			set f_elem_set_name "SECFO_Ribweld_Hole_Elem_LOC_1"
			set m_section_name "SECFO_Ribweld_Rib_LOC_1"
			set f_section_name "SECFO_Ribweld_Hole_LOC_1"
			
			::skoda::connection::main $weldCollectorName $rib_freeEdgeNodes "" $slot_edge_nodes $m_node_set_name\
								$m_elem_set_name $f_node_set_name $f_elem_set_name $m_section_name $f_section_name "ribweld";
		
			*nodecleartempmark;
		}
	
	}
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::ribweld::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="Ribweld_rigids" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}
	
	#show stored view
	*restoreviewmask View_$t 0
	*removeview View_$t;
	
	*createmark comp 1 all;
	*createstringarray 2 "elements_on" "geometry_on"
	*showentitybymark 2 1 2
	
}

proc ::ribweld::getCompIds {} {
	*createmark comps 1 all;
	set compIds [hm_getmark comp 1];
	
	return $compIds
}

proc ::ribweld::exec_rib_welds_main {} {
	
	*nodecleartempmark;
	
	set ::ribweld::profile [hm_info templatetype];

	if {$::connector::slave_joint_flag == 1 && $::connector::profile != "pamcrash2g" } {
		tk_messageBox -message "\"Joint On Slave\" supported only for \"PAMCRASH\" profile" -icon error;
		return
	}
	
	::hwat::utils::BlockMessages "On"
	set ::connector::connection_log_var  [list]
		
	set initial_compIds [::ribweld::getCompIds];
	::ribweld::exec_ribweld;
	set final_compIds [::ribweld::getCompIds];
	
	set new_compIds [lremove $final_compIds $initial_compIds];
	
	#show full comp 
	eval *createmark comp 2 $new_compIds;
	*createstringarray 2 "elements_on" "geometry_on"
	*showentitybymark 2 1 2;
	
	#delete temp comp 
	*createmark components 1 "temp_surf"
	catch {*deletemark components 1};
	
	::hwat::utils::BlockMessages "Off"
	::connector::log_files_write;
	


}


