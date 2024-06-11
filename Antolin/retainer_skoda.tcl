if {[namespace exists ::retainer::skoda]} {
	namespace delete ::retainer::skoda
}
namespace eval ::retainer::skoda {
	set ::retainer::skoda::scriptDir [file dirname [info script]];
	if {[file exists [file join $::retainer::scriptDir skoda.tbc]]} {
		source [file join $::retainer::scriptDir skoda.tbc];
	} else {
		source [file join $::retainer::scriptDir skoda.tcl];
	}

}

proc ::retainer::skoda::exec_retainers {retainer_nodeIds} {
	
	*nodecleartempmark ;
	
	#create comp collector for rigids
	if {![hm_entityinfo exist comps "Skoda_Rigids_connections"] } {
		*createentity comps cardimage=Part name="Skoda_Rigids_connections";
	}
		
	set retainer_RP_comp "Retainer_Rigid_Patch";
	if {![hm_entityinfo exist comps $retainer_RP_comp] } {
		*createentity comps cardimage=Part name=$retainer_RP_comp;
	}
	set RP_comp_id [hm_getvalue comp name=$retainer_RP_comp dataname=id];
		
	#consider all nodes of RP to create R-body;
	set fillHole_compName "xxx_xxx_xxx__xxx__PLAST_CONNECTION__xx_xx_xxxx__PLAST_NULL";
	
	set m_node_set_name "SECFO_Retainer_doghouse_Nodes_LOC_1"
	set m_elem_set_name "SECFO_Retainer_doghouse_Elem_LOC_1"
	set m_section_name "SECFO_Retainer_doghouse_LOC_1"
			
	set temp_comp "retainer_RP_temp_comp"
	set cir_radius 5;
	set mesh_size 2.5;
	foreach nodeId $retainer_nodeIds {
	
		set ret [::doghouse::GetDoghouseNodes $nodeId];
		set retainer_circle_nodes [lindex $ret 0];
		set retainer_edge_nodes [lindex $ret 1];
		set edge_node1 [lindex $ret 2];
		set edge_node2 [lindex $ret 3];
				
		#calculate vector
		set vector [::retainer::calculateVector $nodeId $retainer_circle_nodes $retainer_edge_nodes];
				
		::retainer::createCircularSurface $vector $retainer_circle_nodes $temp_comp $cir_radius;				
		::retainer::translate_Comp $temp_comp $vector $::connector::joint_length;	
		set temp_comp_id [hm_getvalue comp name=$temp_comp dataname=id];
		::retainer::meshSurface $temp_comp_id $mesh_size;
		::retainer::scale_elements $temp_comp;
		set RP_elems [::retainer::moveElems $temp_comp $retainer_RP_comp];	
		set ::connector::recentlyCreatedEntity [lsort -unique [join [lappend ::connector::recentlyCreatedEntity $RP_elems]]];
		
		eval *createmark elements 1 $RP_elems;
		set top_RP_nodes [lsort -unique [join [hm_getvalue elements markid=1 dataname=nodes]]];
				
		#get inittial elemments in a comp 
		*createmark elem 1 "by comp" $fillHole_compName;
		::skoda::connection::fillHole $retainer_circle_nodes $fillHole_compName;
		*createmark elem 2 "by comp" $fillHole_compName;
		*markdifference elems 2 elems 1;
		set fillhole_RP_elems [hm_getmark elems 2];	
		set fillhole_RP_nodes [lsort -unique [join [hm_getvalue elem markid=2 dataname=nodes]]];
		set ::connector::recentlyCreatedEntity [lsort -unique [join [lappend ::connector::recentlyCreatedEntity $fillhole_RP_elems]]];
		
		set combined_nodes [concat $top_RP_nodes $fillhole_RP_nodes];	
		
		set retainer_circle_elems [::skoda::connection::getElemAssociatedWithNodes $retainer_circle_nodes];
		
		#remove RP elements from m_elems and f_elems
		set retainer_circle_elems [lremove $retainer_circle_elems $fillhole_RP_elems];
		
		#get set number and replace it in current set and create new
		set no_extension [::skoda::connection::checkEntityAvailability "sets" $m_node_set_name];
		set m_node_set_name [join [string range [split $m_node_set_name "_"] 0 end-1] _]_$no_extension;
		set m_elem_set_name [join [string range [split $m_elem_set_name "_"] 0 end-1] _]_$no_extension;
		set m_section_name [join [string range [split $m_section_name "_"] 0 end-1] _]_$no_extension;
		
		#create male comp sets
		set m_node_setID [::antolin::connection::utils::createSet $m_node_set_name];
		set m_elem_setID [::antolin::connection::utils::createSet $m_elem_set_name];
		
		#add entity to sets 
		*setvalue sets id=$m_node_setID ids={nodes $retainer_circle_nodes}
		*setvalue sets id=$m_elem_setID ids={elems $retainer_circle_elems}
		
		#create rigid
		::welds::createRigids $combined_nodes "Skoda_Rigids_connections";
		
		::skoda::connection::CreateSectionCards $m_section_name $m_node_setID $m_elem_setID;
		
		#::retainer::createSystem $edge_node1 $edge_node2
		
		#highlight comps 
		eval *createmark components 3 "xxx_xxx_xxx__xxx__PLAST_CONNECTION__xx_xx_xxxx__PLAST_NULL" "Skoda_Rigids_connections"
		*createstringarray 2 "elements_on" "geometry_off"
		*showentitybymark 3 1 2
		
		#delete temp comp
		*createmark components 1 $temp_comp;
		catch {*deletemark components 1}
		
		*nodecleartempmark;
		
	}
	
	


}