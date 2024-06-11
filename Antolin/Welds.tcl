
if {[namespace exists ::welds]} {
	namespace delete ::welds
}

namespace eval ::welds {

	set ::welds::scriptDir [file dirname [info script]];
	set ::welds::profile [hm_info templatetype];
}


proc ::welds::createRigids {nodeIds comp_Name} {
	
	#make current collector
	# *currentcollector components "Rigids_connections"
	*currentcollector components $comp_Name;
	
	eval *createmark node 1 $nodeIds
	if { $::welds::profile == "lsdyna" } {
		if {$::connector::pArr(beamType) == "Rigids"} {
			*elementtype 5 2;
			*rigidlinkinodecalandcreate 1 0 1 123456;
			
			*createmark element 1 -1;
			set elemId [hm_getmark element 1];	
			lappend ::connector::recentlyCreatedEntity $elemId;
			
		} else {
		
			#create temporary rigid element 
			*elementtype 5 2;
			*rigidlinkinodecalandcreate 1 0 1 123456;
			
			*createmark element 1 -1;
			set rigid_elem [hm_getmark element 1];	
			
			#get master node of rigid 
			*createmark node 1 -1;
			set masterNode [hm_getmark node 1];	
			
			#create temp node at master node location 
			*createmark nodes 1 $masterNode
			*nodemarkaddtempmark 1;
			#get temp master node id 
			*createmark node 1 -1;
			set masterNode [hm_getmark node 1];	
			
			#delete rigid element
			*createmark elements 1 $rigid_elem;
			*deletemark elements 1;	


			foreach beam_second_node $nodeIds {
				*createvector 1 0 0 -1
				*barelementcreatewithoffsets $masterNode $beam_second_node 1 0 0 0 0 "" 0 0 0 0 0 0 0 0		

				*createmark element 1 -1;
				set elemId [hm_getmark element 1];	
				lappend ::connector::recentlyCreatedEntity $elemId;				
			}			
				
		}
		
	}
	
	if { $::welds::profile == "abaqus" } {	
		*elementtype 5 9
		*rigidlinkinodecalandcreate 1 0 0 123456;
		
		*createmark element 1 -1;
		set elemId [hm_getmark element 1];	
		lappend ::connector::recentlyCreatedEntity $elemId;
	}
	if { $::welds::profile == "pamcrash2g" } {	
		if {$::connector::pArr(beamType) == "Rigids"} {
			*elementtype 5 1;
			*rigidlinkinodecalandcreate 1 0 0 123456;	
		} else {
			#Mtoco
			*elementtype 5 3
			*rigidlinkinodecalandcreate 1 0 0 123456
		}
		
		*createmark element 1 -1;
		set elemId [hm_getmark element 1];	
		lappend ::connector::recentlyCreatedEntity $elemId;
	}
	
	*createmark node 1 -1;
	set masterNode [hm_getmark node 1];			
	*clearmark nodes 1;
	
	return $masterNode;
}


proc ::welds::updateRigids_jointOnSlave {masterNode1 lst_surfaceWeldNodeIds masterNode2 base_comp_nodeIds vector} {
	
	*createmark elem 1 "by node" $masterNode1;
	set rigid_elemId1 [hm_getmark elem 1];
	
	*createmark node 1 $masterNode1;
	*duplicatemark node 1 1;
	*createmark node 1 -1;
	set duplicate_masterNode1 [hm_getmark node 1];
		
	*createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
	*translatemark nodes 1 1 0.5;
	
	eval *createmark nodes 1 $lst_surfaceWeldNodeIds;
	*appendmark nodes 1 $duplicate_masterNode1;
	*rigidlinkupdate $rigid_elemId1 $masterNode1 1;
		
	*createmark elem 1 "by node" $masterNode2;
	set rigid_elemId2 [hm_getmark elem 1];
	
	*createmark node 1 $masterNode2;
	*duplicatemark node 1 1;
	*createmark node 1 -1;
	set duplicate_masterNode2 [hm_getmark node 1];	
	
	*createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
	*translatemark nodes 1 1 -0.5;
	
	eval *createmark nodes 1 $base_comp_nodeIds;
	*appendmark nodes 1 $duplicate_masterNode2;
	*rigidlinkupdate $rigid_elemId2 $masterNode2 1;
	
	return [list $duplicate_masterNode1 $duplicate_masterNode2];
	
}

