
if {[namespace exists ::surfaceWeld]} {
	namespace delete ::surfaceWeld
}

namespace eval ::surfaceWeld {

	set ::surfaceWeld::scriptDir [file dirname [info script]];
		
	if {[file exists [file join $::connector::scriptDir Welds.tbc]]} {
		source [file join $::connector::scriptDir Welds.tbc];
	} else {
		source [file join $::connector::scriptDir Welds.tcl];
	}
	
	if {[file exists [file join $::connector::scriptDir skoda.tbc]]} {
		source [file join $::connector::scriptDir skoda.tbc];
	} else {
		source [file join $::connector::scriptDir skoda.tcl];
	}

}

proc ::surfaceWeld::checkBox_MethodBtn_callback {arg sub_frm1} {
	
	if {$::connector::surfWeld_skoda_methods == 1} {
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state disabled;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state disabled;
		#joint on slave 
		$::connector::slaveJoint_frm config -state disabled;

		set ::connector::surfWeld_audi_methods 0;
		::connection::help::displaySurfaceWeldImage $sub_frm1
		
	} else {
		$::connector::elemType_joint_lng_frm.joint_lgn_label config -state normal;
		$::connector::elemType_joint_lng_frm.joing_lng_entry config -state normal;
		#joint on slave 
		$::connector::slaveJoint_frm config -state normal;
		
		::connection::help::displaySurfaceWeldImage $sub_frm1
	}
	
	if {$::connector::surfWeld_audi_methods == 1} {
		set ::connector::surfWeld_skoda_methods 0;
	}
}

# # #execute find attached command and compare thickness value to neighbour element thickness
# # proc ::surfaceWeld::findSurfaceWeldNodes1 {nodeId adjacent_elem adjacent_thickness vector} {
	
	# # #set vector [hm_getelementnormal [lindex $adjacent_elem 0] edge 1]; 
		
	# # set i 1
	# # while {$i <= 5} {
		# # #get list of 7 layers of elements 
		# # ::hwat::utils::FindAttachedEntityToGivenEntity $adjacent_elem element element 0;
		# # set adjacent_elem [hm_getmark elems 2];
		# # incr i;
	# # }
		
	# # # get thickness of these elements	
	# # eval *createmark elem 1 $adjacent_elem;
	# # set neighbour_thickness [hm_getvalue elem mark=1 dataname=thickness];
	# # set avg_elm_size [hm_getaverageelemsize 1];
	
	# # set lst_surfaceWeldElemIds [list];
	# # set lst_surfaceWeldNodeIds [list];
	
	# # *clearmark nodes 1	
	# # foreach elemId $adjacent_elem thickness $neighbour_thickness {
		# # #compare thickness with selected node neighbour element
		# # if {$thickness == $adjacent_thickness} {
			# # lappend lst_surfaceWeldElemIds $elemId;
		# # }
	# # }
	
	# # set lst_neighbourElems $adjacent_elem;
	
	# # foreach elemId $lst_surfaceWeldElemIds {
		# # *appendmark nodes 1 "by elem" $elemId;
	
	# # }
	
	# # set lst_surfaceWeldNodeIds [hm_getmark nodes 1];
	
	# # *clearmark nodes 1;
	
	# # #addtional check
	# # #find nodes on plane.  It is required as sometimes undesired same thickness elements present nearby.
	# # set x [hm_getvalue node id=$nodeId dataname=x];
	# # set y [hm_getvalue node id=$nodeId dataname=y];
	# # set z [hm_getvalue node id=$nodeId dataname=z];
	
	# # # *createmark nodes 1 "on plane" $x $y $z [lindex $vector 0] [lindex $vector 1] [lindex $vector 2] 3.0 1 0;
	# # *createmark nodes 1 "on plane" $x $y $z [lindex $vector 0] [lindex $vector 1] [lindex $vector 2] $avg_elm_size 1 0;
	# # set plane_nodeIds [hm_getmark nodes 1];
			
	# # eval *createmark node 2 $lst_surfaceWeldNodeIds;
	
	# # *markintersection nodes 1 nodes 2;
	
	# # #updated surface element list
	# # set lst_surfaceWeldNodeIds [hm_getmark nodes 1];
	# # *clearmark nodes 1;
			
	# # return [list $lst_neighbourElems $lst_surfaceWeldNodeIds];
