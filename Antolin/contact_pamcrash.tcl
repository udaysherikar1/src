catch {namespace delete ::antolin::connection::pam_contact}

namespace eval ::antolin::connection::pam_contact {

}

proc ::antolin::connection::pam_contact::createTieContact_main {masterSetId slaveSetId barCompCollectorName grupo_contact tie_contact_comp} {
	
	set t [clock click ];
	
	#set grupo_contact "grupo_Tie_contact_heat_stake"
	#set tie_contact_comp "grupo_tie_contact_heat_stake"
	
	*createmark elem 1 "by set" $masterSetId
	set shell_elems [hm_getmark elements 1];
	
	*createmark elem 1 "by set" $slaveSetId
	set existing_Bar_elems_in_set [hm_getmark elements 1];
	
	#create master and slave set 
	#set shell_setId [::antolin::connection::pam_contact::createSets $master_name];
	#set bar_setId [::antolin::connection::pam_contact::createSets $slave_name];
	
	
	set bar_elems [::antolin::connection::pam_contact::identifyContactElements $barCompCollectorName];
	
	set bar_elems [concat $existing_Bar_elems_in_set $bar_elems]
		
	#add elements to sets
	::antolin::connection::pam_contact::AddElemsToSet $masterSetId $shell_elems
	::antolin::connection::pam_contact::AddElemsToSet $slaveSetId $bar_elems
	
	if { ![hm_entityinfo exist group $grupo_contact]} {
		#create Tie contact group and assign set ids 
		set group_Id [::antolin::connection::pam_contact::createGroups $masterSetId $slaveSetId $grupo_contact]
	} else {
		set group_Id [hm_getvalue group name=$grupo_contact dataname=id];
	}
	
	if { ![hm_entityinfo exist comp $tie_contact_comp]} {
		#create contact component collector
		set comp_Id [::antolin::connection::pam_contact::createContactComponent $tie_contact_comp];
		#assign contact comp collector to Tie contact group 
		::antolin::connection::pam_contact::AssignCompToGroup $group_Id $comp_Id
	} else {
		set comp_Id [hm_getvalue comp name=$tie_contact_comp dataname=id];
	}
}


proc ::antolin::connection::pam_contact::identifyContactElements {barCompCollectorName} {
		
	set bar_elems [hm_getvalue comp name=$barCompCollectorName dataname=elements];
	
	return $bar_elems
}


proc ::antolin::connection::pam_contact::createContactComponent {comp_name} {
	
	set comp_ID [expr [hm_entityinfo maxid comp] +1 ];
	*createentity comps cardimage=PART_2D name=$comp_name
	#*setvalue comps id=$comp_ID name=$comp_name
	*setvalue comps id=$comp_ID cardimage="PART_LINK"
	
	return $comp_ID
}

proc ::antolin::connection::pam_contact::createGroups {shell_setId bar_setId group_name} {

	set group_ID [expr [hm_entityinfo maxid groups] +1 ];
	
	*createentity groups cardimage=CNTAC33 name=$group_name
	
	*setvalue groups id=$group_ID cardimage="TIED"	
	*setvalue groups id=$group_ID masterentityids={sets $shell_setId}
	*setvalue groups id=$group_ID slaveentityids={sets $bar_setId}
	
	return $group_ID
	
}

proc ::antolin::connection::pam_contact::AddElemsToSet {setId lst_elements} {

	*setvalue sets id=$setId ids={elems $lst_elements}
}

proc ::antolin::connection::pam_contact::AssignCompToGroup {groupId compId} {
	*setvalue groups id=$groupId STATUS=2 8016={comps $compId}
}


#::antolin::connection::pam_contact::createTieContact_main "grupo_shells" "grupo_bar" "grupo_contact" "tie_contact_comp" lst_shells lst_bars