proc ::welds::CalculateMasterNodeTranlationDistance {masterNode1 masterNode2 vector beam_length {weld_type ""}} {
	
	set vector [::antolin::connection::utils::calculateUnitVector $masterNode1 $masterNode2];
	
	set curr_dist [hm_getdistance nodes $masterNode2 $masterNode1 0];
	set curr_dist_x [lindex $curr_dist 1];
	set curr_dist_y [lindex $curr_dist 2];
	set curr_dist_z [lindex $curr_dist 3];
	
	lassign [lindex [hm_nodevalue $masterNode2] 0] x y z
	
	set along_x [expr [lindex $vector 0] * $beam_length];
	set along_y [expr [lindex $vector 1] * $beam_length];
	set along_z [expr [lindex $vector 2] * $beam_length];
	
	set new_node_cordi_x [expr $x+$along_x+$curr_dist_x];
	set new_node_cordi_y [expr $y+$along_y+$curr_dist_y];
	set new_node_cordi_z [expr $z+$along_z+$curr_dist_z];
	
	*nodemodify $masterNode2 $new_node_cordi_x $new_node_cordi_y $new_node_cordi_z
	
	# puts "vector -- $vector"
	# set n_distance [lindex [hm_getdistance nodes $masterNode1 $masterNode2 0] 0];
	# puts "n_distance -- $n_distance"
	# puts "beam_length -- $beam_length"
	# set masterNodeTranlationDist [expr $n_distance - $beam_length];	
	# #if {$masterNodeTranlationDist <= 0} {
	# #	return;
	# #}
	# puts "masterNodeTranlationDist -- $masterNodeTranlationDist"
	
	# *createmark node 1 $masterNode2;
	# *createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
	# *translatemark nodes 1 1 $masterNodeTranlationDist;
}

proc ::welds::alineMasterNodes { masterNode1 masterNode2 vector avg_dist} {

	#translate master node along element vector.... it is to aling both master-2 wrt element normal direction of surfacew weld
	*createmark node 1 $masterNode1;
	*duplicatemark node 1 1;
	set masterNode2_temp [hm_getmark node 1];
	
	eval *createvector 1 [lindex $vector 0] [lindex $vector 1] [lindex $vector 2];
	eval *createmark nodes 1 $masterNode2_temp;
	*translatemark nodes 1 1 $avg_dist;
	*createmark nodes 1 $masterNode2
	*alignnode3 $masterNode1 $masterNode2_temp 1;
	
	*nodecleartempmark;
	
	#return $masterNode2_temp;
	return $masterNode2;
}

proc ::welds::createWeldConnection { weldCollectorName masterNode1 masterNode2 vector} {
		
	#create weld elements
	*currentcollector components $weldCollectorName

	if { $::welds::profile == "lsdyna" } {
		*elementtype 60 1;
		*createvector 1 0 0 -1;
		*barelementcreatewithoffsets $masterNode1 $masterNode2 1 0 0 0 0 "" 0 0 0 0 0 0 0 0;
		
		#supress node N3 in beam
		*createmark elem 1 -1;
		set beamElmId [hm_getmark elem 1];
		*attributeupdateint elements $beamElmId 4153 9 2 0 1;
	}
	
	if { $::welds::profile == "abaqus" } {	
		*elementtype 61 13;
		*rod $masterNode1 $masterNode2 "";
	}
	
	if { $::welds::profile == "pamcrash2g" } {	
		*elementtype 21 2
		*spring $masterNode1 $masterNode2 1 "" 0
	}
	
	*createmark element 1 -1;
	set elemId [hm_getmark element 1];	
	lappend ::connector::recentlyCreatedEntity $elemId;
}


