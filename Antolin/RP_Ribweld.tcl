catch {namespace delete ::ribweld::patch}

namespace eval ::ribweld::patch {
	
	set ::ribweld::patch::scriptDir [file dirname [info script]];
	
	if {[file exists [file join $::ribweld::patch::scriptDir utils.tbc]]} {
		source [file join $::ribweld::patch::scriptDir utils.tbc];
	} else {
		source [file join $::ribweld::patch::scriptDir utils.tcl];
	}
}


proc ::ribweld::patch::getSlotHoleElements {lst_innerNodes} {

	set lst_peripheryElems [list];
	
	foreach n_nodeId $lst_innerNodes {
		*createmark elems 1 "by node id" $n_nodeId;
		set lst_elems [hm_getmark elems 1];
		set lst_peripheryElems [concat $lst_peripheryElems $lst_elems]
	}
	
	set lst_peripheryElems [lsort -unique $lst_peripheryElems];
	return $lst_peripheryElems
}

proc ::ribweld::patch::findLinesOnElemEdges {lst_peripheryElems} {
	
	set break_angle 30;
	eval *createmark elems 1 $lst_peripheryElems;
	*findedges1 elements 1 0 1 1 $break_angle;
	
	*createmark line 1 "by comp name" ^edges 
	set edge_lines [hm_getmark lines 1];
	
	return $edge_lines
}

proc ::ribweld::patch::filter_edges {lst_innerNodes edge_lines} {
	
	#function to exclude outer edge lines and return inner lines
		
	set lst_edgeLines [list]
	set maxNodeId [hm_entityinfo maxid node];
	foreach n_edgeLine $edge_lines {
		*createdoublearray 2 0 1
		#add 2 nodes on edges
		*nodecreateatlineparams $n_edgeLine 1 2 0 1 0;
		set new_maxNodeId [hm_entityinfo maxid node];
		#nodes ids of newly added nodes
		set node_1 $new_maxNodeId;
		set node_2 [expr $new_maxNodeId - 1];
			
		foreach edge_node $lst_innerNodes {
			#get distance between inner node and newly added nodes on line
			set dist1 [lindex [ hm_getdistance nodes $node_1 $edge_node 0] 0]
			set dist2 [lindex [ hm_getdistance nodes $node_2 $edge_node 0] 0]
			
			#condition to include on inner lines 
			set tol_dist 0.5;
			if {$dist1 < $tol_dist || $dist1 < $tol_dist} {
				set lst_edgeLines [concat $lst_edgeLines $n_edgeLine];
			}
		}
	}
	
	#*nodecleartempmark;
	
	set lst_edgeLines [lsort -unique $lst_edgeLines];
	return $lst_edgeLines
}

proc ::ribweld::patch::createSurfToFillSlot {lst_edgeLines} {

	set compName "temp_surf";
	*createentity comps cardimage=PART_2D name=$compName;
	set tempSurfCompId [hm_entityinfo maxid comp];
	
	eval *createmark lines 1 $lst_edgeLines;
	*createplane 1 1 0 0 0 0 0;
	*splinesurface lines 1 1 1 1026;
	
	return $tempSurfCompId;
}

proc ::ribweld::patch::translate_Comp {tempSurfCompId translation_val normal_vector} {

	*createmark components 1 $tempSurfCompId;
	*createvector 1 [lindex $normal_vector 0] [lindex $normal_vector 1] [lindex $normal_vector 2];	
	*translatemark components 1 1 $translation_val;
}

proc ::ribweld::patch::meshSurface {tempSurfCompId avg_elem_size} {
	
	set avg_elem_size 2.5;
	*cleanuptoleranceset 0.01;
	*toleranceset 0.1;
	*setedgedensitylinkwithaspectratio -1
	*elementorder 1
	eval *createmark surfaces 1 "by comp" $tempSurfCompId
	*interactiveremeshsurf 1 $avg_elem_size 2 2 2 1 1
	*set_meshfaceparams 0 2 2 0 0 1 0.5 1 1
	*automesh 0 2 2
	*storemeshtodatabase 1
	*ameshclearsurface 
		
}

