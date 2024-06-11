if {[namespace exists ::dummyMaterial]} {
	namespace delete ::dummyMaterial
}

namespace eval ::dummyMaterial {
	
	set ::dummyMaterial::scriptDir [file dirname [info script]];
	if {[file exists [file join $::dummyMaterial::scriptDir utils.tbc]]} {
		source [file join $::dummyMaterial::scriptDir utils.tbc];
	} else {
		source [file join $::dummyMaterial::scriptDir utils.tcl];
	}

}

proc ::dummyMaterial::mask_1D_elems {} {

	set elms_1Ds [::antolin::connection::utils::get_1D_elements];
	
	eval *createmark elem 1 $elms_1Ds;
	*maskentitymark elements 1 0;

}

proc ::dummyMaterial::checkMat_assignment_ToComp {part_compIds} {
	
	set existing_partMatId 0;
	foreach compId $part_compIds {
		set matId [hm_getvalue component id=$compId dataname=material];
		if {$matId != 0} {
			set existing_partMatId $matId;
		}
	}
	
	return $existing_partMatId;
}

proc ::dummyMaterial::createDummyMat { mat_conunt } {
	
	set matName MAT$mat_conunt;
	while { [hm_entityinfo exist mats $matName] } {
		incr mat_conunt;
		set matName MAT$mat_conunt;
	}
	*createentity mats cardimage=MAT1 name=$matName;
	
	set matId [::hwat::utils::GetEntityMaxId mat];
	
	return [list $mat_conunt $matId]
}

proc ::dummyMaterial::assignMatToComps {} {
	
	set mat_conut 1;
	
	foreach n_part [lsort -increasing -real [array names ::dummyMaterial::arr_partAndComps]] {
		set part_compIds [set ::dummyMaterial::arr_partAndComps($n_part)];
		
		set existing_partMatId [::dummyMaterial::checkMat_assignment_ToComp $part_compIds];
		if {$existing_partMatId != 0} {
			#true
			set matId $existing_partMatId;
		} else {
			set ret [::dummyMaterial::createDummyMat $mat_conut];
			set mat_conunt [lindex $ret 0];
			set matId [lindex $ret 1];
		}
		
		foreach compId $part_compIds {
			#check if comp has material assigned
			set existing_matId [hm_getvalue comp id=$compId dataname=material];
			if {$existing_matId != 0} {
				#if material avaliable to comp, skip new mat assignment
				continue;
			}
			*setvalue comps id=$compId materialid={mats $matId}
		}
	}
}

proc ::dummyMaterial::identifyParts {} {

	#hide all 1-Ds
	::dummyMaterial::mask_1D_elems;
	
	# get all shell elements
	*createmark elem 1 displayed;
	set displayed_shell_elems [hm_getmark elems 1];
	
	catch {array unset ::dummyMaterial::arr_partAndComps}
	array set ::dummyMaterial::arr_partAndComps ""
	set part_conunt 1;	
	while {[llength $displayed_shell_elems] > 0} {
		
		*clearmark element 1
		# take any random shell and find attached elements
		set shell_elemId [lindex $displayed_shell_elems 0];
		*createmark elem 1 $shell_elemId;
		*appendmark elem 1 "by attached";
		set part_elementIds [hm_getmark element 1];
		*clearmark element 1
				
		set part_componentIds "";
		eval *createmark element 1 $part_elementIds;
		set part_componentIds [lsort -unique [join [hm_getvalue elem markid=1 dataname=component]]];
			
		# hide parts
		eval *createmark compss 2 $part_componentIds;
		*createstringarray 2 "elements_on" "geometry_on"
		*hideentitybymark 2 1 2;
		
		set ::dummyMaterial::arr_partAndComps($part_conunt) $part_componentIds;
				
		# get all shell elements
		*createmark elem 1 displayed;
		set displayed_shell_elems [hm_getmark elems 1];
				
		incr part_conunt
				
	}
}


proc ::dummyMaterial::create_Assign_Mats_to_Comp {} {

	if {[string trim [set ::connector::vehicle_program_name]] == ""} {
		tk_messageBox -message "Kindly enter \"valid vehicle program name\" to proceed...!" -icon error;
		return;
	}

	set ::dummyMaterial::material_flag 1;
	
	set t [clock click]; 
	*saveviewmask "view$t" 0;
	
	::dummyMaterial::identifyParts;
	::dummyMaterial::assignMatToComps;
	*restoreviewmask "view$t" 0;
	*removeview "view$t";
	
	#enable connection buttons
	::connector::enableConnectionBtns;
	
	#disable material buttons
	::connector::disableMaterialBtn;
		
}

# ::dummyMaterial::create_Assign_Mats_to_Comp
