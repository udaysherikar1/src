if {[namespace exists ::retainer]} {
	namespace delete ::retainer
}
namespace eval ::retainer {

	set ::retainer::scriptDir [file dirname [info script]];
	if {[file exists [file join $::retainer::scriptDir retainer_option_1.tbc]]} {
		source [file join $::retainer::scriptDir retainer_option_1.tbc];
	} else {
		source [file join $::retainer::scriptDir retainer_option_1.tcl];
	}
	if {[file exists [file join $::retainer::scriptDir retainer_option_2.tbc]]} {
		source [file join $::retainer::scriptDir retainer_option_2.tbc];
	} else {
		source [file join $::retainer::scriptDir retainer_option_2.tcl];
	}
	if {[file exists [file join $::retainer::scriptDir retainer_skoda.tbc]]} {
		source [file join $::retainer::scriptDir retainer_skoda.tbc];
	} else {
		source [file join $::retainer::scriptDir retainer_skoda.tcl];
	}
}


proc ::retainer::rad_MethodBtn_callback {arg sub_frm1} {

	if { $arg == "option_1"} {
		$::connector::slaveJoint_frm config -state normal;
	}
	if { $arg == "option_2"} {
		$::connector::slaveJoint_frm config -state normal;
	}
	if { $arg == "Skoda"} {
		#joint on slave 
		$::connector::slaveJoint_frm config -state disabled;
	}
	
	::connection::help::displayDogHouseImage $sub_frm1
}

proc ::retainer::createSystem {edge_node1 edge_node2 baseNodeId x_axisNodeId} {
		
	*createnodesbetweennodes $edge_node1 $edge_node2 1;
	set y_axis_nodeId [::hwat::utils::GetEntityMaxId node];
	
	#*createmark nodes 1 $baseNodeId
	#*systemcreate 1 0 $baseNodeId "y-axis" $y_axis_nodeId "xy plane" $x_axisNodeId
	
	*systemcreate3nodes 0 $baseNodeId "x-axis" $x_axisNodeId "xy-plane" $y_axis_nodeId;
	set sys_id [::hwat::utils::GetEntityMaxId system];
	
	*createmark systems 1 $sys_id;
	*attributeupdateintmark systems 1 4015 2 2 0 1;
	*attributeupdateintmark systems 1 2 2 2 0 0;
	*attributeupdatestringmark systems 1 3066 2 2 0 retainer_sys_$sys_id;
	*attributeupdateintmark systems 1 956 2 2 0 0;
	*attributeupdateintmark systems 1 6928 2 2 0 0;
	*attributeupdateintmark systems 1 4231 2 2 0 1;
	*attributeupdateintmark systems 1 6927 2 2 0 1;
	*attributeupdateintmark systems 1 4013 2 0 0 1;
	*attributeupdatedoublemark systems 1 4014 2 0 0 0;
	
	*nodecleartempmark;
	
	return $sys_id;
}

proc ::retainer::calculateVector { nodeId retainer_cricle_nodes retainer_edge_nodes} {
	
	#this function calculate the translation vector for doghouse.	
	#calculate cog for neibhour elements .. it will be at bottom
	eval *createmark node 1 $retainer_edge_nodes;
	*findmark nodes 1 257 1 elements 0 2;
	set neibhour_elems [hm_getmark elements 2];
	set i 1;
	while {$i <= 3} {
		#get additional element layers of retainer to push the COG down
		eval *createmark elements 1 $neibhour_elems;
		set retainer_nodes [lsort -unique [join [hm_getvalue element markid=2 dataname=nodes]]];
		
		eval *createmark node 1 $retainer_nodes;
		*findmark nodes 1 257 1 elements 0 2;
		set neibhour_elems [hm_getmark elements 2];
		
		incr i;
	}
	set neibhour_elems_cog_nodeId [::doghouse::createCOG "element" $neibhour_elems];
		
	#calculat cog for circle nodes ... it will be at top
	*createcenternode [lindex $retainer_cricle_nodes 0] [lindex $retainer_cricle_nodes 1] [lindex $retainer_cricle_nodes 2];
	set cicle_center_nodeId [::hwat::utils::GetEntityMaxId node];		
			
	#calculate element normal to aline above nodes
	eval *createmark node 1 $nodeId;
	*findmark nodes 1 257 1 elements 0 2;
	set attachedElems [hm_getmark elements 2];
	set elemNormals [::antolin::connection::utils::getAvgElementNormals $attachedElems];
		
	#project the bottom center node along elemNormals
	*createmark nodes 1 $neibhour_elems_cog_nodeId;
	*createplane 1 [lindex $elemNormals 0] [lindex $elemNormals 1] [lindex $elemNormals 2] \
			[hm_getvalue node id=$cicle_center_nodeId dataname=x] [hm_getvalue node id=$cicle_center_nodeId dataname=y] [hm_getvalue node id=$cicle_center_nodeId dataname=z];
			
	*createvector 1 [lindex $elemNormals 0] [lindex $elemNormals 1] [lindex $elemNormals 2];
	*projectmarktoplane nodes 1 1 1 0
	
	#vector bottom cog to top cog
	set vector [::antolin::connection::utils::calculateUnitVector $neibhour_elems_cog_nodeId $cicle_center_nodeId];
			
	*nodecleartempmark 

	return $vector
}

