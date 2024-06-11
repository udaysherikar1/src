if {[namespace exists ::metal_clips]} {
	namespace delete ::metal_clips
}

namespace eval ::metal_clips {
	set ::metal_clips::scriptDir [file dirname [info script]];

}

proc ::metal_clips::getCompFreeEdges { compId } {

	#find free edges and create plotal elements on free edges 
	*createmark comp 1 $compId;
	*findedges1 comp 1 0 0 0 5;
	
	*createmark elements 1 "by comp name" "^edges"
	set freeEdgePlotalElems [hm_getmark elems 1];
	
	return $freeEdgePlotalElems

}

proc ::metal_clips::getPlotalAttachedToNode { all_freeEdgePlotalElems nodeId } {

	#loop identify plots on free edge associated with selected node
	set freeEdgePlotalsAttachedToNode [list];
	foreach freeEdgeElems $all_freeEdgePlotalElems {
		set freeEdgeElemNodeIds [hm_getvalue elements id=$freeEdgeElems dataname=nodes];
		if {[lsearch $freeEdgeElemNodeIds $nodeId] != -1} {
			lappend freeEdgePlotalsAttachedToNode $freeEdgeElems
		}
	}
	
	return $freeEdgePlotalsAttachedToNode;
}

proc ::metal_clips::getFreeEdgeNodes {compId nodeId} {
	
	#create and get free edge element on component
	set all_freeEdgePlotalElems [::metal_clips::getCompFreeEdges $compId];
	#free edge  plot element associated with selected node
	set freeEdgePlotalsAttachedToNode [::metal_clips::getPlotalAttachedToNode $all_freeEdgePlotalElems $nodeId];
	#unit vector along free edge plotels 
	set unitVector [::antolin::connection::utils::calculatePlotalElemVector [lindex $freeEdgePlotalsAttachedToNode 0]];
	
	set filtered_freeEdgePlotalElems [list];
	lappend filtered_freeEdgePlotalElems $freeEdgePlotalsAttachedToNode;
	set filtered_freeEdgePlotalElems [join $filtered_freeEdgePlotalElems]

	set i 0
	while {$i <= 15 } {
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
	set cliptower_freeEdgeNodes [concat $nodeId $a];
		
	return $cliptower_freeEdgeNodes;
}



proc ::metal_clips::getBottomLayerNodes {toplayerNodes unit_vector count} {

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
		
		if {$count == 1} {
			#fine tune the unit vector 
			set unit_vector [::antolin::connection::utils::calculateUnitVector $nodeId $bottom_nodeId];
		}
	}
	
	eval *createmark node 1 $node_bottom_layers;
	eval *createmark node 2 $toplayerNodes;
	*markdifference node 1 node 2;
	set node_bottom_layers [hm_getmark node 1];
	set node_bottom_layers [lsort -unique [join $node_bottom_layers]];

	return [list $node_bottom_layers $unit_vector];
}

proc ::metal_clips::getClipTowerNodes {nodeId compId cliptower_freeEdgeNodes comp_of_1d_elems} {

	#get attached comps to selected node comp
	set lst_attaced_comps [::antolin::connection::utils::getAttachedComps $compId $comp_of_1d_elems];
	#puts "lst_attaced_comps -- $lst_attaced_comps"

	#get C.O.G. of clip tower face
	*createmark node 1 $nodeId;
	*appendmark node 1 "by face";
	set clip_faceNodes [hm_getmark node 1];
	
	set clipFace_centerNode [::antolin::connection::utils::createCenterNodeAtNodeBbox $clip_faceNodes];
	#get node on clip slot
	set x1 [hm_getvalue nodes id=$clipFace_centerNode dataname=x];
	set y1 [hm_getvalue nodes id=$clipFace_centerNode dataname=y];
	set z1 [hm_getvalue nodes id=$clipFace_centerNode dataname=z];
	*nodecleartempmark;
		
	eval *createmark nodes 1 "by comp" $lst_attaced_comps;
	#eval *appendmark nodes 1 "by comp" $comp_of_1d_elems;
	set closestNodeOnSlot [hm_getclosestnode $x1 $y1 $z1 0 1];
	set vector_clip_head_to_slot [::antolin::connection::utils::calculateUnitVector $nodeId $closestNodeOnSlot];
			
	set cliptower_Nodes $cliptower_freeEdgeNodes;
	set bottom_layer_nodes $cliptower_freeEdgeNodes;
	set i 1;
	while {$i <= $::connector::element_layers} {
		set ret [::metal_clips::getBottomLayerNodes $bottom_layer_nodes $vector_clip_head_to_slot $i];
		set bottom_layer_nodes [lindex $ret 0];
		set vector_clip_head_to_slot [lindex $ret 1];
		lappend cliptower_Nodes $bottom_layer_nodes;
		incr i;
	}
	set cliptower_Nodes [lsort -unique [join $cliptower_Nodes]];
	
	return [list $closestNodeOnSlot $cliptower_Nodes]
}


