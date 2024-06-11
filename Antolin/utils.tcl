catch {namespace delete ::antolin::connection::utils}

namespace eval ::antolin::connection::utils {

}


proc ::antolin::connection::utils::assingLcsTo1D_pamcrash {elemId lcs_Id} {

	*attributeupdateint elements $elemId 7002 18 2 0 1
	*attributeupdateint elements $elemId 3070 18 2 0 2
	*attributeupdateentity elements $elemId 1237 18 2 0 nodes 0
	*attributeupdateentity elements $elemId 1238 18 2 0 nodes 0
	*attributeupdateentity elements $elemId 3069 18 2 0 systems $lcs_Id
}

proc ::antolin::connection::utils::createSet {setName} {
	
	set t [clock click ];
	set setID [expr [hm_entityinfo maxid set] +1 ];
	*createentity sets name="set$t"
	*setvalue sets id=$setID name=$setName
	
	
	return $setID
}

proc ::antolin::connection::utils::AddAllElemsToMasterSet {setId} {
	
	
	foreach config {104 108 103 106 204 205 206 208 210 213 215 220} {
        *appendmark elems 1 "by config" $config;
    }
	
	set lst_elements [hm_getmark elements 1]
	*setvalue sets id=$setId ids={elems $lst_elements}
}



proc ::antolin::connection::utils::GetNodeCompIds {nodeIds} {
	# get comps associated with nodes 
	
	set lst_comps [list]
	foreach n_node $nodeIds {
		*createmark elems 2 "by node id" $n_node
		set elems [lindex [hm_getmark elems 2] 0]

		set compid [hm_getvalue elems id=$elems dataname=component];	
		set lst_comps [concat $lst_comps $compid]
	}
	
	
	set lst_comps [lsort -unique $lst_comps ];
	return $lst_comps
}


proc ::antolin::connection::utils::diff_CompElems_from_fullModel {holeCompIds_associatedWithNode} {
	
	eval *createmark elems 2 "by comp" $holeCompIds_associatedWithNode;
	
	#mark all shells in model
	foreach config {104 108 103 106 } {
		*appendmark elems 1 "by config" $config;
	}
	
	#subtract comp elements from all shells elements 
	*markdifference elems 1 elems 2
	set diff_elems [hm_getmark elems 1]	

	return $diff_elems
}



proc ::antolin::connection::utils::diff_list {list1_big list2_small} {
	
	set diff_comps [list]
	#set all_initialComps "1 2 3 4 5 6"
	#set holeCompIds_associatedWithNode "1 2"
	
	foreach id1 $list1_big {
		if {[lsearch -exact $list2_small $id1] == -1} {
			
			set diff_comps [concat $diff_comps $id1]
		}	
	}
	
	return $diff_comps
}


proc ::antolin::connection::utils::GetInitialCompCount {} {

	*createmark comp 1 all;
	set all_initialComps [hm_getmark comps 1]
		 
	return $all_initialComps
}

proc ::antolin::connection::utils::createRbody_pam {lst_nodes master_id} {
	
	#RBODY elements
	*elementtype 5 1
	eval *createmark nodes 2 $lst_nodes
	*rigidlink $master_id 2 123456;
	
}

proc ::antolin::connection::utils::createRbody_lsdyna {lst_nodes} {
	
	set centerNode [::antolin::connection::utils::createCenterNodeAtNodeBbox $lst_nodes];
		
	if { $::connector::pArr(beamType) == "Beams"} {
		#set rigidElmId [::hwat::utils::GetEntityMaxId element];
		#set centerNode [::hwat::utils::GetEntityMaxId node];
				
		foreach beam_second_node $lst_nodes {
			*createvector 1 0 0 -1
			*barelementcreatewithoffsets $centerNode $beam_second_node 1 0 0 0 0 "" 0 0 0 0 0 0 0 0;
			lappend ::connector::recentlyCreatedEntity [::hwat::utils::GetEntityMaxId element];			
		}
		
		#delete ealier created rigid element 
		#*createmark elements 1 $rigidElmId
		#*deletemark elements 1;
		
	} else {
	
		#RBODY elements
		eval *createmark node 1 $lst_nodes;
		*elementtype 5 2;
		*rigidlinkinodecalandcreate 1 0 1 123456;
	}
	
}

proc ::antolin::connection::utils::createBeams_pam {nodes_list master_id} {

	foreach beam_second_node $nodes_list {	
		*createvector 1 0 0 -1
		*barelementcreatewithoffsets $master_id $beam_second_node 1 0 0 0 0 "" 0 0 0 0 0 0 0 0	
	}
}