proc ::retainer::createCircularSurface {vector nodeList compName radius} {
	
	if {![hm_entityinfo exist components $compName]} {
		*createentity comps name=$compName;
	}
	*currentcollector components $compName
	*createcenternode [lindex $nodeList 0] [lindex $nodeList 1] [lindex $nodeList 2];
	set cicle_center_nodeId [::hwat::utils::GetEntityMaxId node];	
	
	*createlist nodes 1 $cicle_center_nodeId
	#*createvector 1 0 1 0
	*createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
	*createcirclefromcenterradius 1 1 $radius 360 0;
	set circle_lineId [::hwat::utils::GetEntityMaxId line];
	*nodecleartempmark;
	
	*surfacemode 4
	*createmark lines 1 $circle_lineId
	*surfacesplineonlinesloop 1 1 1 67;
	set circle_surfId [::hwat::utils::GetEntityMaxId surface];
	
	*createmark line 1 $circle_lineId;
	*deletemark line 1;
}

proc ::retainer::translate_Comp {RP_comp_id normal_vector translation_val} {
	
	eval *createmark surface 1 "by comp" $RP_comp_id;
	*createvector 1 [lindex $normal_vector 0] [lindex $normal_vector 1] [lindex $normal_vector 2];	
	*translatemark surface 1 1 $translation_val;	
}

proc ::retainer::meshSurface {tempSurfCompId mesh_size} {
	
	*cleanuptoleranceset 0.01;
	*toleranceset 0.1;
	*setedgedensitylinkwithaspectratio -1
	*elementorder 1
	eval *createmark surfaces 1 "by comp" $tempSurfCompId
	*interactiveremeshsurf 1 $mesh_size 2 2 2 1 1
	*set_meshfaceparams 0 2 2 0 0 1 0.5 1 1
	*automesh 0 2 2
	*storemeshtodatabase 1
	*ameshclearsurface;	
}

proc ::retainer::scale_elements {comp_name} {
	
	#get base node
	*createmark node 1 "by comp" $comp_name;
	*createbestcirclecenternode nodes 1 0 1 0;
	set base_nodeId [::hwat::utils::GetEntityMaxId node];
	
	set scalePer 1.8
	*createmark components 1 $comp_name;
	*scalemark components 1 $scalePer $scalePer $scalePer $base_nodeId
	
}

proc ::retainer::moveElems {ori_comp desti_comp} {
	*createmark elements 1 "by comp" $ori_comp;
	set RP_elems [hm_getmark elements 1];
	*movemark elements 1 $desti_comp;
	
	return $RP_elems
}

proc ::retainer::getCompIds {} {
	*createmark comps 1 all;
	set compIds [hm_getmark comp 1];
	
	return $compIds
}

proc ::retainer::Assign_prop_mat_to_beam {weldCollectorName} {

	set prop_Id [::welds::assignProperty $weldCollectorName "retainer"];
	set mat_Id [::welds::assignMaterial $weldCollectorName];

	#assign prop and mat to comp
	*createmark comps 1 $weldCollectorName;
	set comp_Id [hm_getmark comp 1];
	*setvalue comps id=$comp_Id propertyid={props $prop_Id}
	*setvalue props id=$prop_Id STATUS=2 materialid={mats $mat_Id}
	
	return $prop_Id
}

