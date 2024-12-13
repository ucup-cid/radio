set br "/home/abocy/lagu"

bind pub - .find tom
bind pub - !find tom
bind pub - !del apus
bind pub - .del apus

proc tom {nick uhost hand chan arg} {
	global br
	if {$chan != "#abocyFM"} { return 0 }
	if {[lindex $arg 0] == ""} { puthelp "NOTICE $nick :ketik .find <target>" ;return 0 }
	set files ""
	foreach f [glob -directory $br -type f *] {
		if {[string match -nocase "*$arg*" $f]} {
			lappend files [file tail $f] 
		}
	}
         foreach si [file join $files] {
        if {[string  match -nocase "*$arg*" $si]} {
	set ukuran [file size "$br/$si"]
	set size [fixform $ukuran]
         putserv "privmsg $chan :$si  \002\[\002$size\002\]\002"
      } else {
		putserv "privmsg $chan :zonk"
      }
   }
}

proc apus {nick uhost hand chan arg} {
	global br
	if {$chan != "#abocyFM"} { return 0 }
	if {[lindex $arg 0] == ""} { puthelp "NOTICE $nick :ketik .del <target>" ;return 0 }
        foreach files [glob -directory $br -type f *] {
	if {[string match -nocase "*$arg*" $files]} {
		exec rm -f $files
	} else {
       if {[file exists $br/$arg] == 1} {
           exec rm -f $br/$arg
      puthelp "privmsg $chan :$arg dihapus"
        }
     }
   }
}

proc fixform n {
	if {wide($n) < 1000} {return $n}
	foreach unit {KB MB GB TB P E} {
		set n [expr {$n/1024.}]
		if {$n < 1000} {
			set n [string range $n 0 3]
			regexp {(.+)\.$} $n -> n
			set size "$n $unit"
			return $size
		}
	}
	return Inf
}

putlog "file remover by TOMJERRX loaded"