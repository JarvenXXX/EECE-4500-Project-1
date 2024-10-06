proc place_inverters {numinverters numchains} {
	for {set i 0} { ${i} < [expr ${numchains}/2] } { incr i} {
		for {set y 0} { ${y} < ${numinverters} } {incr y} {
			set x [expr {2 * $y}];
			set_location_assignment LCCOMB_X[expr 54 + $i]_Y46_N$x -to "ro_puf:puf|ring_oscillator:\\group_a:${i}:OSCA|invers[${y}]";
		}
	}

	for {set i [expr ${numchains}/2] } { ${i} < ${numchains} } { incr i} {
		for {set y 0} { ${y} <  ${numinverters}} {incr y} {
			set x [expr {2 * $y}];
			set_location_assignment LCCOMB_X[expr 46 + $i]_Y45_N$x -to "ro_puf:puf|ring_oscillator:\\group_b:${i}:OSCB|invers[${y}]";
		}
	}
}

place_inverters 13 16;

#Extra Credit arrangement, placing inverters in different LABs.

#for {set i 0} { ${i} < 8 } { incr i} {
	#for {set y 0} { ${y} < 13 } {incr y} {
		#set x [expr {2 * $i}];
		#set_location_assignment LCCOMB_X[expr 54 + $y]_Y46_N$x -to "ro_puf:puf|ring_oscillator:\\group_a:${i}:OSCA|invers[${y}]";
	#}
#}

#for {set i 0 } { ${i} < 8 } { incr i} {
	#for {set y 0} { ${y} <  13} {incr y} {
		#set x [expr {2 * $i}];
		#set_location_assignment LCCOMB_X[expr 54 + $y]_Y45_N$x -to "ro_puf:puf|ring_oscillator:\\group_b:[expr 8 + ${i}]:OSCB|invers[${y}]";
	#}
#}