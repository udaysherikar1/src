if {[namespace exists ::screw::sandwich]} {
	namespace delete ::screw::sandwich
}

namespace eval ::screw::sandwich {

	set ::screw::sandwich::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::screw::sandwich::scriptDir Welds.tbc]]} {
		source [file join $::screw::sandwich::scriptDir Welds.tbc];
	} else {
		source [file join $::screw::sandwich::scriptDir Welds.tcl];
	}
	if {[file exists [file join $::screw::sandwich::scriptDir utils.tbc]]} {
		source [file join $::screw::sandwich::scriptDir utils.tbc];
	} else {
		source [file join $::screw::sandwich::scriptDir utils.tcl];
	}
}

proc ::screw::sandwich::create_sandwichweld_representation { midLayer_nodes_top_layer f_washerNodes \
															weldCollectorName all_boss_nodes vector} {
															
	#create rigids in correct collector
	*currentcollector components "Screw_rigids"

	if {$::screw::profile == "lsdyna"} {
		#rigid on top layer
		::antolin::connection::utils::createRbody_lsdyna $f_washerNodes;
		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
		#rigid on mid and boss layer
		set rigid_nodes [concat $midLayer_nodes_top_layer $all_boss_nodes];
		::antolin::connection::utils::createRbody_lsdyna $rigid_nodes;
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];	
	}
	if {$::screw::profile == "pamcrash2g" || $::screw::profile == "abaqus"} {
		#rigid on top layer
		::welds::createRigids $f_washerNodes "Screw_rigids";
		set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		
		#rigid on mid and boss layer
		set rigid_nodes [concat $midLayer_nodes_top_layer $all_boss_nodes];
		::welds::createRigids $rigid_nodes "Screw_rigids";
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];	
	
	}
	
	#aling boss master node wrt female part master node
	set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
	
	::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
	::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
	::screw::Assign_prop_mat_to_beam $weldCollectorName;
	
	*nodecleartempmark;
															
}

proc ::screw::sandwich::create_sandwichweld_RP_representation {f_nodes comp_thickness avg_elem_size midLayer_nodes_top_layer f_washerNodes weldCollectorName all_boss_nodes vector} {
	
	*currentcollector components "Screw_rigids"
	
	set rigid_nodes [concat $midLayer_nodes_top_layer $all_boss_nodes]
	if {$::screw::profile == "lsdyna"} {
		#rigid on top layer
		::antolin::connection::utils::createRbody_lsdyna $rigid_nodes;
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
	}
	if {$::screw::profile == "pamcrash2g" || $::screw::profile == "abaqus"} {
		#rigid on top layer
		::welds::createRigids $rigid_nodes "Screw_rigids";
		set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
		lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
	}
	
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
	::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;	
	
	::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
	::screw::Assign_prop_mat_to_beam $weldCollectorName;

}

proc ::screw::sandwich::Main {adjacent_elem midLayer_nodes_top_layer f_nodes f_washerNodes weldCollectorName comp_thickness avg_elem_size vector} {
	
	*createmark elem 1 "by node" [lindex $midLayer_nodes_top_layer 0];
	set adjacent_elem [hm_getmark elem 1];
	set compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];	
	
	set boss_nodes_top_layer [::screw::getNodesOnBossCircle $midLayer_nodes_top_layer $compId];
		
	set cir_center [::screw::getCirleCenter $midLayer_nodes_top_layer];
	set circle_x [lindex $cir_center 0];
	set circle_y [lindex $cir_center 1];
	set circle_z [lindex $cir_center 2];
	
	set ret [::screw::getNodeLayersOnBoss $circle_x $circle_y $circle_z $boss_nodes_top_layer];
	set all_boss_nodes [lindex $ret 0];
	set unit_vector [lindex $ret 1];
	
	if {$::connector::screw_radiobtn_methods == 1} {													
		#R-B-R													
		::screw::sandwich::create_sandwichweld_representation $midLayer_nodes_top_layer $f_washerNodes $weldCollectorName $all_boss_nodes $vector;										
	} else {
		#RP
		::screw::sandwich::create_sandwichweld_RP_representation $f_nodes $comp_thickness $avg_elem_size $midLayer_nodes_top_layer $f_washerNodes $weldCollectorName $all_boss_nodes $vector;		
	}													
}