proc ::antolin::connection::utils::create_bars_on_edges {RP_elements comp_name profile} {
	
	if {![hm_entityinfo exist components $comp_name]} {
		*createentity comps name=$comp_name;	
	}
	*currentcollector components $comp_name;
	set compId [hm_getvalue components name=$comp_name dataname=id]
	
	eval *createmark elements 1 $RP_elements
	*findedges1 elements 1 0 0 1 30;
	*createmark edges 1 "by comp" "^edges";
	set edge_for_bar_elems [hm_getmark edge 1];
	*movemark elements 1 $comp_name
	
	*createmark components 1 "^edges"
	*deletemark components 1
		
	foreach edge_elem $edge_for_bar_elems {
		lappend ::connector::recentlyCreatedEntity $edge_elem;
		*createmark elements 1 $edge_elem
		#*configedit 1 "bar2"
		if {$profile == "pamcrash2g"} {
			*configedit 1 "rod"
		}
		
		if {$profile == "lsdyna"} {
			*configedit 1 "bar2"
		}
		
		*clearmark all
	}
	
	*createmark components 2 $comp_name
	*createstringarray 2 "elements_on" "geometry_on"
	*showentitybymark 2 1 2;
	
	return $compId
}

proc ::antolin::connection::utils::createNullBeamProps {propName profile} {
	
	if {![hm_entityinfo exist props $propName]} {
		*createentity props cardimage=SectShll name=$propName
	}
	set propId [hm_getvalue props name=$propName dataname=id]
	
	if {$profile == "lsdyna"} {
		*setvalue props id=$propId cardimage="SectBeam"
		*setvalue props id=$propId STATUS=1 402=1
		*setvalue props id=$propId STATUS=1 429=2
		*setvalue props id=$propId STATUS=1 403=1
		*setvalue props id=$propId STATUS=1 723=0.5
		*setvalue props id=$propId STATUS=1 724=0.5
	}
	
	return $propId
}


# Function to calculate the unit vector between two points
proc ::antolin::connection::utils::calculateUnitVector { masterNode1 masterNode2} {


	set x1 [hm_getvalue node id=$masterNode1 dataname=x];
	set y1 [hm_getvalue node id=$masterNode1 dataname=y];
	set z1 [hm_getvalue node id=$masterNode1 dataname=z];
	
	set x2 [hm_getvalue node id=$masterNode2 dataname=x];
	set y2 [hm_getvalue node id=$masterNode2 dataname=y];
	set z2 [hm_getvalue node id=$masterNode2 dataname=z];

    # Calculate the vector between the two points
    set vx [expr {$x2 - $x1}]
    set vy [expr {$y2 - $y1}]
    set vz [expr {$z2 - $z1}]

    # Calculate the magnitude of the vector
    set magnitude [expr {sqrt($vx*$vx + $vy*$vy + $vz*$vz)}]

    # Calculate the unit vector
    set unitVector [list [expr {$vx / $magnitude}] [expr {$vy / $magnitude}] [expr {$vz / $magnitude}]];

    return $unitVector
}

proc ::antolin::connection::utils::getWasherNodes {inner_nodes} {
	
	eval *createmark node 1 $inner_nodes;
	*findmark nodes 1 1 1 element 0 1;
	set washer_elements [hm_getmark elem 1];
	set washer_nodes [lsort -unique [join [hm_getvalue elem mark=1 dataname=nodes]]];
	
	return $washer_nodes;
}


proc ::antolin::connection::utils::getCompNameFromNodeId {nodeId} {
	
	*createmark elem 1 "by node" $nodeId;
	set baseComp_Id [hm_getvalue elem id=[lindex [hm_getmark elem 1] 0] dataname=component];
	set baseComp_Name [hm_getvalue comp id=$baseComp_Id dataname=name];
}

proc ::antolin::connection::utils::createWeldCollector {comp1 comp2 rigid_comp_name postFix flag} {
	
	set ::welds::profile [hm_info templatetype];
	
	if {$flag == 0} {
		set weldCollectorName [lrange [split $comp1 _] 0 1]_To_[lindex [split $comp2 _] 0];
	} else {
		set weldCollectorName [lindex [split $comp1 _] 0]_[lindex [split $comp2 _] 0];
	}
	
	if {$postFix != ""} {
		set weldCollectorName [string map {" " _} ${weldCollectorName}$postFix];
	}
		
	if {![hm_entityinfo exist comps $weldCollectorName -byname] } {
		*createentity comps cardimage=Part name=$weldCollectorName;
	}

	if {![hm_entityinfo exist props $weldCollectorName -byname] } {
		*createentity props cardimage=SectShll name=$weldCollectorName;
	}
	
	if {![hm_entityinfo exist mats $weldCollectorName -byname] } {
		*createentity mats cardimage=MATL1 name=$weldCollectorName;
	}
	
	if {![hm_entityinfo exist systcols $weldCollectorName -byname] } {
		*createentity systcols name=$weldCollectorName
	}

	#create comp collector for rigids
	if {![hm_entityinfo exist comps $rigid_comp_name] } {
		*createentity comps cardimage="" name=$rigid_comp_name;
	}	
	
	return $weldCollectorName
}

