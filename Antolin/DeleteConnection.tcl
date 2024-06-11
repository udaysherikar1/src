catch {namespace delete ::delete}

namespace eval ::delete {

}


proc ::delete::exec_deleteRecentConnection {} {
	
	set ans [tk_messageBox -message "Do you want to delete recently created connections ?" -type yesno];
	if {$ans == "no"} {
		return
	}
	
	#reset review
	set ::connector::reviewConnection_flag 0;
	::connector::exec_reviewRecentConnection
		
	if {[info exists ::connector::recentlyCreatedEntity]} {
		
		catch {
			eval *createmark elements 1 $::connector::recentlyCreatedEntity;
			*deletemark elements 1
		};		
	}
	
	
	if {[info exists ::connector::recentlyCreatedLCS]} {
		catch {
			eval *createmark system 1 $::connector::recentlyCreatedLCS;
			*deletemark system 1;
		};
	};
}
