if {[namespace exists ::doghouse]} {
	namespace delete ::doghouse
}


namespace eval ::doghouse {


}


proc ::doghouse::getDogHouseFaceElems {n_node} {
	
	*createmark elem 1 "by node" $n_node
	set n_elem [lindex [hm_getmark elem 1] 0];
	
	#update the feature angle to avoid unwanted elements 
	*featureangleset 5;
	
	*createmark elem 1 $n_elem
	*appendmark elem 1 "by face"
	set face_elem [hm_getmark elem 1];	
	
	return $face_elem

}

proc ::doghouse::createCOG {entityType entityList} {

	eval *createmark $entityType 1 $entityList
	set bbox [hm_getboundingbox $entityType 1 0 0 0];
	
	*createnode [lindex $bbox 0] [lindex $bbox 1] [lindex $bbox 2];
	*createmark node 1 -1;
	set node1 [hm_getmark node 1];
	*createnode [lindex $bbox 3] [lindex $bbox 4] [lindex $bbox 5];
	*createmark node 1 -1;
	set node2 [hm_getmark node 1];
	
	*createnodesbetweennodes $node1 $node2 1
	*createmark node 1 -1;
	set cog [hm_getmark node 1]
	
	return $cog
}

proc ::doghouse::getEdgeNodes {elem_list} {

	eval *createmark elems 1 $elem_list;
	*findedges1 elements 1 0 0 0 30;
	
	*createmark node 1 "by comp name" "^edges"
	set edge_nodes [hm_getmark node 1];
	
	*createmark components 1 "^edges"
	catch {*deletemark components 1}
		
	return $edge_nodes
}

proc ::doghouse::getCircleNodes {nodeId cicle_center_nodeId edge_nodes} {

	#calculate distance between selected node and circle node i.e. radius
	set radius [lindex [hm_getdistance nodes $cicle_center_nodeId $nodeId 0] 0];
		
	set lst_cricle_nodes [list];
	set u_tol [expr $radius * 1.5];
	#set l_tol [expr $radius * 0.9];
	foreach edgeNode $edge_nodes {
		set n_dist [lindex [hm_getdistance nodes $cicle_center_nodeId $edgeNode 0] 0];
		
		if { $n_dist <= $u_tol} {	
			set lst_cricle_nodes [lappend lst_cricle_nodes $edgeNode];
		}	
	}
	
	return $lst_cricle_nodes;
}

proc ::doghouse::getClosestNode {temp_cogNodeId doghouse_faceElem ignore_nodeIds} {

	set x1 [hm_getvalue nodes id=$temp_cogNodeId dataname=x];
	set y1 [hm_getvalue nodes id=$temp_cogNodeId dataname=y];
	set z1 [hm_getvalue nodes id=$temp_cogNodeId dataname=z];
	
	eval *createmark elem 1 $doghouse_faceElem;
	eval *createmark node 1 $ignore_nodeIds;
	set closestNodeOnSlot [hm_getclosestnode $x1 $y1 $z1 1 1];
		
	return $closestNodeOnSlot
}


proc ::doghouse::GetDoghouseNodes {nodeId} {
		
	#get dog house face elements 	
	set doghouse_faceElem [::doghouse::getDogHouseFaceElems $nodeId];
	#edge nodes
	set edge_nodes [::doghouse::getEdgeNodes $doghouse_faceElem];
	
	# get cog fron edge nodes
	eval *createmark nodes 1 $edge_nodes;
	*createbestcirclecenternode nodes 1 0 1 0;
	set temp_cogNodeId [::hwat::utils::GetEntityMaxId node];
	#set temp_cogNodeId [::doghouse::createCOG "element" $doghouse_faceElem];
		
	#get two closest nodes from face cog 
	set closeNodeId1 [::doghouse::getClosestNode $temp_cogNodeId $doghouse_faceElem $nodeId];
	set node_exlude "$nodeId $closeNodeId1"
	set closeNodeId2 [::doghouse::getClosestNode $temp_cogNodeId $doghouse_faceElem $node_exlude];
	#cicle centre
	*createcenternode $nodeId $closeNodeId1 $closeNodeId2
	set cicle_center_nodeId [::hwat::utils::GetEntityMaxId node];	
	set retainer_cricle_nodes [::doghouse::getCircleNodes $nodeId $cicle_center_nodeId $edge_nodes];
	*nodecleartempmark;
		
	return [list $retainer_cricle_nodes $edge_nodes $closeNodeId1 $closeNodeId2];
	
	
}

