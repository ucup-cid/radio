setudef flag req
set reqplud(rest) 60
bind pub f .on reqon
bind pub f !on reqon
bind pub f .off reqoff 
bind pub f !off reqoff
set path "/home/radio/mp3"

proc reqon {nick uhost hand chan arg} {
	if {$chan != "#doyik"} { return 0 }
	foreach chans [channels] {
		if {[channel get $chans req]} {
			puthelp "NOTICE $nick :Already Opened"
			return 0
		}
		channel set $chans +req
puthelp "PRIVMSG Radio :bcast %boldAutoRJ%bold On Duty!!"
putquick "PRIVMSG Radio :autodj-play"
set nicknames "AutoRJ"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set temp [open "dj" w+]; puts $temp $djnickname; close $temp
set temp [open "djnick" w+]; puts $temp $djnickname; close $temp}
}

proc reqoff {nick uhost hand chan arg} {
       	if {$chan != "#doyik"} { return 0 }
	foreach chans [channels] {
		if {![channel get $chans req]} {
			puthelp "NOTICE $nick :Already Closed"
			return 0
		}
		channel set $chans -req
set nicknames "$nick"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set temp [open "dj" w+]; puts $temp $djnickname; close $temp
set temp [open "djnick" w+]; puts $temp $djnickname; close $temp
puthelp "PRIVMSG Radio :bcast %boldAutoRJ%bold is Closed %boldRj-$djnickname%bold yang bertugas"
		putserv "PRIVMSG Radio :autodj-force"
			}
}

bind pub o -skip lewat
proc lewat {nick uhost hand arg chan} {
	putquick "privmsg Radio :autodj-next"
	putserv "privmsg Radio :bcast %bold%song%bold diSkip oleh %bold$nick ..!!%bold "
	}


   ##############################################################
set radiochans "#radio"
set scdjtrigger ".dj"
set scwishtrigger "!req"
set scgreettrigger "!pesan"
bind pub - $scdjtrigger  pub_dj
bind pub - $scwishtrigger  pub_request
bind pub - !rek pub_request
bind pub - .rek pub_request
bind pub - .req pub_request
bind pub - $scgreettrigger  pub_greet
bind pub - .pesan  pub_greet
bind nick f * djnickchange
proc setdj {nickname djnickname } {
if {$djnickname == "" } { set djnickname $nickname }
global streamip streamport streampass
putlog "shoutcast: new dj: $djnickname ($nickname)"
set temp [open "dj" w+]; puts $temp $djnickname; close $temp
set temp [open "djnick" w+]; puts $temp $nickname; close $temp
}
proc setautodj {nickname djnickname} {
set nicknames "AutoRJ"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set temp [open "dj" w+]; puts $temp $djnickname; close $temp
set temp [open "djnick" w+]; puts $temp $nicknames; close $temp}
proc request { nick arg } {
 global reqplud
if {$arg == ""} { putserv "privmsg Radio :bcast $nick Ketik !req <Artis - Judul Lagu>"; return 0}
set temp [open "djnick" r]; set djnick [gets $temp]; close $temp
if {$djnick == "AutoRJ"} {
if {[info exists reqplud(protection)]} {
set rest [expr [clock seconds] - $reqplud(protection)]
if {$rest < $reqplud(rest)} {
puthelp "privmsg Radio :bcast %bold$nick%bold: Wait [expr $reqplud(rest) - $rest] Second(s) For Request."
return 0
}
catch { unset rest }
}
set reqplud(protection) [clock seconds]
pub_get $nick $arg
} else {
putserv "privmsg Radio :raw privmsg $djnick :( Request dari $nick ) - $arg"
puthelp "NOTICE $nick :Request sent.."}
}

