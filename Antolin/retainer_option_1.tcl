if {[namespace exists ::retainer::option1]} {
	namespace delete ::retainer::option1
}
namespace eval ::retainer::option1 {
	set ::retainer::option1::scriptDir [file dirname [info script]];

}

proc ::retainer::option1::exec_retainers {retainer_nodeIds} {
	
	*nodecleartempmark ;
	
	set retainer_RP_comp "Retainer_Rigid_Patch";
	if {![hm_entityinfo exist comps $retainer_RP_comp] } {
		*createentity comps cardimage=Part name=$retainer_RP_comp;
	}
	set RP_comp_id [hm_getvalue comp name=$retainer_RP_comp dataname=id];
	set weldCollectorName [::antolin::connection::utils::createWeldCollector "RETAINER" "OPTION01" "Retainer_rigids" "_XXRET" 1];
	set temp_comp "retainer_RP_temp_comp"
	set cir_radius 5.0;
	set mesh_size 2.5;
	set trans_dist 10;
	foreach nodeId $retainer_nodeIds {
	
		set ret [::doghouse::GetDoghouseNodes $nodeId];
		set retainer_cricle_nodes [lindex $ret 0];
		set retainer_edge_nodes [lindex $ret 1];
		set edge_node1 [lindex $ret 2];
		set edge_node2 [lindex $ret 3];
		#calculate vector
		set vector [::retainer::calculateVector $nodeId $retainer_cricle_nodes $retainer_edge_nodes];
				
		::retainer::createCircularSurface $vector $retainer_cricle_nodes $temp_comp $cir_radius;		
		::retainer::translate_Comp $temp_comp $vector $trans_dist;	
		set temp_comp_id [hm_getvalue comp name=$temp_comp dataname=id];
		::retainer::meshSurface $temp_comp_id $mesh_size;
		::retainer::scale_elements $temp_comp;
		set RP_elems [::retainer::moveElems $temp_comp $retainer_RP_comp];	
		set ::connector::recentlyCreatedEntity [lsort -unique [join [lappend ::connector::recentlyCreatedEntity $RP_elems]]];
		
		if {$::retainer::profile == "abaqus"} {
			set RP_nodes [::retainer::exclude_RP_layers $RP_elems];
		} else {
			# consider all nodes RP
			eval *createmark elements 1 $RP_elems;
			set RP_nodes [lsort -unique [join [hm_getvalue elements markid=1 dataname=nodes]]];
		}
				
		*currentcollector components "Retainer_rigids"
		if {$::retainer::profile == "lsdyna"} {
			::antolin::connection::utils::createRbody_lsdyna $retainer_cricle_nodes;
			set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			
			::antolin::connection::utils::createRbody_lsdyna $RP_nodes;
			set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		}
		
		if {$::retainer::profile == "pamcrash2g" || $::retainer::profile == "abaqus"} {
			::welds::createRigids $retainer_cricle_nodes "Retainer_rigids";
			set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			
			::welds::createRigids $RP_nodes "Retainer_rigids";
			set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		}
		
		#aling boss master node wrt female part master node
		set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
		::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
		
		if {$::retainer::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
			#joint on slave is ON
			set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_1 $retainer_cricle_nodes $rigid_centerNodeId_2 $RP_nodes $vector];
			set rigid_centerNodeId_1 [lindex $ret 0];
			set rigid_centerNodeId_2 [lindex $ret 1];
			
			*nodecleartempmark;
		}
		
		::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
		*nodecleartempmark 
		::hwat::utils::ClearMark node 1;
				
		set prop_Id [::retainer::Assign_prop_mat_to_beam $weldCollectorName];
		
		set sys_id [::retainer::createSystem $edge_node1 $edge_node2 $rigid_centerNodeId_1 $rigid_centerNodeId_2];
		lappend ::connector::recentlyCreatedLCS $sys_id;
		#system for abaqus only		
		if {$::retainer::profile == "abaqus"} {
			#assign system in property
			*setvalue props id=$prop_Id STATUS=2 2517={systs $sys_id}
		}
		
				
		set RP_thickness 1.0;
		set RP_comp_name "Retainer_Rigid_Patch_1mm"
		if {$::retainer::profile == "pamcrash2g"} {
			#assign rhickness to comp 
			*setvalue comps id=$RP_comp_id cardimage="PART_2D";
			*setvalue comps id=$RP_comp_id STATUS=2 416=$RP_thickness
		} else {
			set RP_prop_id [::retainer::create_RP_Prop $RP_thickness $RP_comp_name];
			#assign RP prop to RP comp 
			*setvalue comps id=$RP_comp_id propertyid={props $RP_prop_id}
		}
				
		#delete temp comp
		*createmark components 1 $temp_comp;
		catch {*deletemark components 1}
		
	}
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::retainer::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="Retainer_rigids" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}		
}