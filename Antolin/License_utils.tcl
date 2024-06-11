# %  procomp C:\\WorkingDir\\WIP\\License_utility\\*.tcl

package require http

catch {namespace delete ::antolin::license}

namespace eval ::antolin::license {

}

# --------------------------------------------------------------------------------------------------
#  Internet connectivity check
# --------------------------------------------------------------------------------------------------
proc ::antolin::license::checkInternetConnectivity {} {
    set url "http://www.google.com"
	set internet_status [catch {set response [http::geturl $url]} internet_error]
	
	if {$internet_status == 1} {
		return 1
	}    
    http::cleanup $response	
	return 0
}

proc ::antolin::license::GetUnixTimeStamp {} {

	set internet_status [::antolin::license::checkInternetConnectivity];
	if {$internet_status == 1} {
		return 0
	}
	
	set time_url "http://worldtimeapi.org/api/ip"
	set response [http::geturl $time_url]
	set data [http::data $response];
	#set curret_date [string range $data [expr 259+15] [expr 259+24]];
	set curret_date [string range $data [expr [string first "utc_datetime" $data]+15] [expr [string first "utc_datetime" $data]+24]];
	set unix_time [clock scan $curret_date];
	
	return $unix_time
}
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# decode validity.txt and compare with server time
# --------------------------------------------------------------------------------------------------
proc ::antolin::license::readFile {filePath} {
	set fp [open $filePath r]
	set file_data [read $fp]
	close $fp
	
	return $file_data
}

proc ::antolin::license::to_ascii {char} {
 	set value 0
	scan $char %c value
	return $value				
}

proc ::antolin::license::encode {str} {
								
	set enc_string "password"
	set enc_idx 0
	set crypt_str ""
	for {set i 0} {$i < [string length $str]} {incr i 1} {

		set curnum [expr {[to_ascii [string index $str $i]] + [::antolin::license::to_ascii [string index $enc_string $enc_idx]]}]
			
		if {$curnum > 255} {
			set curnum [expr {$curnum - 256}]
		}
			
		set crypt_char [format %c $curnum]
		set crypt_str "$crypt_str$crypt_char"
		set enc_idx [incr enc_idx 1]
		if {$enc_idx == [string length $enc_string]} {
			set enc_idx 0
		}
	}
		
	return $crypt_str			
}

proc ::antolin::license::decode {str} {
		
	set enc_string "password"
	set enc_idx 0
	set crypt_str ""
	set strlen [string length $str]
	if {$strlen == 0} {return}
	for {set testx 0} {$testx < $strlen} {incr testx 1} {
		set curnum [expr {[to_ascii [string index $str $testx]]-[::antolin::license::to_ascii [string index $enc_string $enc_idx]]}]
		
		if {$curnum < 0} {
			set curnum [expr {$curnum + 256}]
		}
		set crypt_str "$crypt_str[format %c $curnum]"
		set enc_idx [incr enc_idx 1]
		if {$enc_idx == [string length $enc_string]} {
			set enc_idx 0
		}
	}
	return $crypt_str
}
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# main function calling internet connectivity and validity
# --------------------------------------------------------------------------------------------------

proc ::antolin::license::checkPAValidity {filePath}  {
	
	set curtime [::antolin::license::GetUnixTimeStamp];
	if {$curtime <= 0} {
		#no internet
		return 2
	}
	
	set str [::antolin::license::readFile $filePath];
	set validity_time [::antolin::license::decode $str];
	
	# if {![string is double -strict $validity_time]} {
		# #if user manually try to edit the time text file
		# puts 0000
		# return 1	
	# }

	if { $curtime < $validity_time } {
		#pass 
		return 0
	} else {
		#fail
		return 1
	}
}


# set filePath {C:\WorkingDir\WIP\License_utility\validity_20sept.txt}
# set filePath {C:\WorkingDir\WIP\License_utility\validity.txt}
# set ret [::antolin::license::checkPAValidity $filePath];
# if {$ret == 0} {
	# puts "#call function to launch tool "	
# } elseif {$ret == 1} {
	# tk_messageBox -message "Automation validity is over. Kindly contact 'Antolin Design and Business Services Pvt Ltd'" -icon error;
	# return
# } else {
	# tk_messageBox -message "Kindly check your internet connection and try again" -icon error;
	# return
# }