proc ::welds::assigncardImageToComp {weldCollectorName} {
	
	set comp_Id [hm_getvalue comp name=$weldCollectorName dataname=id];
	if { $::welds::profile == "pamcrash2g" } {
		*setvalue comps id=$comp_Id cardimage="PART_1D"
		*setvalue comps id=$comp_Id STATUS=2 5010=8
		*setvalue comps id=$comp_Id STATUS=0 4004="SPRGBM"
	}

}

proc ::welds::assignProperty {weldCollectorName {connectionType ""}} {
	
	set prop_Id [hm_getvalue prop name=$weldCollectorName dataname=id];
	
	if { $::welds::profile == "lsdyna" } {
		
		*setvalue props id=$prop_Id cardimage="SectBeam"
		
		*setvalue props id=$prop_Id STATUS=2 399=6
		*setvalue props id=$prop_Id STATUS=0 2216=0
		*setvalue props id=$prop_Id STATUS=0 10002=0
		*setvalue props id=$prop_Id STATUS=1 402=0.833333
		*setvalue props id=$prop_Id STATUS=1 429=2
		
		#turn off CST
		*setvalue props id=$prop_Id STATUS=1 403=1
		*createmark properties 1 $prop_Id
		*attributeupdatedoublemark properties 1 403 9 0 0 1
		
		#ON SCOOR and set value to 2
		*setvalue props id=$prop_Id STATUS=1 3122=2
		#ON VOL and set value to 500
		*setvalue props id=$prop_Id STATUS=1 410=500
		#ON INER and set value to 0.01
		*setvalue props id=$prop_Id STATUS=1 411=0.01
					
		*setvalue props id=$prop_Id STATUS=1 723=4
		*setvalue props id=$prop_Id STATUS=1 724=4
		
		#turn on title check box
		*createmark properties 1 $prop_Id;		
		*attributeupdateintmark properties 1 90 9 2 0 1;
		
	} elseif { $::welds::profile == "abaqus" } {
		
		*setvalue props id=$prop_Id cardimage="CONNECTORSECTION";
		if {$connectionType == "retainer"} {
			*setvalue props id=$prop_Id STATUS=2 865="PLANAR";
		} else {
			*setvalue props id=$prop_Id STATUS=2 865="BEAM"
		}
		*setvalue props id=$prop_Id STATUS=2 4701=1;
		*setvalue props id=$prop_Id STATUS=2 867=1;
		*setvalue props id=$prop_Id STATUS=2 2516=0;
		*setvalue props id=$prop_Id STATUS=2 868="";
		*setvalue props id=$prop_Id STATUS=2 870=0;
		*setvalue props id=$prop_Id STATUS=2 2516=1;
		*setvalue props id=$prop_Id STATUS=2 863=1;
		*setvalue props id=$prop_Id STATUS=2 4701=1
		
	} elseif { $::welds::profile == "pamcrash2g" } {
	
		*setvalue props id=$prop_Id STATUS=1 399=16
		*setvalue props id=$prop_Id STATUS=1 402=0.833333
		*setvalue props id=$prop_Id STATUS=1 427=5
		*setvalue props id=$prop_Id STATUS=1 428=1
		*setvalue props id=$prop_Id STATUS=1 429=0
		*setvalue props id=$prop_Id STATUS=1 430=0
		*setvalue props id=$prop_Id STATUS=1 431=1
		*setvalue props id=$prop_Id STATUS=1 435=0
		*setvalue props id=$prop_Id STATUS=1 2015=0
		
	}
	
	return $prop_Id;
}