proc pub_get {nick arg} {
global radiochans reqplud path
set asu [lrange $arg 0 end]
catch {exec youtube-dl --default-search ytsearch --skip-download --no-warnings --get-id --get-duration --restrict-filenames --get-filename -o "%(title)s" "$asu"} report
foreach {id namafile durasi} [split $report "\n"] {
set jadul [string map {{_} { }} $namafile]; set jembod "https://youtu.be/$id"}
regsub -all -- "\[^A-Za-z0-9'&-\]" $jadul " " jadul1
regsub -all {\s+} $jadul1 " " jadul2
regsub {^\s+} $jadul2 "" jadul3
regsub {\s+$} $jadul3 "" ooo
set ::waloh $nick; set ::jadule $jadul
putquick "NOTICE $nick :Downloading $jadul"
putserv "privmsg Radio :autodj-reload"
if {[file exists "$path/$ooo.mp3"]} { utimer 3 [list puthelp "privmsg Radio :request $ooo.mp3"] ; return 0}
catch {exec youtube-dl --prefer-ffmpeg --restrict-filenames --ignore-config --no-cache-dir --no-resize-buffer --no-playlist --no-mtime --abort-on-error --no-color --no-mark-watched --no-call-home --no-warnings --youtube-skip-dash-manifest -w -x --audio-format mp3 --audio-quality 5 -o "$path/$ooo.%(ext)s" "$jembod"} runcmd
if {[string match *error* [string tolower $runcmd]]} { puthelp "NOTICE $nick :\00304ERROR.."; return 0 }
if {[string match *max-filesize* [string tolower $runcmd]]} { puthelp "NOTICE $nick :\00304ERROR.. \00305Durasi: \002$durasi\002 \00307(max durasi 25menit)\017"; exec rm -f "$path/$ooo.webm.part"; exec rm -f "$path/$ooo.m4a.part"; return 0 }
utimer 3 [list puthelp "privmsg Radio :request $ooo.mp3"]}
proc pub_request { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { request $nick $arg }}
proc scgreet { nick arg } {
if {$arg == ""} { putserv "Privmsg Radio :bcast %bold$nick%bold Ketik !pesan <pesan anda>"; return 0}
global dj 
set temp [open "djnick" r]; set djnick [gets $temp]; close $temp
if {$djnick == "AutoRJ"} { return 0 }
putserv "privmsg Radio :raw privmsg $djnick :( Pesan dari $nick ) - $arg"
puthelp "NOTICE $nick :pesan sent.."}
proc pub_greet { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreet $nick $arg }}
bind msg - Thank repor
proc repor {nick uhost hand rest} {
if {$nick != "Radio"} { return 0 }
if {[string match "0" [lindex $rest 15]]} {
puthelp "NOTICE $::waloh : \002$::jadule\002 akan diputar setelah lagu berikut"
} else {
puthelp "NOTICE $::waloh : \002$::jadule\002 akan diputar setelah \00304\002[lindex $rest 15]\002\017 lagu lagi"}
unset ::waloh; unset ::jadule
}
proc msg_setdj { nick uhost hand arg } { global radiochans; setdj $nick $arg }
proc pub_setdj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { setdj $nick $arg }}
proc msg_setautodj { nick uhost hand arg } { global radiochans; setautodj $nick $arg }
proc pub_setautodj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { setautodj $nick $arg }}
proc djnickchange { oldnick uhost hand chan newnick } {
set temp [open "djnick" r]; set djnick [gets $temp]; close $temp
if {$oldnick == $djnick} {
putlog "shoutcast: dj nickchange $oldnick -> $newnick"
set temp [open "djnick" w+]; puts $temp $newnick; close $temp}
}
proc dj { nick } {
set target "$nick"
putlog "shoutcast: $target asked for dj info"
if {[file exists dj]} {
set temp [open "dj" r]; set dj [gets $temp]; close $temp
putserv "Privmsg Radio :bcast %bold$dj%bold On yang bertugas!!!"
}}
proc pub_dj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { dj $nick  }}

putlog "radio.tcl loaded"
