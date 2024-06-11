if {[namespace exists ::plastic_clips]} {
	namespace delete ::plastic_clips
}

namespace eval ::plastic_clips {
	set ::plastic_clips::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::plastic_clips::scriptDir clips_metals.tbc]]} {
		source [file join $::plastic_clips::scriptDir clips_metals.tbc];
	} else {
		source [file join $::plastic_clips::scriptDir clips_metals.tcl];
	}
}

proc ::plastic_clips::Assign_prop_mat_to_beam {weldCollectorName} {

	set prop_Id [::welds::assignProperty $weldCollectorName];
	set mat_Id [::welds::assignMaterial $weldCollectorName];

	#assign prop and mat to comp
	*createmark comps 1 $weldCollectorName;
	set comp_Id [hm_getmark comp 1];
	*setvalue comps id=$comp_Id propertyid={props $prop_Id}
	*setvalue props id=$prop_Id STATUS=2 materialid={mats $mat_Id}
}

proc ::plastic_clips::createClipRepresentations { clipTower_edge_nodes filtered_slot_edge_nodes weldCollectorName elem_vector} {
	
	#create rigids in correct collector
	*currentcollector components "Clip_rigids"
	
	if {$::plastic_clips::profile == "lsdyna"} {
		#common boss for both options in lsdyna
		::antolin::connection::utils::createRbody_lsdyna $clipTower_edge_nodes;
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend clipTower_rigid_master_node [::hwat::utils::GetEntityMaxId node];
		
		::antolin::connection::utils::createRbody_lsdyna $filtered_slot_edge_nodes;
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend slot_rigid_masterNode [::hwat::utils::GetEntityMaxId node];
	}
	
	if {$::plastic_clips::profile == "pamcrash2g" || $::plastic_clips::profile == "abaqus"} {
		#common boss for both options in pamcrash
		::welds::createRigids $clipTower_edge_nodes "Clip_rigids";
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend clipTower_rigid_master_node [::hwat::utils::GetEntityMaxId node];
		
		::welds::createRigids $filtered_slot_edge_nodes "Clip_rigids";
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		lappend slot_rigid_masterNode [::hwat::utils::GetEntityMaxId node];
	}
		#puts "slot_rigid_masterNode -- $slot_rigid_masterNode"
			#puts "clipTower_rigid_master_node -- $clipTower_rigid_master_node"
			
	#translate the slot rigid node along element vector
	set vector1 [::antolin::connection::utils::calculateUnitVector $slot_rigid_masterNode $clipTower_rigid_master_node];
	set center_node_dist [expr [lindex [hm_getdistance node $clipTower_rigid_master_node $slot_rigid_masterNode 0] 0] *1.1];
	*createmark nodes 1 $slot_rigid_masterNode
	*createvector 1 [lindex $vector1 0] [lindex $vector1 1] [lindex $vector1 2];
	*translatemark nodes 1 1 $center_node_dist;

	set slot_rigid_masterNode [::welds::alineMasterNodes $clipTower_rigid_master_node $slot_rigid_masterNode $elem_vector $::connector::joint_length];
	
	if {$::plastic_clips::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
		#joint on slave is ON
		set ret [::welds::updateRigids_jointOnSlave $clipTower_rigid_master_node $clipTower_edge_nodes $slot_rigid_masterNode $filtered_slot_edge_nodes $elem_vector];
		set clipTower_rigid_master_node [lindex $ret 0];
		set slot_rigid_masterNode [lindex $ret 1];
		*nodecleartempmark;
	}
	
	::welds::CalculateMasterNodeTranlationDistance $clipTower_rigid_master_node $slot_rigid_masterNode $elem_vector $::connector::joint_length;
		
	::welds::createWeldConnection $weldCollectorName $clipTower_rigid_master_node $slot_rigid_masterNode $elem_vector;
	::plastic_clips::Assign_prop_mat_to_beam $weldCollectorName;
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::plastic_clips::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="Clip_rigids" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}

}


