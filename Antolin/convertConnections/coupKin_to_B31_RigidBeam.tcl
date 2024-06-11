catch {namespace delete ::abaqus::coupKin_to_B31}

namespace eval ::abaqus::coupKin_to_B31 {

}

namespace eval ::abaqus::coupKin_to_rigidBeam {

}

proc ::abaqus::coupKin_to_B31::createProp {} {
	
	if {![hm_entityinfo exist props "B31_prop"] } {
		*createentity props cardimage=SHELLSECTION name="B31_prop";
	}
	set propId [hm_getvalue prop name="B31_prop" dataname=id];
	
	*setvalue props id=$propId cardimage="BEAMGENSECTION";
	*setvalue props id=$propId STATUS=2 293=1;
	*setvalue props id=$propId STATUS=2 294=7.85e-12;
	*setvalue props id=$propId STATUS=2 143=1;
	*setvalue props id=$propId STATUS=2 144=0;
	*setvalue props id=$propId STATUS=2 296=5;
	*setvalue props id=$propId STATUS=2 246=2;
	*setvalue props id=$propId STATUS=2 698=1;
	*setvalue props id=$propId STATUS=0 699=1;
	*setvalue props id=$propId STATUS=2 703={0};
	*setvalue props id=$propId STATUS=2 700=210000;
	*setvalue props id=$propId STATUS=2 701=80769;
	*setvalue props id=$propId STATUS=2 702=1.3e-05;
	
	return $propId
}

proc ::abaqus::coupKin_to_B31::convert_To_B31 {COUP_KIN_elems propId} {
	
	set prop_name [hm_getvalue prop id=$propId dataname=name]
	
	set ::connector::connection_log_var  [list]
	set ::connector::connection_log_var [list [list "Converted COUP_KIN To B31" "=" [llength $COUP_KIN_elems] "connector(s)"]];
	
	if {![hm_entityinfo exist comp "B31_Comp" -byname]} {
		*createentity comps name="B31_Comp"
	}
	*currentcollector components "B31_Comp";
	set compId [hm_getvalue comp name="B31_Comp" dataname=id]
	
	*removeview "B31_View"
	*saveviewmask "B31_View" 0;
	::hwat::utils::BlockMessages "On"
	
	foreach elemId $COUP_KIN_elems {
		set elem_config [hm_getvalue element id=$elemId dataname=config	];
		if {$elem_config > 100} {
			# skip elements other than 1d
			continue
		}
		set nodes [hm_getvalue elem id=$elemId dataname=nodes];
		set masterNodeId [lindex $nodes 0];
		set legNodes [lrange $nodes 1 end];
		
		#create B31 elements
		*elementtype 60 9
		*createvector 1 0 0 -1;
		foreach legNode $legNodes {
			*barelementcreatewithoffsets $masterNodeId $legNode 1 0 0 0 0 $prop_name 0 0 0 0 0 0 0 0
		}
		
		*createmark elements 1 $elemId;
		catch {*deletemark elements 1;}
	}
	# assign prop to comp 
	*setvalue comps id=$compId propertyid={props $propId};
	
	::hwat::utils::BlockMessages "Off";
	*restoreviewmask "B31_View" 0;
	
	*createmark components 3 "B31_Comp"
	*createstringarray 2 "elements_on" "geometry_off"
	*showentitybymark 3 1 2
	
	::connector::log_files_write;
	
	tk_messageBox -message "Conversion is Done, Please Update \"B31 Property\" as per your Unit System...!"

}

# -------------------------------------------------------------------------------------------------
proc ::abaqus::coupKin_to_rigidBeam::convert_To_RigidBeam {COUP_KIN_elems} {
	
	set ::connector::connection_log_var  [list]
	set ::connector::connection_log_var [list [list "Converted COUP_KIN To Rigid_BEAM" "=" [llength $COUP_KIN_elems] "connector(s)"]];
	
	::hwat::utils::BlockMessages "On"
	foreach elemId $COUP_KIN_elems {
		set elem_config [hm_getvalue element id=$elemId dataname=config	];
		if {$elem_config > 100} {
			# skip elements other than 1d
			continue
		}
		*elementtype 2 1;
		*elementtype 3 1;
		*elementtype 23 1;
		*elementtype 24 1;
		*elementtype 27 1;
		*elementtype 57 1;
		*elementtype 5 4
		*createmark elements 1 $elemId;
		*elementsettypes 1;
		*elementconfigcolor 1 30;
	}
	::hwat::utils::BlockMessages "Off"
	
	::connector::log_files_write;
}                     
