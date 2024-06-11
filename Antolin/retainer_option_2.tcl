if {[namespace exists ::retainer::option2]} {
	namespace delete ::retainer::option2
}
namespace eval ::retainer::option2 {
	set ::retainer::option2::scriptDir [file dirname [info script]];

}


proc ::retainer::option2::getCompThickess {nodeId} {

	*createmark elem 1 "by node" $nodeId;
	set adjacent_adjacent_elem [hm_getmark elem 1];
	set adjacent_compIds [hm_getvalue elem markid=1 dataname=component];
		
	if {$::retainer::profile == "pamcrash2g"} {
		#check the component thickness for pamcrash
		set thickness 0.0
		foreach compId $adjacent_compIds {
			set comp_thickness 0;
			catch {set comp_thickness [hm_getvalue comp id=$compId dataname=thickness]};
			if {$comp_thickness > $thickness} {
				set thickness $comp_thickness;
			}
		}
		
		#if component thickness is 0, check element thickness for pamcrash
		if {$thickness >= 99} {
			set elem_thickness 0.0;
			set thickness 0.0;
			foreach elemId $adjacent_adjacent_elem {
				catch {set elem_thickness [hm_getvalue elem id=$elemId dataname=thickness]};
				if {$elem_thickness >= $thickness} {
					set thickness $elem_thickness;
				}
			}				
		}
		if {$thickness >= 99} {
			set thickness 0.0
		}
		
	} else {
		set thickness 0.0
		foreach compId $adjacent_compIds {
			set comp_thickness 0;
			catch {set comp_thickness [hm_getvalue comp id=$compId dataname=thickness]};
			if {$comp_thickness > $thickness} {
				set thickness $comp_thickness;
			}
		
		}
	
	}
	
	#return the maximum thickness of component / elements 
	return $thickness
}