proc ::antolin::connection::utils::GetWasherNodeIds {innterNodes} {
	
	eval *createmark nodes 1 $innterNodes
	*findmark nodes 1 257 1 elements 0 2
	set washerElems [hm_getmark elems 2];
	set washerNodes [hm_getvalue elem markid=2 dataname=nodes];
	set washerNodes [lsort -unique [join $washerNodes]];
	
	return [list $washerElems $washerNodes];
}

proc ::antolin::connection::utils::getDistanceFromCordinates {x1 y1 z1 x2 y2 z2} {

	set distance [expr {sqrt(pow($x2 - $x1, 2) + pow($y2 - $y1, 2) + pow($z2 - $z1, 2))}]

	return $distance
}

proc ::antolin::connection::utils::getAvgElementNormals {elemIds} {
	
	set x_avg 0;
	set y_avg 0;
	set z_avg 0;
	
	foreach elm $elemIds {
				
		if {[hm_getvalue elem id=$elm dataname=config] < 100} {
			#neglect 1-d elements
			continue
		}
		set vector [hm_getelementnormal $elm edge 1 ];
		set x_avg [expr $x_avg + [lindex $vector 0]];
		set y_avg [expr $y_avg + [lindex $vector 1]];
		set z_avg [expr $z_avg + [lindex $vector 2]];
				
	}
	set avg_vector "[format %0.4f [expr ($x_avg/[llength $elemIds])]] [format %0.4f [expr ($y_avg/[llength $elemIds])]] [format %0.4f [expr ($z_avg/[llength $elemIds])]]"
	
	return $avg_vector;
}


# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------

proc ::antolin::connection::utils::calculatePlotalElemVector {elemId } {

	#identify unit vector along the a plot elements
	set freeEdgeElemNodeIds [hm_getvalue elements id=$elemId dataname=nodes];	
	set unitVector [::antolin::connection::utils::calculateUnitVector [lindex $freeEdgeElemNodeIds 0] [lindex $freeEdgeElemNodeIds 1]];
	
	return $unitVector;

}

proc ::antolin::connection::utils::findPlotalsAttachedToPlotal {plotal_elemIds} {
	#any one plotal elements and find attached elements
	eval *createmark elements 1 $plotal_elemIds;
	*findmark elements 1 257 1 elements 0 2;
	set attached_elems [hm_getmark elem 2];
	
	set attached_plotal_elems [list]
	foreach elemId $attached_elems {
		set configId [hm_getvalue elem id=$elemId dataname=config];
		if {$configId == 2} {
			#consider only plotel elements
			lappend attached_plotal_elems $elemId;
		}
	}
	
	return $attached_plotal_elems

}

proc ::antolin::connection::utils::get_1D_elements {} {
	
	*createmark elem 1 "by config" 60;
	set elem_config_1d [list 63 70 22 57 2 56 5 55 61 21 3 27];
	foreach configId $elem_config_1d {
		*appendmark elem 1 "by config" $configId;
	}
	set elem_1d_list [hm_getmark element 1];
	
	return $elem_1d_list;

}

proc ::antolin::connection::utils::get_1D_elem_components {elem_list_1d} {
	
	if {[llength $elem_list_1d] == 0} {
		return
	}
	#hide all comps in graphics
	*createmark comp 2 all;
	*createstringarray 2 "elements_on" "geometry_on"
	*hideentitybymark 2 1 2
	
	#display 1d elements in graphics
	eval *createmark elements 1 $elem_list_1d;
	*findmark elements 1 0 1 elements 0 2;
	
	#get visible comp ids
	*createmark comp 1 displayed
	set comp_of_1d_elems [hm_getmark comps 1];
	
	return $comp_of_1d_elems
}