proc ::welds::assignMaterial {weldCollectorName} {
	
	set mat_Id [hm_getvalue mats name=$weldCollectorName dataname=id];
	
	if { $::welds::profile == "lsdyna" } {
	
		*setvalue mats id=$mat_Id STATUS=2 4449=1
		*setvalue mats id=$mat_Id STATUS=0 4440=0
		*setvalue mats id=$mat_Id STATUS=0 4439=0
		*setvalue mats id=$mat_Id STATUS=2 8559={curves 0}
		*setvalue mats id=$mat_Id STATUS=0 5353=0
		*setvalue mats id=$mat_Id STATUS=0 6130=0
		*setvalue mats id=$mat_Id STATUS=0 1662=0
		*setvalue mats id=$mat_Id STATUS=0 6131=0
		*setvalue mats id=$mat_Id STATUS=1 118=1.05e-06
		*setvalue mats id=$mat_Id STATUS=1 119=0.04
		*setvalue mats id=$mat_Id STATUS=1 2528=0.3
		*setvalue mats id=$mat_Id STATUS=1 2529=0.2
		*setvalue mats id=$mat_Id STATUS=1 2530=0.025
		*setvalue mats id=$mat_Id STATUS=1 4440=1
		*setvalue mats id=$mat_Id STATUS=0 5352=0
		*setvalue mats id=$mat_Id STATUS=1 2533=0.025
		*setvalue mats id=$mat_Id STATUS=1 2534=0.048
		*setvalue mats id=$mat_Id STATUS=1 3236=0.048
		*setvalue mats id=$mat_Id STATUS=1 4439=0
		*setvalue mats id=$mat_Id STATUS=1 5352=0
		
	} elseif { $::welds::profile == "abaqus" } {
	
		*setvalue mats id=$mat_Id STATUS=2 1375=1;
		*setvalue mats id=$mat_Id STATUS=0 1378=0;
		*setvalue mats id=$mat_Id STATUS=0 1379=0;
		*setvalue mats id=$mat_Id STATUS=1 1378=2;
		*setvalue mats id=$mat_Id STATUS=1 1379=2;
		*setvalue mats id=$mat_Id STATUS=2 1380=1;
		*setvalue mats id=$mat_Id STATUS=0 1383=0;
		*setvalue mats id=$mat_Id STATUS=0 1384=0;
		*setvalue mats id=$mat_Id STATUS=1 1383=2;
		*setvalue mats id=$mat_Id STATUS=1 1384=2;
		
	} elseif { $::welds::profile == "pamcrash2g" } {
	
		*setvalue mats id=$mat_Id STATUS=1 118=8e-09
		*setvalue mats id=$mat_Id STATUS=1 119=210000
		*setvalue mats id=$mat_Id STATUS=1 120=0.3
		*setvalue mats id=$mat_Id STATUS=1 282=0
		*setvalue mats id=$mat_Id STATUS=1 1162=0
		*setvalue mats id=$mat_Id STATUS=1 1163=0
		*setvalue mats id=$mat_Id STATUS=1 1164=0
	}
	
	return $mat_Id;
}


proc ::welds::createSpiderBeamProp_dyna {} {

	if {![hm_entityinfo exist props "spiderBeamProp"] } {
		*createentity props cardimage=SectShll name="spiderBeamProp"	
	}
	set prop_id [hm_getvalue props name="spiderBeamProp" dataname=id];
	*setvalue props id=$prop_id cardimage="SectBeam";
	*setvalue props id=$prop_id STATUS=2 90=1;
	*setvalue props id=$prop_id STATUS=2 399=1;
	*setvalue props id=$prop_id STATUS=1 402=0.833333;
	*setvalue props id=$prop_id STATUS=1 429=2;
	*setvalue props id=$prop_id STATUS=1 403=1;
	*setvalue props id=$prop_id STATUS=1 723=1;
	*setvalue props id=$prop_id STATUS=1 724=1;
	
	return $prop_id;
}

proc ::welds::createSystem {weldCollectorName origin_node axis_node plane_node} {
	
	*currentcollector systcols $weldCollectorName
	*systemcreate3nodes 0 $origin_node "x-axis" $axis_node "xy-plane" $plane_node;
	
	
	*createmark system 1 -1;
	set sysId [hm_getmark system 1];	
	lappend ::connector::recentlyCreatedLCS $sysId;
	
}