proc ::retainer::option2::exec_retainers {retainer_nodeIds} {
	
	*nodecleartempmark ;
	
	set retainer_RP_comp "Retainer_Rigid_Patch";
	if {![hm_entityinfo exist comps $retainer_RP_comp] } {
		*createentity comps cardimage=Part name=$retainer_RP_comp;
	}
	set RP_comp_id [hm_getvalue comp name=$retainer_RP_comp dataname=id];
	
	set retainer_RP_comp_combined "Retainer_Rigid_Patch_combined";
	if {![hm_entityinfo exist comps $retainer_RP_comp_combined] } {
		*createentity comps cardimage=Part name=$retainer_RP_comp_combined;
	}
	set RP_combined_comp_id [hm_getvalue comp name=$retainer_RP_comp_combined dataname=id];
	set weldCollectorName [::antolin::connection::utils::createWeldCollector "RETAINER" "OPTION02" "Retainer_rigids" "_XXRET" 1];
			
	set mesh_size 2.5;
	foreach nodeId $retainer_nodeIds {
	
		set ret [::doghouse::GetDoghouseNodes $nodeId];
		set retainer_cricle_nodes [lindex $ret 0];
		set retainer_edge_nodes [lindex $ret 1];
		set edge_node1 [lindex $ret 2];
		set edge_node2 [lindex $ret 3];
		#calculate vector
		set vector [::retainer::calculateVector $nodeId $retainer_cricle_nodes $retainer_edge_nodes];
		set n_thickness [::retainer::option2::getCompThickess $nodeId];
		
		# create and translate surface in downward direction
		set reverse_vector "[expr [lindex $vector 0]*-1] [expr [lindex $vector 1]*-1] [expr [lindex $vector 2]*-1]"
		# if {[lindex $vector 1] < 0} {
			# #if -ve make it +ve
			# set reverse_vector "0 1 0"
		# } else {
			# #if +ve make it -ve
			# set reverse_vector "0 -1 0"
		# }
			
		#create bottom circle
		set temp_comp_bottom "retainer_RP_temp_comp_1"
		set cir_radius1 10;
		set n_trans [expr ($n_thickness+2.5)/2];
		::retainer::createCircularSurface $vector $retainer_cricle_nodes $temp_comp_bottom $cir_radius1;	
		::retainer::translate_Comp $temp_comp_bottom $reverse_vector $n_trans;	
		set temp_comp_bottom_id [hm_getvalue comp name=$temp_comp_bottom dataname=id];
		::retainer::meshSurface $temp_comp_bottom_id $mesh_size;
		set RP_elems_bottom [::retainer::moveElems $temp_comp_bottom $retainer_RP_comp_combined];	
		set ::connector::recentlyCreatedEntity [lsort -unique [join [lappend ::connector::recentlyCreatedEntity $RP_elems_bottom]]];
		
		#create middle circle
		set temp_comp_middle "retainer_RP_temp_comp_2"
		set cir_radius2 7.5;
		set n_trans [expr ($n_thickness+2.5)/2];
		::retainer::createCircularSurface $vector $retainer_cricle_nodes $temp_comp_middle $cir_radius2;	
		::retainer::translate_Comp $temp_comp_middle $vector $n_trans;	
		set temp_comp_middle_id [hm_getvalue comp name=$temp_comp_middle dataname=id];
		::retainer::meshSurface $temp_comp_middle_id $mesh_size;
		set RP_elems_middle [::retainer::moveElems $temp_comp_middle $retainer_RP_comp_combined];
		set ::connector::recentlyCreatedEntity [lsort -unique [join [lappend ::connector::recentlyCreatedEntity $RP_elems_middle]]];
		
		#create top circle
		set temp_comp_top "retainer_RP_temp_comp_3"
		set cir_radius3 5;
		set n_trans 10;
		::retainer::createCircularSurface $vector $retainer_cricle_nodes $temp_comp_top $cir_radius3;	
		::retainer::translate_Comp $temp_comp_top $vector $n_trans;	
		set temp_comp_top_id [hm_getvalue comp name=$temp_comp_top dataname=id];
		::retainer::meshSurface $temp_comp_top_id $mesh_size;
		set RP_elems_top [::retainer::moveElems $temp_comp_top $retainer_RP_comp];
		set ::connector::recentlyCreatedEntity [lsort -unique [join [lappend ::connector::recentlyCreatedEntity $RP_elems_top]]];
		
		#delete temp comp
		eval *createmark components 1 "$temp_comp_bottom $temp_comp_middle $temp_comp_top";
		catch {*deletemark components 1}
		
		if {$::retainer::profile == "abaqus"} {
			set top_RP_nodes [::retainer::exclude_RP_layers $RP_elems_top];
		} else {
			eval *createmark elements 1 $RP_elems_top;
			set top_RP_nodes [lsort -unique [join [hm_getvalue elements markid=1 dataname=nodes]]];
		}
		
		set combined_RP_elems "$RP_elems_bottom $RP_elems_middle"	
		eval *createmark elements 1 $combined_RP_elems;
		set combined_RP_nodes [lsort -unique [join [hm_getvalue elements markid=1 dataname=nodes]]];
								
		*currentcollector components "Retainer_rigids"
		
		if {$::retainer::profile == "lsdyna"} {
			::antolin::connection::utils::createRbody_lsdyna $combined_RP_nodes;
			set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			
			::antolin::connection::utils::createRbody_lsdyna $top_RP_nodes;
			set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		}
		
		if {$::retainer::profile == "pamcrash2g" || $::retainer::profile == "abaqus"} {
			::welds::createRigids $combined_RP_nodes "Retainer_rigids";
			set rigid_centerNodeId_1 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
			
			::welds::createRigids $top_RP_nodes "Retainer_rigids";
			set rigid_centerNodeId_2 [::hwat::utils::GetEntityMaxId node];
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];
		}
		
		#aling boss master node wrt female part master node
		set rigid_centerNodeId_1 [::welds::alineMasterNodes $rigid_centerNodeId_2 $rigid_centerNodeId_1 $vector $::connector::joint_length];
		::welds::CalculateMasterNodeTranlationDistance $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector $::connector::joint_length;
		
		if {$::retainer::profile == "pamcrash2g" && $::connector::slave_joint_flag == 1} {			
			#joint on slave is ON
			set ret [::welds::updateRigids_jointOnSlave $rigid_centerNodeId_1 $combined_RP_nodes $rigid_centerNodeId_2 $top_RP_nodes $vector];
			set rigid_centerNodeId_1 [lindex $ret 0];
			set rigid_centerNodeId_2 [lindex $ret 1];
			
			*nodecleartempmark;
		}
		
		::welds::createWeldConnection $weldCollectorName $rigid_centerNodeId_1 $rigid_centerNodeId_2 $vector;
		*nodecleartempmark 
		::hwat::utils::ClearMark node 1;
		
		set prop_Id [::retainer::Assign_prop_mat_to_beam $weldCollectorName];
		
		#system for abaqus only
		set sys_id [::retainer::createSystem $edge_node1 $edge_node2 $rigid_centerNodeId_1 $rigid_centerNodeId_2];
		lappend ::connector::recentlyCreatedLCS $sys_id;
		if {$::retainer::profile == "abaqus"} {
			#assign system in property
			*setvalue props id=$prop_Id STATUS=2 2517={systs $sys_id}
		}
		
		if {$::retainer::profile == "pamcrash2g"} {
			#assign rhickness to comp 
			set RP_thickness 1.0;
			*setvalue comps id=$RP_comp_id cardimage="PART_2D";
			*setvalue comps id=$RP_comp_id STATUS=2 416=$RP_thickness
			
			set RP_thickness 2.5;
			*setvalue comps id=$RP_combined_comp_id cardimage="PART_2D";
			*setvalue comps id=$RP_combined_comp_id STATUS=2 416=$RP_thickness
			
		} else {
			set RP_thickness 2.5;
			set RP_comp_name "Retainer_Rigid_Patch_2.5mm"
			set RP_prop_id_2_5mm [::retainer::create_RP_Prop $RP_thickness $RP_comp_name];
			
			set RP_thickness 1.0;
			set RP_comp_name "Retainer_Rigid_Patch_1mm"
			set RP_prop_id_1mm [::retainer::create_RP_Prop $RP_thickness $RP_comp_name];
			#assign RP prop to RP comp 
			*setvalue comps id=$RP_comp_id propertyid={props $RP_prop_id_1mm}
			*setvalue comps id=$RP_combined_comp_id propertyid={props $RP_prop_id_2_5mm}
		}
		
	}
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::retainer::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="Retainer_rigids" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}
}