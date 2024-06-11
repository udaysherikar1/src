
if {[namespace exists ::usweld::sandwich]} {
	namespace delete ::usweld::sandwich
}

namespace eval ::usweld::sandwich {

	set ::usweld::sandwich::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::usweld::sandwich::scriptDir Welds.tbc]]} {
		source [file join $::usweld::sandwich::scriptDir Welds.tbc];
	} else {
		source [file join $::usweld::sandwich::scriptDir Welds.tcl];
	}
	if {[file exists [file join $::usweld::sandwich::scriptDir utils.tbc]]} {
		source [file join $::usweld::sandwich::scriptDir utils.tbc];
	} else {
		source [file join $::usweld::sandwich::scriptDir utils.tcl];
	}
}


proc ::usweld::sandwich::create_sandwichweld_representation {adjacent_elem f_nodes f_washerNodes midLayer_nodes_top_layer weldCollectorName comp_thickness avg_elem_size vector} {
		
	*createmark elem 1 "by node" [lindex $midLayer_nodes_top_layer 0];
	set adjacent_elem [hm_getmark elem 1];
	set compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
	
	set bottomComp_edge_nodeLayer [::usweld::getNodesOnBossCircle $midLayer_nodes_top_layer $compId];	
	
	#create rigids in correct collector
	*currentcollector components "Heatstake_Rigids"

	if {$::usweld::profile == "lsdyna"} {
		#seperate rigids for each component
		::antolin::connection::utils::createRbody_lsdyna $f_washerNodes;
		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
		set rigid_nodes [concat $midLayer_nodes_top_layer $bottomComp_edge_nodeLayer]
		::antolin::connection::utils::createRbody_lsdyna $rigid_nodes;
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
	}

	if {$::usweld::profile == "pamcrash2g" || $::usweld::profile == "abaqus"} {
		#seperate rigids for each component
		
		::welds::createRigids $f_washerNodes "Heatstake_Rigids";
		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
		set rigid_nodes [concat $midLayer_nodes_top_layer $bottomComp_edge_nodeLayer]
		::welds::createRigids $rigid_nodes "Heatstake_Rigids";
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
	}
	
	#aling boss master node wrt female part master node .. rigid_centerNodeId_1 and rigid_centerNodeId_2
	set rigid_centerNodeId_2 [::welds::alineMasterNodes $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length];
	::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
	
	#create weld
	::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
	
	set prop_Id [::usweld::Assign_prop_mat_to_beam $weldCollectorName];
	
	#if {$::usweld::profile == "abaqus"} {
	#	*setvalue props id=$prop_Id STATUS=2 2517={systs $coordinate_system_id};
	#}
	
	*nodecleartempmark;
}


proc ::usweld::sandwich::create_sandwichweld_RP_representation { adjacent_elem f_nodes f_washerNodes midLayer_nodes_top_layer weldCollectorName comp_thickness avg_elem_size vector } {

	*createmark elem 1 "by node" [lindex $midLayer_nodes_top_layer 0];
	set adjacent_elem [hm_getmark elem 1];
	set compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
	
	set bottomComp_edge_nodeLayer [::usweld::getNodesOnBossCircle $midLayer_nodes_top_layer $compId];
				
	#create rigids in correct collector
	*currentcollector components "Heatstake_Rigids"	
	set rigid_nodes [concat $midLayer_nodes_top_layer $bottomComp_edge_nodeLayer]
	if {$::usweld::profile == "lsdyna"} {
		#seperate rigids for each component
		::antolin::connection::utils::createRbody_lsdyna $rigid_nodes;
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
	}

	if {$::usweld::profile == "pamcrash2g" || $::usweld::profile == "abaqus"} {
		#seperate rigids for each component
		::welds::createRigids $rigid_nodes "Heatstake_Rigids";
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
	}
	
	#create fake patch element or rigid patch above female component
	set RP_comp "Heatstake_Rigid_Patch"
	set RP_elems [::circularRP::createRP_main $f_nodes $rigid_centerNodeId_2 $RP_comp $comp_thickness $avg_elem_size];
	
	if {$::usweld::profile == "lsdyna"} {
		set RP_periphery_elem_comp_name "Heatstake_Tied_Nullbeam"
		set null_beam_compId [::antolin::connection::utils::create_bars_on_edges $RP_elems $RP_periphery_elem_comp_name $::usweld::profile];
		set null_beam_propId [::antolin::connection::utils::createNullBeamProps $RP_periphery_elem_comp_name $::usweld::profile];
		#assign prop to component 
		*setvalue comps id=$null_beam_compId propertyid={props $null_beam_propId}
		
		*createmark node 1 "by comp" "Heatstake_Tied_Nullbeam";
		set RP_outer_nodes [hm_getmark nodes 1];
	}
		
	if {$::usweld::profile == "pamcrash2g" || $::usweld::profile == "abaqus"} {
		set RP_periphery_elem_comp_name "usweld_Tied_Bar"
		::antolin::connection::utils::create_bars_on_edges $RP_elems $RP_periphery_elem_comp_name $::usweld::profile;
		
		*createmark node 1 "by comp" "usweld_Tied_Bar";
		set RP_outer_nodes [hm_getmark nodes 1];
	}
		
	lappend ::connector::recentlyCreatedEntity $RP_elems
	set ::connector::recentlyCreatedEntity [join $::connector::recentlyCreatedEntity];
	
	*currentcollector components "Heatstake_Rigids"
	#get RP nodes
	eval *createmark elem 1 $RP_elems;
	set RP_nodes [hm_getvalue elem mark=1 dataname=nodes];
	set RP_nodes [lsort -unique [join $RP_nodes]];
	
	#exclude outer nodes of RP for rigid creation 
	set RP_nodes [lremove $RP_nodes $RP_outer_nodes];
	
	if {$::usweld::profile == "lsdyna"} {
		::antolin::connection::utils::createRbody_lsdyna $RP_nodes;
		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
	}
	if {$::usweld::profile == "pamcrash2g" || $::usweld::profile == "abaqus"} {
		::welds::createRigids $RP_nodes "Heatstake_Rigids";
		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
	}

	lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
	
	#aling boss master node wrt female part master node
	set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
	
	::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
	
	# if {$::usweld::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
		# #joint on slave is ON
		# set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_1 $RP_nodes $rigid_centerNodeId_2 $boss_nodes $vector];
		# set rigid_centerNodeId_1 [lindex $ret 0];
		# set rigid_centerNodeId_2 [lindex $ret 1];
		
		# #set avg_dist 0.5
	# }
	
	::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
	
	set prop_Id [::usweld::Assign_prop_mat_to_beam $weldCollectorName];
	#if {$::usweld::profile == "abaqus"} {
	#	*setvalue props id=$prop_Id STATUS=2 2517={systs $coordinate_system_id};
	#}
		
	*nodecleartempmark;

}


proc ::usweld::sandwich::Main {adjacent_elem f_nodes f_washerNodes midLayer_nodes_top_layer weldCollectorName comp_thickness avg_elem_size vector} {

	if {$::connector::usweld_radiobtn_methods == 1} {
		#R-B-R
		::usweld::sandwich::create_sandwichweld_representation $adjacent_elem $f_nodes $f_washerNodes $midLayer_nodes_top_layer $weldCollectorName $comp_thickness $avg_elem_size $vector;
	} else {
		#RP
		::usweld::sandwich::create_sandwichweld_RP_representation $adjacent_elem $f_nodes $f_washerNodes $midLayer_nodes_top_layer $weldCollectorName $comp_thickness $avg_elem_size $vector;
	}
	

}


