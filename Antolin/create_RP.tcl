catch {namespace delete ::circularRP}

namespace eval ::circularRP {
	
	set ::circularRP::scriptDir [file dirname [info script]];
		
}

proc ::circularRP::automesh { circle_surfId elemSize} {

	*createmark surfaces 1 $circle_surfId
	*interactiveremeshsurf 1 $elemSize 2 2 2 1 1
	*set_meshfaceparams 0 6 2 0 0 1 0.5 1 1
	*automesh 0 6 2
	*storemeshtodatabase 1
	*ameshclearsurface 


}

proc ::circularRP::alineMasterNodes { masterNode1 masterNode2 vector avg_dist} {

	#translate master node along element vector.... it is to aling both master-2 wrt element normal direction of surfacew weld
	*createmark node 1 $masterNode1;
	*duplicatemark node 1 1;
	set masterNode2_temp [hm_getmark node 1];
	
	eval *createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
	eval *createmark nodes 1 $masterNode2_temp;
	*translatemark nodes 1 1 $avg_dist;
	*createmark nodes 1 $masterNode2
	*alignnode3 $masterNode1 $masterNode2_temp 1;
	
	#*nodecleartempmark;
	
	return $masterNode2;
}

proc ::circularRP::create {comp_thickness inner_nodes rigid_centerNodeId_2} {

	#*createcenternode [lindex $inner_nodes 0] [lindex $inner_nodes 1] [lindex $inner_nodes 2];
	#set centerId [::hwat::utils::GetEntityMaxId node];
	
	#puts "inner_nodes -- $inner_nodes"
	eval *createmark nodes 1 $inner_nodes;
	*createbestcirclecenternode nodes 1 0 1 0;
	# # set circle_radius [lindex [hm_getbestcirclecenter nodes 1] end];
	set centerId [::hwat::utils::GetEntityMaxId node];
	set circle_radius [lindex [hm_getdistance nodes $centerId  [lindex $inner_nodes 0] 0] 0];
	
	#get element normal of washer element on f-part		
	set ret [::antolin::connection::utils::GetWasherNodeIds $inner_nodes];
	set f_washerElements [lindex $ret 0];
	set f_washerNodes [lindex $ret 1];
	set vector [::antolin::connection::utils::getAvgElementNormals $f_washerElements];
	
	#aling center nodes of top and bottom rigids	
	set centerId [::circularRP::alineMasterNodes $rigid_centerNodeId_2 $centerId $vector $::connector::joint_length];
	#calculate unite vector from bottom to top center nodes 	
	set unit_vector [::antolin::connection::utils::calculateUnitVector $rigid_centerNodeId_2 $centerId];
		
	set radius [expr $circle_radius*1.4]
	*createlist nodes 1 $centerId
	*createvector 1 [lindex $unit_vector 0] [lindex $unit_vector 1] [lindex $unit_vector 2]
	*createcirclefromcenterradius 1 1 $radius 360 0
	set circle_lineId [::hwat::utils::GetEntityMaxId line];
	
	*surfacemode 4
	*createmark lines 1 $circle_lineId
	*surfacesplineonlinesloop 1 1 1 67
	
	set trans_dist [expr ($comp_thickness+1)/2.0]
	
	#set trans_dist -10;
	set circle_surfId [::hwat::utils::GetEntityMaxId surface];
	*createmark surfaces 1 $circle_surfId
	*translatemark surfaces 1 1 $trans_dist
	
	*createmark lines 1 $circle_lineId
	*deletemark lines 1
	
	*nodecleartempmark;
	
	return $circle_surfId
	
		
}

proc ::circularRP::create_RP_Prop {} {
	
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

proc ::circularRP::createRP_main {inner_nodes rigid_centerNodeId_2 compName comp_thickness elemSize} {
	
	if {![hm_entityinfo exist comps $compName] } {
		*createentity comps cardimage=Part name=$compName;
	}
	*currentcollector components $compName;
	set RP_comp_id [hm_getvalue comp name=$compName dataname=id];
	
	set circle_surfId [::circularRP::create $comp_thickness $inner_nodes $rigid_centerNodeId_2];
	
	
	*createmark elem 1 "by comp" $compName
	
	#standard element size
	#automesh
	::circularRP::automesh $circle_surfId $elemSize;
	
	*createmark elem 2 "by comp" $compName;
	
	*markdifference elems 2 elems 1
	set RP_elems [hm_getmark elem 2];
	
	set RP_prop_id [::circularRP::create_RP_Prop];
	
	#assign RP prop to RP comp 
	*setvalue comps id=$RP_comp_id propertyid={props $RP_prop_id}
	
	#workaround to delete circular surface 
	if {![hm_entityinfo exist comps "temp_comp"] } {
		*createentity comps cardimage=Part name="temp_comp";
	}
	*createmark surfaces 1 $circle_surfId
	*movemark surfaces 1 "temp_comp"
	*createmark components 1 "temp_comp"
	*deletemark components 1
	
	return $RP_elems
	
}