proc ::retainer::create_RP_Prop {thickness RP_comp_name} {
	#create property assign thickness = 1
	if {![hm_entityinfo exist props $RP_comp_name] } {
		*createentity props cardimage=SectShll name=$RP_comp_name
	}
	set prop_id [hm_getvalue prop name=$RP_comp_name dataname=id];
	
	if {$::retainer::profile == "lsdyna"} {
		*setvalue props id=$prop_id STATUS=1 431=$thickness
		*setvalue props id=$prop_id STATUS=2 90=1
		*setvalue props id=$prop_id STATUS=1 399=16
		*setvalue props id=$prop_id STATUS=1 402=0.833
		*setvalue props id=$prop_id STATUS=1 427=5
	}	
	
	if {$::retainer::profile == "abaqus"} {
		*setvalue props id=$prop_id cardimage="SHELLSECTION"
		*setvalue props id=$prop_id STATUS=1 111=$thickness
	}
	
	if {$::retainer::profile == "pamcrash2g"} {
		#not required as thickness is directly assigned to component
	}
	
	
	return $prop_id

}

proc ::retainer::exclude_RP_layers {RP_elems} {

	eval *createmark elements 1 $RP_elems;
	*findedges1 elements 1 0 0 0 30;
	
	*createmark node 1 "by comp name" "^edges"
	set edge_nodes [hm_getmark node 1];
	
	*createmark components 1 "^edges"
	catch {*deletemark components 1}
	
	eval *createmark nodes 1 $edge_nodes;
	*findmark nodes 1 257 1 elements 0 2 0;
	#set edge_elements [hm_getmark element 2];
	set edge_element_nodes [hm_getvalue elements markid=2 dataname=nodes]
	set edge_element_nodes [lsort -unique [join $edge_element_nodes]]
	
	eval *createmark elements 1 $RP_elems;
	set all_RP_nodes [lsort -unique [join [hm_getvalue elements markid=1 dataname=nodes]]];
			
	#get list intersection 
	eval *createmark node 1 $all_RP_nodes;
	eval *createmark node 2 $edge_element_nodes;
	
	*markdifference node 1 node 2;
	set filter_RP_nodes [hm_getmark node 1];
	
	return $filter_RP_nodes;
}


proc ::retainer::exec_retainers_main {} {
		
	set ::retainer::profile [hm_info templatetype];

	if {$::connector::slave_joint_flag == 1 && $::connector::profile != "pamcrash2g" } {
		tk_messageBox -message "\"Joint On Slave\" supported only for \"PAMCRASH\" profile" -icon error;
		return
	}
	
	*nodecleartempmark;
	*createmarkpanel nodes 1 "Select node(s) for retainer creation";
	set retainer_nodeIds [hm_getmark nodes 1];
	if {$retainer_nodeIds == "" } {
		tk_messageBox -message "Please select node(s)" -icon error;
		return
	}
	
	set ::connector::connection_log_var  [list]
	set ::connector::recentlyCreatedEntity [list];
	set ::connector::recentlyCreatedLCS [list];
		
	::hwat::utils::BlockMessages "On"
	
	set initial_compIds [::retainer::getCompIds];
	if {$::retainer::retainer_radiobtn_methods==1} {
		#option -1
		set ::connector::connection_log_var [list [list "Option-1 Retainer(s)" "=" [llength $retainer_nodeIds] "connector(s)"]];
		::retainer::option1::exec_retainers $retainer_nodeIds;
	} elseif {$::retainer::retainer_radiobtn_methods==2} {
		#option -2
		set ::connector::connection_log_var [list [list "Option-2 Retainer(s)" "=" [llength $retainer_nodeIds] "connector(s)"]];
		::retainer::option2::exec_retainers $retainer_nodeIds;
	} else {
		#skoda
		set ::connector::connection_log_var [list [list "Skoda Retainer(s)" "=" [llength $retainer_nodeIds] "connector(s)"]];	
		::retainer::skoda::exec_retainers $retainer_nodeIds;
	}
	
	set final_compIds [::retainer::getCompIds];
	
	set new_compIds [lremove $final_compIds $initial_compIds];
	
	#show full comp 
	eval *createmark comp 2 $new_compIds;
	*createstringarray 2 "elements_on" "geometry_on"
	*showentitybymark 2 1 2;
		
	::hwat::utils::BlockMessages "Off"
	::connector::log_files_write;

}