proc ::antolin::connection::utils::getAttachedComps {compId comp_of_1d_elems} {
	
	*createmark components 1 $compId;
	*findmark components 1 1 1 components 0 2;
	set attaced_comps [hm_getmark comps 2];
		
	if {[llength $attaced_comps] == 0} {
		# no component attached
		return $compId
	}	
	
	#remove tool created comp ids 
	eval *createmark comp 1 "MetalClips_Option-1 MetalClips_Option-2 MetalClips_Option-3 Clip_rigids"
	set ignore_comp_id [hm_getmark comp 1];
	set attaced_comps [lremove $attaced_comps $ignore_comp_id]
	#remove existing 1d comps 
	set attaced_comps [lremove $attaced_comps $comp_of_1d_elems]
		
	if {[llength $attaced_comps] == 0} {
		# no component attached
		return $compId
	}	
	
	set lst_attaced_comps [list];	
	set i 1;
	while {$i < 3} {
		eval *createmark components 1 $attaced_comps;
		*findmark components 1 1 1 components 0 2;
		set attaced_comps [hm_getmark comps 2];
		set attaced_comps [lremove $attaced_comps $ignore_comp_id];
		#remove existing 1d comps 
		set attaced_comps [lremove $attaced_comps $comp_of_1d_elems]
		
		lappend lst_attaced_comps $attaced_comps;
		incr i;
	}
	set lst_attaced_comps [lsort -unique [join $lst_attaced_comps]];
	
	return $lst_attaced_comps;
}

proc ::antolin::connection::utils::createCenterNodeAtNodeBbox {nodeList} {

	set bbox [::hwat::utils::GetBBoxFromNodes $nodeList];
	*createnode [lindex $bbox 0] [lindex $bbox 1] [lindex $bbox 2];
	set minNode [::hwat::utils::GetEntityMaxId node];
	*createnode [lindex $bbox 3] [lindex $bbox 4] [lindex $bbox 5];
	set maxNode [::hwat::utils::GetEntityMaxId node];
	*createnodesbetweennodes $minNode $maxNode 1;
	set bboxCenterNode [::hwat::utils::GetEntityMaxId node];
	#puts "bboxCenterNode -- $bboxCenterNode"
	
	return $bboxCenterNode
}



proc ::antolin::connection::utils::calculate_normal_vector_to_three_points {n1 n2 n3} {
	
	set vector_n1_n2 [::antolin::connection::utils::calculateUnitVector $n1 $n2];
	set vector_n1_n3 [::antolin::connection::utils::calculateUnitVector $n1 $n3];

	set normal_vector [::hwat::math::VectorCrossProduct $vector_n1_n2 $vector_n1_n3];
	
	return $normal_vector;
}

proc ::antolin::connection::utils::system_create { normal_vector master_id opening_nodes } {

	*clearmark all
	set node_01 [ lindex $opening_nodes 0]
	set node_02 [ lindex $opening_nodes 1]
	*createnodesbetweennodes $node_01 $node_02  1
	
	set middle_node [hm_latestentityid nodes]
	
	#puts "middle node is $middle_node"
	*clearmark all
	
	set x_comp [ lindex $normal_vector 0]
	set y_comp [ lindex $normal_vector 1]
	set z_comp [ lindex $normal_vector 2]
	
	set x_comp [ expr { $x_comp + 0.00000001 } ]
	set y_comp [ expr { $y_comp + 0.00000001 } ]
	set z_comp [ expr { $z_comp + 0.00000001 } ]

	##puts "x comp is $x_comp y comp is $y_comp z comp is $z_comp"
	
	*createmark nodes 1 $master_id
	*duplicatemark nodes 1 29
	set dupe_node_id [hm_getmark nodes 1]
	
	*createmark nodes 1 $dupe_node_id
	
	*createvector 1 1 0 0
	*translatemark nodes 1 1 $x_comp
	
	*createvector 1 0 1 0
	*translatemark nodes 1 1 $y_comp
	
	*createvector 1 0 0 1
	*translatemark nodes 1 1 $z_comp
	
	*clearmark all
		
	*systemcreate3nodes 0 $master_id "x-axis" $dupe_node_id "xy-plane" $middle_node
	#*systemcreate3nodes 0 $master_id "x-axis" $middle_node "xy-plane" $dupe_node_id
	 set system_id_latest [ hm_latestentityid system ]
	 
	 return $system_id_latest

}

# proc ::antolin::connection::utils::moveElemsToComp {compName postFix} {
	
	# #create component with required post-fix
	# set new_weldCollectorName ${compName}$postFix;
	# if {![hm_entityinfo exist comps $new_weldCollectorName]} {
		# *createentity comps name=$new_weldCollectorName;
	# }
	# #move elements
	# *createmark elem 1 "by comp" $compName;
	# *movemark elements 1 $new_weldCollectorName;
	
	# #delete empty comp
	# *createmark components 1 $compName
	# *deletemark components 1

# }