proc ::metal_clips::getSlotEdgeNodes {nodeId} {

	eval *createmark nodes 1 $nodeId;
	*findmark nodes 1 257 1 elements 0 2
	set neibhour_elems [hm_getmark elems 2];
	
	eval *createmark elems 1 $neibhour_elems;
	hm_getnearbyentities inputentitytype=elems inputentitymark=1 outputentitytypes={elems} outputentitymark=2 radius=25 nearby_search_method=sphere
	set lst_closed_nodeloop [hm_getedgeloops2 element  markid=2 looptype=3];
	
	set slot_edge_nodes "";
	foreach nodeloop $lst_closed_nodeloop {
		if {[lsearch $nodeloop $nodeId] != -1} {
			set slot_edge_nodes $nodeloop;
			break;
		}
	}

	set slot_edge_nodes [lsort -increasing -real [lsort -unique $slot_edge_nodes]];
	set slot_edge_nodes [lrange $slot_edge_nodes 1 end];

	return $slot_edge_nodes;

}

proc ::metal_clips::filer_slot_edge_nodes {slot_edge_nodes} {
		
	eval *createmark nodes 1 $slot_edge_nodes;
	*createbestcirclecenternode nodes 1 0 1 0;
	set slot_centerId [::hwat::utils::GetEntityMaxId node];
	
	set total_dist 0;
	set avg_dist 0;
	#calculate avg distance
	foreach clipNode $slot_edge_nodes {
		#set dist [lindex [hm_getdistance node $clipNode $clipMidNodeOnEdge 0] 0];
		set dist [lindex [hm_getdistance node $clipNode $slot_centerId 0] 0];
		set total_dist [expr $total_dist + $dist];
	}
	set avg_dist [expr $total_dist / [llength $slot_edge_nodes]]
	
	set filtered_slot_edge_nodes [list];
	foreach clipNode $slot_edge_nodes {	
		#set dist [lindex [hm_getdistance node $clipNode $clipMidNodeOnEdge 0] 0];
		set dist [lindex [hm_getdistance node $clipNode $slot_centerId 0] 0];
		if {$dist <= [expr $avg_dist*0.95]} {
			lappend filtered_slot_edge_nodes $clipNode
		}
	}
	*nodecleartempmark 
	
	return $filtered_slot_edge_nodes
}


proc ::metal_clips::Assign_prop_mat_to_beam {weldCollectorName} {

	set prop_Id [::welds::assignProperty $weldCollectorName];
	set mat_Id [::welds::assignMaterial $weldCollectorName];

	#assign prop and mat to comp
	*createmark comps 1 $weldCollectorName;
	set comp_Id [hm_getmark comp 1];
	*setvalue comps id=$comp_Id propertyid={props $prop_Id}
	*setvalue props id=$prop_Id STATUS=2 materialid={mats $mat_Id}
}

proc ::metal_clips::createClipRepresentations { clipMidNodeOnEdge cliptower_Nodes slot_edge_nodes weldCollectorName vector} {

	#create rigids in correct collector
	*currentcollector components "Clip_rigids"
	
	if {$::metal_clips::profile == "lsdyna"} {
		#common boss for both options in lsdyna
		::antolin::connection::utils::createRbody_lsdyna $cliptower_Nodes;
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend clipTower_rigid_master_node [::hwat::utils::GetEntityMaxId node];
		
		::antolin::connection::utils::createRbody_lsdyna $slot_edge_nodes;
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend slot_rigid_masterNode [::hwat::utils::GetEntityMaxId node];
	}
	
	if {$::metal_clips::profile == "pamcrash2g" || $::metal_clips::profile == "abaqus"} {
		#common boss for both options in pamcrash
		::welds::createRigids $cliptower_Nodes "Clip_rigids";
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend clipTower_rigid_master_node [::hwat::utils::GetEntityMaxId node];
		
		::welds::createRigids $slot_edge_nodes "Clip_rigids";
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend slot_rigid_masterNode [::hwat::utils::GetEntityMaxId node];
	}
	
	*replacenodes $slot_rigid_masterNode $clipMidNodeOnEdge 1 0;
	*nodecleartempmark;
		
	set clipMidNodeOnEdge [::welds::alineMasterNodes $clipTower_rigid_master_node $clipMidNodeOnEdge $vector $::connector::joint_length];
	
	if {$::metal_clips::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
		#joint on slave is ON
		set ret [::welds::updateRigids_jointOnSlave $clipMidNodeOnEdge $slot_edge_nodes $clipTower_rigid_master_node $cliptower_Nodes $vector];
		set clipMidNodeOnEdge [lindex $ret 0];
		set clipTower_rigid_master_node [lindex $ret 1];
		*nodecleartempmark;
	}
	
	::welds::CalculateMasterNodeTranlationDistance $clipTower_rigid_master_node $clipMidNodeOnEdge $vector $::connector::joint_length;
	
	::welds::createWeldConnection $weldCollectorName $clipMidNodeOnEdge $clipTower_rigid_master_node $vector;
	::metal_clips::Assign_prop_mat_to_beam $weldCollectorName;
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::metal_clips::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="Clip_rigids" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}
}