# # }


proc ::surfaceWeld::findSurfaceWeldNodes { nodeId thickness} {
	#execute find attached command and compare thickness value to neighbour element thickness	
	
	#get neighbour elems and its thickness of selected node
	*createmark nodes 1 $nodeId
	*findmark nodes 1 257 1 elements 0 2;
	set adjacent_elem [hm_getmark elements 2];
	set neighbour_thickness [hm_getvalue element mark=2 dataname=thickness];
	
	
	set lst_surfaceWeldNodeIds [list];
	set lst_surfaceWeldElemIds [list];
	# loop find elements attached to nodes, check and compare element thickness
	set i 1;
	while {$i <= 7} {
	
		foreach elemId $adjacent_elem adjacent_thickness $neighbour_thickness {
			#compare thickness with selected node neighbour element
			if {$adjacent_thickness == $thickness} {
				lappend lst_surfaceWeldElemIds $elemId;
				set attached_Elems_NodeIds [hm_getvalue elements id=$elemId dataname=nodes];
				set attached_Elems_NodeIds [lsort -unique [join $attached_Elems_NodeIds]];
				lappend lst_surfaceWeldNodeIds $attached_Elems_NodeIds;
				lappend lst_surfaceWeldElemIds $elemId;
			}
		}
		set lst_surfaceWeldNodeIds [lsort -unique [join $lst_surfaceWeldNodeIds]];
		
		eval *createmark nodes 1 $lst_surfaceWeldNodeIds
		*findmark nodes 1 257 1 elements 0 2;
		set adjacent_elem [hm_getmark elements 2];
		set neighbour_thickness [hm_getvalue element mark=2 dataname=thickness];
	
		incr i;	
	}

	set lst_surfaceWeldNodeIds [lsort -unique [join $lst_surfaceWeldNodeIds]];	
	set lst_surfaceWeldElemIds [lsort -unique [join $lst_surfaceWeldElemIds]];	
		
	return [list $lst_surfaceWeldElemIds $lst_surfaceWeldNodeIds];
}

proc ::surfaceWeld::getBaseComponentNodeIds {lst_surfaceWeldNodeIds lst_neighbourElems} {
	
	set base_comp_nodeIds [list];
	set total_dist 0;
	set avg_dist 0;
	
	*createmark elems 1 all;
	eval *createmark elems 2 $lst_neighbourElems;
	*markdifference elems 1 elems 2;
	set other_elem_ids [hm_getmark elems 1]; 
	
	#get comps associated with nodes 
	eval *createmark nodes 1 $lst_surfaceWeldNodeIds;
	*findmark nodes 1 1 1 components 0 2;
	set lst_comp [hm_getmark comp 2];
	eval *createmark node 1 "by comp" $lst_comp;
	
	foreach surfaceWeld_nodeId $lst_surfaceWeldNodeIds {
		
		set x [hm_getvalue node id=$surfaceWeld_nodeId dataname=x];
		set y [hm_getvalue node id=$surfaceWeld_nodeId dataname=y];
		set z [hm_getvalue node id=$surfaceWeld_nodeId dataname=z];
	
		set nodeId [hm_getclosestnode $x $y $z 1 1]; 
		lappend base_comp_nodeIds $nodeId;
		
		set dist [lindex [hm_getdistance node $surfaceWeld_nodeId $nodeId 0] 0];
		set total_dist [expr $total_dist + $dist];
	
	}
	*clearmark elems 1;
	set avg_dist [expr $total_dist / [llength $lst_surfaceWeldNodeIds]]
	
	return [list $base_comp_nodeIds $avg_dist];
}

