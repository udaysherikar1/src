if {[namespace exists ::skoda::connection]} {
	namespace delete ::skoda::connection
}

namespace eval ::skoda::connection {
	set ::skoda::connection::scriptDir [file dirname [info script]];	
}

proc ::skoda::connection::createFillHoleComponentProp {compId} {
	
	*setvalue comps id=$compId cardimage="PART_2D";
	*setvalue comps id=$compId STATUS=1 1148=0.5;
	*setvalue comps id=$compId STATUS=2 416=0.5;
	*setvalue comps id=$compId STATUS=2 126=5;
}


proc ::skoda::connection::fillHole {nodeList compName} {

	if {![hm_entityinfo exist components $compName]} {
		*createentity comps name=$compName;
		set compId [::hwat::utils::GetEntityMaxId comp];
		::skoda::connection::createFillHoleComponentProp $compId;
	}
	*currentcollector components $compName
	eval *createmark nodes 1 $nodeList
	*createstringarray 4 "Remesh: 1" "AdjacentComp: 2" "CurvedFill: 1" "DefineMaxWidth:0"
	*fill_fe_holes 1 1 0 1 4
	*clearmark all
}

proc ::skoda::connection::checkEntityAvailability { entityType entityName } {
	#set entityName SECFO_Surface_weld_bottom_Elem_LOC_11
	set no_extension 1;
	while {[hm_entityinfo exist $entityType $entityName]} {
		incr no_extension;
		#set entityName [join [string range [split $entityName "_"] 0 end-1] _]_$no_extension
		set entityName [string range $entityName 0 [string last _ $entityName]]$no_extension
	}
	return $no_extension;
}

proc ::skoda::connection::getElemAssociatedWithNodes {nodes} {

	eval *createmark nodes 1 $nodes;
	*findmark nodes 1 257 1 elements 0 2;
	set elems [hm_getmark elements 2];
	
	return $elems

}

proc ::skoda::connection::CreateSectionCards {section_name node_set_id elem_set_id} {
	
	#create section name
	*createentity crosssections config=401 name=$section_name;
	set secId [::hwat::utils::GetEntityMaxId crosssections];
	*setvalue crosssections id=$secId STATUS=2 secfotype=4;
	
	*setvalue crosssections id=$secId STATUS=2 nodeentities={sets $node_set_id}
	*setvalue crosssections id=$secId STATUS=2 elementities={sets $elem_set_id}

}

proc ::skoda::connection::main {weldCollectorName m_nodes {screw_boss_nodes ""} f_nodes m_node_set_name m_elem_set_name\
								f_node_set_name f_elem_set_name m_section_name f_section_name connectionType} {
	
	
	if {$connectionType == "screw" || $connectionType == "usweld" || $connectionType == "ribweld"} {
		
		#consider all nodes of RP to create R-body;
		set fillHole_compName "xxx_xxx_xxx__xxx__PLAST_CONNECTION__xx_xx_xxxx__PLAST_NULL";
		#get inittial elemments in a comp 
		*createmark elem 1 "by comp" $fillHole_compName;
		if {$connectionType != "ribweld"} {
			# dont execute fill hole option for rib in ribweld
			::skoda::connection::fillHole $m_nodes $fillHole_compName;
		}	
		::skoda::connection::fillHole $f_nodes $fillHole_compName;
		#get final elemments in a comp 
		*createmark elem 2 "by comp" $fillHole_compName;
				
		*markdifference elems 2 elems 1;
		set new_RP_elems [hm_getmark elems 2];	
		set new_RP_nodes [lsort -unique [join [hm_getvalue elem markid=2 dataname=nodes]]];
		
		if {[llength $screw_boss_nodes] == 0} {
			set combined_nodes [concat $m_nodes $f_nodes $new_RP_nodes];
			set m_elems [::skoda::connection::getElemAssociatedWithNodes $m_nodes];
		} else {
			set combined_nodes [concat $screw_boss_nodes $f_nodes $new_RP_nodes];
			set m_elems [::skoda::connection::getElemAssociatedWithNodes $screw_boss_nodes];
		}
		set f_elems [::skoda::connection::getElemAssociatedWithNodes $f_nodes];
		
		#remove RP elements from m_elems and f_elems
		set m_elems [lremove $m_elems $new_RP_elems];
		set f_elems [lremove $f_elems $new_RP_elems];
		
		lappend ::connector::recentlyCreatedEntity $new_RP_elems;
		set ::connector::recentlyCreatedEntity [join $::connector::recentlyCreatedEntity]
		
	} elseif {$connectionType == "metal_clip" || $connectionType == "plastic_clip"} {
		set combined_nodes [concat $m_nodes $f_nodes];
		
		set m_elems [::skoda::connection::getElemAssociatedWithNodes $m_nodes];
		set f_elems [::skoda::connection::getElemAssociatedWithNodes $f_nodes];
	
	} else {
		#surface welds
		set combined_nodes [concat $m_nodes $f_nodes];
		
		set m_elems [::skoda::connection::getElemAssociatedWithNodes $m_nodes];
		set f_elems [::skoda::connection::getElemAssociatedWithNodes $f_nodes];
	}
	
	*currentcollector components $weldCollectorName;
	
	#get set number and replace it in current set and create new
	set no_extension [::skoda::connection::checkEntityAvailability "sets" $m_node_set_name];
	set m_node_set_name [join [string range [split $m_node_set_name "_"] 0 end-1] _]_$no_extension;
	set m_elem_set_name [join [string range [split $m_elem_set_name "_"] 0 end-1] _]_$no_extension;
	set f_node_set_name [join [string range [split $f_node_set_name "_"] 0 end-1] _]_$no_extension;
	set f_elem_set_name [join [string range [split $f_elem_set_name "_"] 0 end-1] _]_$no_extension;
	set m_section_name [join [string range [split $m_section_name "_"] 0 end-1] _]_$no_extension;
	set f_section_name [join [string range [split $f_section_name "_"] 0 end-1] _]_$no_extension;
				
	#create male comp sets
	set m_node_setID [::antolin::connection::utils::createSet $m_node_set_name];
	set m_elem_setID [::antolin::connection::utils::createSet $m_elem_set_name];
	#create female comp sets
	set f_node_setID [::antolin::connection::utils::createSet $f_node_set_name];
	set f_elem_setID [::antolin::connection::utils::createSet $f_elem_set_name];
	
	#add entity to sets 
	*setvalue sets id=$m_node_setID ids={nodes $m_nodes}
	*setvalue sets id=$m_elem_setID ids={elems $m_elems}
	*setvalue sets id=$f_node_setID ids={nodes $f_nodes}
	*setvalue sets id=$f_elem_setID ids={elems $f_elems}
	
	
	::welds::createRigids $combined_nodes "Skoda_Rigids_connections";
		
	::skoda::connection::CreateSectionCards $m_section_name $m_node_setID $m_elem_setID;
	::skoda::connection::CreateSectionCards $f_section_name $f_node_setID $f_elem_setID;
	
	#highlight comps 
	eval *createmark components 3 "xxx_xxx_xxx__xxx__PLAST_CONNECTION__xx_xx_xxxx__PLAST_NULL" "Skoda_Rigids_connections"
	*createstringarray 2 "elements_on" "geometry_off"
	*showentitybymark 3 1 2
	
}