catch {namespace delete ::freeNode}

namespace eval ::freeNode {

}


# this funcion identify free nodes of 1D element and remove them
proc ::freeNode::removeFree1DNodes {} {

	set ans [tk_messageBox -message "Keep only \"RBE2(s)/Rigid(s)\" elements on display.  Do you want to proceed?" -type yesno];
	if {$ans == "no"} {
		return
	}
	
	::hwat::utils::BlockMessages "On"
	
	*createmark elements 1 "displayed";
	set displayed_elemIds [hm_getmark elements 1];
	
	set ::connector::connection_log_var  [list]
	set ::connector::connection_log_var [list [list "Remove free nodes from Rigids" "=" [llength $displayed_elemIds] "Rigids(s)"]];
	
	foreach elemId $displayed_elemIds {
		set elem_config [hm_getvalue element id=$elemId dataname=config	];
		if {$elem_config > 100} {
			# skip elements other than 1d
			continue
		}
		
		# check free nodes of element 
		*createmark elements 1 $elemId;
		*elementtestfree1d nodes 1 2;
		set free1DNodes [hm_getmark nodes 2];
		if {[llength $free1DNodes] == 0} {
			#no free node
			continue
		}
				
		#get all nodes of 1D element 
		set legNodes [hm_getvalue element id=$elemId dataname=nodes];
		set masterNodeId [lindex $legNodes 0];
				
		#remove free nodes from leg node list
		set updated_legNodes [lremove $legNodes "$free1DNodes $masterNodeId"];
			
		eval *createmark nodes 1 $updated_legNodes
		*rigidlinkupdate $elemId $masterNodeId 1;
		
	}
	
	::hwat::utils::BlockMessages "Off"
	::connector::log_files_write;
}

# ::freeNode::removeFree1DNodes

