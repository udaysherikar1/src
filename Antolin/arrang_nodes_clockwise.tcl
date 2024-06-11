if {[namespace exists ::arrange::nodes]} {
	namespace delete ::arrange::nodes
}
namespace eval ::arrange::nodes {

	set ::arrange::nodes::scriptDir [file dirname [info script]];

}

proc ::arrange::nodes::calculateCentroid {nodeList} {
    set numnodeList [llength $nodeList]
    set x_sum 0
    set y_sum 0
    set z_sum 0
	
	for {set i 0} {$i < [llength $nodeList]} {incr i} {
		set point [lindex $nodeList $i];

		set x_sum [expr $x_sum + [lindex $point 0]];
		set y_sum [expr $x_sum + [lindex $point 1]];
		set z_sum [expr $x_sum + [lindex $point 2]];
		
	}
	
    set centroid [list [expr {$x_sum / $numnodeList}] [expr {$y_sum / $numnodeList}] [expr {$z_sum / $numnodeList}]]
    return $centroid
}

proc ::arrange::nodes::calculateAngle {point centroid} {
    lassign $point x y z
    lassign $centroid cx cy cz
    set dx [expr {$x - $cx}]
    set dy [expr {$y - $cy}]
    set dz [expr {$z - $cz}]
    return [expr {atan2($dy, $dx)}]
}

proc ::arrange::nodes::arrangeClockwise {nodeList} {
	
	set lst_cordi [::arrange::nodes::get_node_cordinates $nodeList];
	#puts "lst_cordi -- $lst_cordi"
    set centroid [::arrange::nodes::calculateCentroid $lst_cordi]
	#puts "centroid -- $centroid"
    set angles {}
    foreach point $nodeList cordi $lst_cordi {
        lappend angles [list $point [::arrange::nodes::calculateAngle $cordi $centroid]]
    }
    set sortednodeList [lsort -index 1 -real $angles];
    set result ""
	foreach var $sortednodeList {
		set point [lindex $var 0]
		lappend result $point
	}
	return [lreverse $result] ;   # Reverse the order to make it clockwise
}


proc ::arrange::nodes::get_node_cordinates {nodeList} {
	
	set cordi ""
	foreach id $nodeList {
		set x1 [hm_getvalue node id=$id dataname=x];
		set y1 [hm_getvalue node id=$id dataname=y];
		set z1 [hm_getvalue node id=$id dataname=z];
		lappend cordi "$x1 $y1 $z1"
	}
	return $cordi
}

#set nodeList [list "1017" "1013" "1020"];
#set clockwise_nodeList [::arrange::nodes::arrangeClockwise $nodeList]
#puts "nodeList in clockwise order: $clockwise_nodeList"