proc ::ribweld::patch::scale_surface {master_id} {
	
	set scalePer 1.5
	*createmark surfaces 1 1
	*scalemark surfaces 1 $scalePer $scalePer $scalePer $master_id
	#*scalemark surfaces 1 1.2 1.2 1.2 41208

}

proc ::ribweld::patch::filter_RP_nodes_for_Rigid { tempSurfCompId} {
	
	set break_angle 30;
	*createmark components 1 $tempSurfCompId
	*findedges1 components 1 0 0 0 $break_angle
	
	*createmark nodes 1 "by comp" ^edges;
	set RP_edge_nodeIds [hm_getmark node 1];
	
	*createmark nodes 1 "by comp" $tempSurfCompId;
	set RP_all_nodeIds [hm_getmark node 1];
	
	
	set RP_nodes_for_rigid [::antolin::connection::utils::diff_list $RP_all_nodeIds $RP_edge_nodeIds];
	
	return $RP_nodes_for_rigid
	
}

proc ::ribweld::patch::delete_temp_comp {} {
	
	if { [hm_entityinfo exist comp "temp_surf"]} {
		*createmark comp 1 "temp_surf";
		*deletemark comp 1;
	}
}

proc ::ribweld::patch::create_RP_Prop {} {
		
	if {![hm_entityinfo exist props RP_Prop] } {
		*createentity props cardimage=SectShll name="RP_Prop"
	}
	set prop_id [hm_getvalue prop name="RP_Prop" dataname=id]
	
	*setvalue props id=$prop_id STATUS=2 90=1;
	*setvalue props id=$prop_id STATUS=1 402=0.833;
	*setvalue props id=$prop_id STATUS=1 399=16;
	*setvalue props id=$prop_id STATUS=1 427=5;
	*setvalue props id=$prop_id STATUS=1 431=1;
	
	return $prop_id
}

proc ::ribweld::patch::create_Slot_Patch { lst_innerNodes translation_val normal_vector master_id avg_elem_size RP_comp} {
	
	::ribweld::patch::delete_temp_comp
	
	set profile [hm_info templatetype];
	
	if {![hm_entityinfo exist comps $RP_comp] } {
		*createentity comps cardimage=Part name=$RP_comp;
	}
	#*currentcollector components $RP_comp;
	set RP_comp_id [hm_getvalue comp name=$RP_comp dataname=id];
	
	set lst_peripheryElems [::ribweld::patch::getSlotHoleElements $lst_innerNodes];
	set edge_lines [::ribweld::patch::findLinesOnElemEdges $lst_peripheryElems];
	set lst_edgeLines [::ribweld::patch::filter_edges $lst_innerNodes $edge_lines];
	
	set tempSurfCompId [::ribweld::patch::createSurfToFillSlot $lst_edgeLines];
	::ribweld::patch::translate_Comp $tempSurfCompId $translation_val $normal_vector;
	::ribweld::patch::scale_surface $master_id;
	::ribweld::patch::meshSurface $tempSurfCompId $avg_elem_size;
	
	set RP_nodes_for_rigid [::ribweld::patch::filter_RP_nodes_for_Rigid $tempSurfCompId];
	
	#RP elements 
	*createmark elements 1 "by comp" $tempSurfCompId;
	set RP_elems [hm_getmark elements 1];
			
	eval *createmark elements 1 $RP_elems
	*movemark elements 1 $RP_comp;
	
	if {$profile == "pamcrash2g"} {
		#assign rhickness to comp 
		*setvalue comps id=$RP_comp_id cardimage="PART_2D";
		*setvalue comps id=$RP_comp_id STATUS=2 416=1
	} else {
		set RP_prop_id [::circularRP::create_RP_Prop];
		#assign RP prop to RP comp 
		*setvalue comps id=$RP_comp_id propertyid={props $RP_prop_id}
	}
			
		
	#delete temp comp
	*createmark components 1 "^edges"
	*deletemark components 1;
	
	return [list $RP_nodes_for_rigid $RP_elems];
	
}