proc ::metal_clips::exec_metalClips_main {} {

	puts "metal clips"
	set ::metal_clips::profile [hm_info templatetype];
	
	*createmarkpanel nodes 1 "Select node(s) for clip creation";
	set clip_nodeIds [hm_getmark nodes 1];
	if {[llength $clip_nodeIds] == 0 } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return
	}
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
	
	set ::connector::connection_log_var [list [list "Metal Clips" "=" [llength $clip_nodeIds] "connector(s)"]];
		
	#only collector name change, everything else is same
	if {$::connector::clip_radiobtn_options == 1} {
		::antolin::connection::utils::createWeldCollector "METALCLIPS" "OPTION01" "Clip_rigids" "_XXMC" 1;
		set weldCollectorName "METALCLIPS_OPTION01_XXMC"
	} elseif {$::connector::clip_radiobtn_options == 2} {
		::antolin::connection::utils::createWeldCollector "METALCLIPS" "OPTION02" "Clip_rigids" "_XXMC" 1;
		set weldCollectorName "METALCLIPS_OPTION02_XXMC"
	} else {
		::antolin::connection::utils::createWeldCollector "METALCLIPS" "OPTION03" "Clip_rigids" "_XXMC" 1;
		set weldCollectorName "METALCLIPS_OPTION03_XXMC"
	}
	*nodecleartempmark ;
	
	#store current view 
	set t [clock click];
	*saveviewmask View_$t 0;
	
	#these components need to be ingonred in find attached operations
	set elem_1d_list [::antolin::connection::utils::get_1D_elements];
	set comp_of_1d_elems [::antolin::connection::utils::get_1D_elem_components $elem_1d_list];
	
	foreach nodeId $clip_nodeIds {
		
		if {[hm_entityinfo exist comps "Skoda_Rigids_connections"] } {
			set skoda_rigid_comp_id [hm_getvalue comp name="Skoda_Rigids_connections" dataname=id];
			set comp_of_1d_elems [lsort -unique [lappend $comp_of_1d_elems $skoda_rigid_comp_id]];
		}
		
		#get component id
		*createmark elem 1 "by node" $nodeId;
		set adjacent_elem [hm_getmark elem 1];
		set compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
		
		#function identify and return free edge nodes of clip tower
		set cliptower_freeEdgeNodes [::metal_clips::getFreeEdgeNodes $compId $nodeId];
		#get clip tower nodes
		set ret [::metal_clips::getClipTowerNodes $nodeId $compId $cliptower_freeEdgeNodes $comp_of_1d_elems];
		set closestNodeOnSlot [lindex $ret 0];
		set cliptower_Nodes [lindex $ret 1];
		#get slot edge nodes
		set slot_edge_nodes [::metal_clips::getSlotEdgeNodes $closestNodeOnSlot];
		set filtered_slot_edge_nodes [::metal_clips::filer_slot_edge_nodes $slot_edge_nodes];
		*nodecleartempmark;
		
		if {$::connector::clip_skoda_methods == 1} {
			#skoda connections
			puts "skoda metal clip"
			
			#create comp collector for rigids
			set weldCollectorName "Skoda_Rigids_connections";
			if {![hm_entityinfo exist comps $weldCollectorName] } {
				*createentity comps cardimage=Part name=$weldCollectorName;
			}
			set m_node_set_name "SECFO_Metal_Clip_Tower_Nodes_LOC_1"
			set m_elem_set_name "SECFO_Metal_Clip_Tower_Elem_LOC_1"
			set f_node_set_name "SECFO_Metal_Clip_Slot_Nodes_LOC_1"
			set f_elem_set_name "SECFO_Metal_Clip_Slot_Elem_LOC_1"
			set m_section_name "SECFO_Metal_Clip_Tower_LOC_1"
			set f_section_name "SECFO_Metal_Clip_Slot_LOC_1"
			
			::skoda::connection::main $weldCollectorName $cliptower_Nodes "" $filtered_slot_edge_nodes $m_node_set_name\
								$m_elem_set_name $f_node_set_name $f_elem_set_name $m_section_name $f_section_name "metal_clip";
			
		} else {
			
			set ret [::antolin::connection::utils::GetWasherNodeIds $filtered_slot_edge_nodes];
			set slot_washerElements [lindex $ret 0];
			set slot_washerNodes [lindex $ret 1];
		
			set vector [::antolin::connection::utils::getAvgElementNormals $slot_washerElements];					
			set clipMidNodeOnEdge [::antolin::connection::utils::createCenterNodeAtNodeBbox $cliptower_freeEdgeNodes];
			# transate node with some distance
			*createmark node 1 $clipMidNodeOnEdge;
			*createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
			*translatemark nodes 1 1 0.5;
			
			::metal_clips::createClipRepresentations $clipMidNodeOnEdge $cliptower_Nodes $filtered_slot_edge_nodes $weldCollectorName $vector;
		
		}
			
	}
	
	#show stored view
	*restoreviewmask View_$t 0
}