proc ::plastic_clips::exec_plasticClips_main {} {

	puts "plastic clips"
	set ::plastic_clips::profile [hm_info templatetype];
	
	*createmarkpanel nodes 1 "Select node(s) for clip creation";
	set clip_nodeIds [hm_getmark nodes 1];
	if {[llength $clip_nodeIds] == 0 } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return
	}
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
	
	set ::connector::connection_log_var [list [list "Plastic Clips" "=" [llength $clip_nodeIds] "connector(s)"]];
	
	::antolin::connection::utils::createWeldCollector "PLASTICCLIPS" "OPTION01" "Clip_rigids" "_XXPC" 1;
	#::antolin::connection::utils::createWeldCollector "MetalClips" "Option-2" "Clip_rigids" 1;
	#::antolin::connection::utils::createWeldCollector "MetalClips" "Option-3" "Clip_rigids" 1;
	if {$::connector::clip_radiobtn_options == 1} {
		set weldCollectorName "PLASTICCLIPS_OPTION01_XXPC"
	} elseif {$::connector::clip_radiobtn_options == 2} {
		set weldCollectorName "PLASTICCLIPS_OPTION02_XXPC"
	} else {
		set weldCollectorName "PLASTICCLIPS_OPTION03_XXPC"
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
		
		#clip tower center clopt edge nodes 
		set clipTower_edge_nodes [::metal_clips::getSlotEdgeNodes $nodeId];	
		
		#block of code to get slop edge nodes 
		set x1 [hm_getvalue nodes id=$nodeId dataname=x];
		set y1 [hm_getvalue nodes id=$nodeId dataname=y];
		set z1 [hm_getvalue nodes id=$nodeId dataname=z];
		set lst_attaced_comps [::antolin::connection::utils::getAttachedComps $compId $comp_of_1d_elems];
		eval *createmark nodes 1 "by comp" $lst_attaced_comps;
		set closestNodeOnSlot [hm_getclosestnode $x1 $y1 $z1 0 1];
		set slot_edge_nodes [::metal_clips::getSlotEdgeNodes $closestNodeOnSlot];
		set filtered_slot_edge_nodes [::metal_clips::filer_slot_edge_nodes $slot_edge_nodes];
		*nodecleartempmark;
		
		if {$::connector::clip_skoda_methods == 1} {
			#skoda connections
			puts "skoda plastic clip"
			
			#create comp collector for rigids
			set weldCollectorName "Skoda_Rigids_connections";
			if {![hm_entityinfo exist comps $weldCollectorName] } {
				*createentity comps cardimage=Part name=$weldCollectorName;
			}
			set m_node_set_name "SECFO_Plastic_Clip_Tower_Nodes_LOC_1"
			set m_elem_set_name "SECFO_Plastic_Clip_Tower_Elem_LOC_1"
			set f_node_set_name "SECFO_Plastic_Clip_Slot_Nodes_LOC_1"
			set f_elem_set_name "SECFO_Plastic_Clip_Slot_Elem_LOC_1"
			set m_section_name "SECFO_Plastic_Clip_Tower_LOC_1"
			set f_section_name "SECFO_Plastic_Clip_Slot_LOC_1"
			
			::skoda::connection::main $weldCollectorName $clipTower_edge_nodes "" $filtered_slot_edge_nodes $m_node_set_name\
								$m_elem_set_name $f_node_set_name $f_elem_set_name $m_section_name $f_section_name "plastic_clip";
		
		
		
		} else {
			set ret [::antolin::connection::utils::GetWasherNodeIds $filtered_slot_edge_nodes];
			set slot_washerElements [lindex $ret 0];
			set slot_washerNodes [lindex $ret 1];
			set vector [::antolin::connection::utils::getAvgElementNormals $slot_washerElements];
			# if {$::connector::normal_flag == 1} {
				# set vector "[expr [lindex $vector 0]*-1] [expr [lindex $vector 1]*-1] [expr [lindex $vector 2]*-1]"
			# }
						
			::plastic_clips::createClipRepresentations $clipTower_edge_nodes $filtered_slot_edge_nodes $weldCollectorName $vector;
		}
		
	}
	
	#show stored view
	*restoreviewmask View_$t 0
}