proc ::surfaceWeld::exec_surfaceWeld {} {
	
	set ::surfaceWeld::profile [hm_info templatetype];
	
	if {$::connector::slave_joint_flag == 1 && $::surfaceWeld::profile != "pamcrash2g" } {
		tk_messageBox -message "\"Joint On Slave\" supported only for \"PAMCRASH\" profile" -icon error;
		return
	}
		
	
	if {$::surfaceWeld::profile == "lsdyna"}  {
		set message_connectionType "Representation :- [set ::connector::pArr(beamType)] - BEAM - [set ::connector::pArr(beamType)]"
	} elseif {$::surfaceWeld::profile == "abaqus"} {
		set message_connectionType "Representation :-  COUP_KIN - CONN3D2 - COUP_KIN"
	} elseif {$::surfaceWeld::profile == "pamcrash2g"} {
		set message_connectionType "Representation :-  [set ::connector::pArr(beamType)] - SPRING BEAM - [set ::connector::pArr(beamType)]"
	} else {
		tk_messageBox -message "Surface weld not supported for $::surfaceWeld::profile" -icon error;
		return
	}
		
	*createmarkpanel nodes 1 "Select node(s) on surface weld(s)";
	set surfaceWeld_nodeIds [hm_getmark nodes 1];
	if {$surfaceWeld_nodeIds == "" } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return 
	}
	
	::hwat::utils::BlockMessages "On"
	
	set ::connector::connection_log_var  [list]
	set ::connector::connection_log_var [list [list "Surface Weld" "=" [llength $surfaceWeld_nodeIds] "connector(s)"]];
	
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
			
	foreach nodeId $surfaceWeld_nodeIds {
			
		*createmark elem 1 "by node" $nodeId;
		set adjacent_elem [hm_getmark elem 1];
		set adjacent_thickness [lindex [hm_getvalue elem mark=1 dataname=thickness] 0];
		
		#get surface weld comp id and name
		set surfaceWeld_compId [hm_getvalue elem id=[lindex $adjacent_elem 0] dataname=component];
		set surfaceWeld_compName [hm_getvalue comp id=$surfaceWeld_compId dataname=name];
		set surfaceWeld_MatId [hm_getvalue comp id=$surfaceWeld_compId dataname=material];
		set surfaceWeld_MatName [hm_getvalue material id=$surfaceWeld_MatId dataname=name];
				
		#set vector [hm_getelementnormal [lindex $adjacent_elem 0] edge 1]; 
		set vector [::antolin::connection::utils::getAvgElementNormals $adjacent_elem];
				
		#identify surface weld elements
		#set ret [::surfaceWeld::findSurfaceWeldNodes1 $nodeId $adjacent_elem $adjacent_thickness $vector];
		set ret [::surfaceWeld::findSurfaceWeldNodes $nodeId $adjacent_thickness];
		set lst_neighbourElems [lindex $ret 0];
		set lst_surfaceWeldNodeIds [lindex $ret 1];
								
		#identify base component elements 
		set ret1 [::surfaceWeld::getBaseComponentNodeIds $lst_surfaceWeldNodeIds $lst_neighbourElems];
		set base_comp_nodeIds [lindex $ret1 0];
		set avg_dist [lindex $ret1 1];
				
		#get base comp name
		*createmark elem 1 "by node" [lindex $base_comp_nodeIds 0];
		set baseComp_Id [hm_getvalue elem id=[lindex [hm_getmark elem 1] 0] dataname=component];
		set baseComp_Name [hm_getvalue comp id=$baseComp_Id dataname=name];
		set baseComp_MatId [hm_getvalue comp id=$baseComp_Id dataname=material];
		set baseComp_MatName [hm_getvalue material id=$baseComp_MatId dataname=name];
		
		#------------------------------------------------------------------------------------------	
		#------------------------------------------------------------------------------------------	
		# SKODA methodology
		if {$::connector::surfWeld_skoda_methods == 1} {
		
			#create comp collector for rigids
			set weldCollectorName "Skoda_Rigids_connections";
			if {![hm_entityinfo exist comps $weldCollectorName] } {
				*createentity comps cardimage=Part name=$weldCollectorName;
			}
	
			set m_node_set_name "SECFO_Surface_weld_top_Nodes_LOC_1"
			set m_elem_set_name "SECFO_Surface_weld_top_Elem_LOC_1"
			set f_node_set_name "SECFO_Surface_weld_bottom_Nodes_LOC_1"
			set f_elem_set_name "SECFO_Surface_weld_bottom_Elem_LOC_1"
			set m_section_name "SECFO_Surface_weld_top_LOC_1"
			set f_section_name "SECFO_Surface_weld_bottom_LOC_1"
			
			::skoda::connection::main $weldCollectorName $lst_surfaceWeldNodeIds "" $base_comp_nodeIds $m_node_set_name\
									$m_elem_set_name $f_node_set_name $f_elem_set_name $m_section_name $f_section_name "surfaceweld";
									
									
			# continue is important to skip the general connections functions
			continue
		}
		#------------------------------------------------------------------------------------------	
		#------------------------------------------------------------------------------------------	
		
		#create component collector for Weld
		#set weldCollectorName [::antolin::connection::utils::createWeldCollector "SURFACEWELD_$surfaceWeld_compName" $baseComp_Name "SurfaceWeld_Rigids_connections" "_XXSW" 0];
		set weldCollectorName [::antolin::connection::utils::createWeldCollector "SURFACEWELD_$surfaceWeld_MatName" $baseComp_MatName "SurfaceWeld_Rigids_connections" "_XXSW" 0];
		
		#create rigids
		set masterNode1 [::welds::createRigids $lst_surfaceWeldNodeIds "SurfaceWeld_Rigids_connections"];
		set masterNode2 [::welds::createRigids $base_comp_nodeIds "SurfaceWeld_Rigids_connections"];
		
		#aling master node-1 wrt to vector of master-2 element... here vector is to translate master -2		
		set masterNode1 [::welds::alineMasterNodes $masterNode2 $masterNode1 $vector $avg_dist];
				
		#calculate unit vector between two points. vector between master-1 and new master - 2
		set vector [::antolin::connection::utils::calculateUnitVector $masterNode1 $masterNode2];
					
		if {$::connector::slave_joint_flag == 1} {			
			#joint on slave is ON
			set ret [::welds::updateRigids_jointOnSlave $masterNode1 $lst_surfaceWeldNodeIds $masterNode2 $base_comp_nodeIds $vector];
			set masterNode1 [lindex $ret 0];
			set masterNode2 [lindex $ret 1];
			
			#set avg_dist 0.5
		}
			
		#calculate distance and translate master nodes so that beam length is managed as per user inputs
		::welds::CalculateMasterNodeTranlationDistance $masterNode1 $masterNode2 $vector $::connector::joint_length;
				
		#create welds 
		::welds::createWeldConnection $weldCollectorName $masterNode1 $masterNode2 $vector;
	 
		#assign prop and mats to weld
		::welds::assigncardImageToComp $weldCollectorName
		set prop_Id [::welds::assignProperty $weldCollectorName];
		set mat_Id [::welds::assignMaterial $weldCollectorName];
		
		#assign prop and mat to comp
		*createmark comps 1 $weldCollectorName;
		set comp_Id [hm_getmark comp 1];
		*setvalue comps id=$comp_Id propertyid={props $prop_Id}
		*setvalue props id=$prop_Id STATUS=2 materialid={mats $mat_Id}
						
		::welds::createSystem $weldCollectorName $masterNode1 $masterNode2 [lindex $base_comp_nodeIds end];	
	}
	
	if {[set ::connector::pArr(beamType)]== "Beams" && [set ::surfaceWeld::profile] == "lsdyna"} {
		set spiderBeam_propId [::welds::createSpiderBeamProp_dyna];
		set rigidBeam_compId [hm_getvalue comps name="SurfaceWeld_Rigids_connections" dataname=id];
		*setvalue comps id=$rigidBeam_compId propertyid={props $spiderBeam_propId};
	}
	
	::connector::log_files_write;
	
	::hwat::utils::BlockMessages "Off"

}

