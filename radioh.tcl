package require json
package require http
package require tls
package require tdom
#set key "AIzaSyAvCZv9QY9KzbgUsFhdnT71MqNZ1dQ86Pc"
#set key "AIzaSyBlnL8h7FnukIEj9_QLtunU6x2AIO0H9vQ"
#set key "AIzaSyDlm0jcPyZ0V25-3a51RX4b6gz5tx9bfhQ"
set apis "1"
setudef flag req
set [decrypt 64 "cnQVD1r//Rq..Pp9g0vorLM0"] 100
bind pub f !on [decrypt 64 "BgjpS/vBJUK1"]
bind pub o .on [decrypt 64 "FwZNb16gXaa1"]
bind pub f !radio [decrypt 64 "xiYPx.uxTMI1"]
bind pub f !cmd [decrypt 64 "bzR15.swiXu/"]
bind pub f !off [decrypt 64 "5UMMZ0ODEXx0"]
bind pub f !in [decrypt 64 "RORAW/97MMG/"]
bind pub f !out [decrypt 64 "dZiKe0BSaiq0gKeyI/n05Ky/"]
bind pub o .next [decrypt 64 "DiwrH.KL8GL."]
bind pub f .ceklis pub_ceklist
bind pub m !kill killing
bind pub -|- .stream [decrypt base64 "c3RyZWFt"]
bind pub -|- .song [decrypt 64 "ORdwj/ms0T5/"]
bind pub -|- .rj [decrypt 64 "0nCbQ0AID5//6bFEt.vzuwM0"]
bind pubm - "*.stream" [decrypt 64 "r2FMm.Q2WGN.2fARM0e6CF30"]
bind pubm - "*!stream" [decrypt 64 "r2FMm.Q2WGN.2fARM0e6CF30"]
bind pubm - "*.song" [decrypt 64 "xTBbF1ejzyv1EBLLt1zFhhK0"]
bind pubm - "*!song" [decrypt 64 "xTBbF1ejzyv1EBLLt1zFhhK0"]
bind pubm - "*!lis" [decrypt 64 "xTBbF1ejzyv1EBLLt1zFhhK0"]
bind pubm - "*!dj" [decrypt 64 "gHk6T/09cue/23Nra0kQr5u0"]
bind pubm - "*!rj" [decrypt 64 "gHk6T/09cue/23Nra0kQr5u0"]
bind pubm - "*.dj" [decrypt 64 "gHk6T/09cue/23Nra0kQr5u0"]
bind pubm - "*.rj" [decrypt 64 "gHk6T/09cue/23Nra0kQr5u0"]
bind pubm - "*!req*" [decrypt 64 "GcgTn0mPXae/9pI6m1rWNB21"]
bind pubm - "*.req*" [decrypt 64 "GcgTn0mPXae/9pI6m1rWNB21"]
bind pubm - "*!rek*" [decrypt 64 "GcgTn0mPXae/9pI6m1rWNB21"]
bind pubm - "*.pesan*" [decrypt 64 "JPjHX1x7MYt0JBkep1uW8yN."]
bind pubm - "*!pesan*" [decrypt 64 "JPjHX1x7MYt0JBkep1uW8yN."]
bind pub f !greet [decrypt base64 "Z3JldGluZw=="]
set [decrypt 64 "gO.9p/Esvcz0"] "/home/abocy/lagu"
set [decrypt 64 "8qSH9.wwuLw."] "count"
set streamip "127.0.0.1" 
set streamport "8000"
set streampass "2019"
set adminpass "abocyradio0"

set [decrypt 64 "XCReW/24cq7/uckaW/VPX/9."] {
"Current song requested by%color1%bold"
"Current song requested by%color3%bold"
"Current song requested by%color4%bold"
"Current song requested by%color5%bold"
"Current song requested by%color6%bold"
"Current song requested by%color7%bold"
"Current song requested by%color9%bold"
"Current song requested by%color10%bold"
"Current song requested by%color12%bold"
"Current song requested by%color13%bold"
"Current song requested by%color14%bold"
}

bind msg o .lock kunci
proc kunci {nick uhost hand rest} {

if {[lindex $rest 0] == ""} { 
putserv "NOTICE $nick : ERROR"
} else {
set kunc [lindex $rest 0]
set x [open "kunci" w+] ; puts $x $kunc ; close $x
puthelp "NOTICE $nick :$kunc terkunci"
}}

bind msg o .unlock nokunci
proc nokunci {nick uhost hand rest} {

set iyo "AbocyFM"
set nokunc $iyo
set x [open "kunci" w+] ; puts $x $nokunc ; close $x
puthelp "NOTICE $nick :Kunci dibuka"
}

if {![file exists $::limit]} {
putlog "$::limit file doesnt exists, creating file..."
set [decrypt 64 "dmqn5/bkSbl1"] [open $::limit w]
puts $pile "0"
close $pile
}
if {![file exists webreq]} {
putlog "webreq file doesnt exists, creating file..."
exec touch webreq
}
proc status { } { 
   global streamip streamport streampass 
   if {[catch {set sock [socket $streamip $streamport] } sockerror]} { 
      putlog "error: $sockerror" 
      return 0 } else { 
      puts $sock "GET /admin.cgi?sid=1&pass=$streampass&mode=viewxml&page=1 HTTP/1.1" 
      puts $sock "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0" 
      puts $sock "Host: $streamip" 
      puts $sock "Connection: close" 
      puts $sock "" 
      flush $sock 
      while {[eof $sock] != 1} { 
         set bl [read $sock] 
         if { [string first "standalone" $bl] != -1 } { 
	    set mx ""
	    regexp -nocase {<STREAMSTATUS>(.*?)</STREAMSTATUS>} $bl match mx
	    set mx [regsub -all -nocase {\s+} $mx " "]
            set streamstatus $mx
	}
      } 
      close $sock 
   } 
   if {[info exists streamstatus]} { 
      if { $streamstatus == "1" } { return 1 } else { return 0 } 
   } else { return 0 } 
}
proc pub_ceklist { nick uhost hand chan arg } { 
   global streamip streamport adminpass
   if {$chan != "#abocyFM"} { return 0 }
   if {[catch {set sock [socket $streamip $streamport] } sockerror]} { 
      putlog "error: $sockerror" 
      return 0 } else { 
      puts $sock "GET /admin.cgi?sid=1&pass=$adminpass&mode=viewxml&page=3 HTTP/1.1" 
      puts $sock "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0" 
      puts $sock "Host: $streamip" 
      puts $sock "Connection: close" 
      puts $sock "" 
      flush $sock 
      while {[eof $sock] != 1} { 
         set bl [gets $sock] 
	 set xy [open "hee.xml" w+] ; puts $xy $bl ; close $xy
      } 
      close $sock 
	set f [open "hee.xml" r]; set doc [dom parse [read $f]]; close $f
	set root [$doc documentElement]
	set mess [$root selectNodes "/SHOUTCASTSERVER/LISTENERS/LISTENER"]

	foreach elem $mess {
	  set host [[$elem selectNodes HOSTNAME] text]
	  set userag [[$elem selectNodes USERAGENT] text]
	  set time [[$elem selectNodes CONNECTTIME] text]
	  set hours [expr {int($time) / 3600}]; set mins  [expr {int($time) / 60 % 60}]; set secs  [expr {int($time) % 60}]
	  set bf [open "djnick" r]; set djnick [gets $bf]; close $bf
	if {[matchattr $nick m]} { putserv "notice $nick :1IP 5\[12$host5\]1 Stream With 5\[3$userag5\]1 Stream Durasi 5\[6[format "%02d:%02d:%02d" $hours $mins $secs]5\]"; exec rm -f hee.xml
	} elseif {$djnick == $nick} { 
	  putserv "notice $nick :1IP 5\[12$host5\]1 Stream With 5\[3$userag5\]1 Stream Durasi 5\[6[format "%02d:%02d:%02d" $hours $mins $secs]5\]"
	  exec rm -f hee.xml
	} else { 
	  putserv "notice $nick :Hanya Owner/Master dan RJ Yang Bertugas Yang bisa Cek IP Listeners"
	  exec rm -f hee.xml
       }
     }
  } 
}

proc killing {nick uhost hand chan arg} {
   global streamip streamport adminpass
   if {$chan != "#abocyFM"} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[catch {set sock [socket $streamip $streamport] } sockerror]} { 
      putlog "error: $sockerror" 
      return 0 } else { 
      puts $sock "GET /admin.cgi?sid=1&pass=$adminpass&mode=kicksrc HTTP/1.1" 
      puts $sock "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0" 
      puts $sock "Host: $streamip" 
      puts $sock "Connection: close" 
      puts $sock "" 
      flush $sock 
      close $sock 
	puthelp "NOTICE $nick :12Killing DJ..."
     } 
}
proc [decrypt 64 "BgjpS/vBJUK1"] {nick uhost hand chan arg} {
	global reqplud
	if {$chan != "#abocyFM"} { return 0 }
	set temp [open "dj" r]
	set asu [gets $temp]
	close $temp
	foreach chans [channels] {
		if {[channel get $chans req]} {
			puthelp "privmsg AbocyFM :raw NOTICE $nick :Already Opened"
			return 0
		}
	if {$asu != $nick} { putserv "privmsg AbocyFM :raw NOTICE $nick :Maaf, sedang ada Rj yang OnAir..!!!"; return 0}
		channel set $chans +req
puthelp "PRIVMSG AbocyFM :bcast %color2AutoRJ %bold%color3ON%bold"
putquick "PRIVMSG AbocyFM :autodj-play"
putserv "NOTICE $nick :\[AutoRJ ON\]"
set nicknames "AutoRJ"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" w+]
puts $temp $djnickname
close $temp
catch { unset reqplud(protection) }
	}
}
proc [decrypt 64 "FwZNb16gXaa1"] {nick uhost hand chan arg} {
	global reqplud
	if {$chan != "#abocyFM"} { return 0 }
	foreach chans [channels] {
		if {[channel get $chans req]} {
			puthelp "privmsg AbocyFM :raw NOTICE $nick :Already Opened"
			return 0
		}
		channel set $chans +req
puthelp "PRIVMSG AbocyFM :bcast %color2AutoRJ %bold%color3ON%bold"
putquick "PRIVMSG AbocyFM :autodj-play"
putserv "NOTICE $nick :\[AutoRJ ON\]"
set nicknames "AutoRJ"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
exec rm -f webreq; exec touch webreq
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" w+]
puts $temp $djnickname
close $temp
catch { unset reqplud(protection) }
	}
}
bind pubm - "*DJ:*" autotaken
proc autotaken {nick uhost hand chan arg} {
  global botnick
  if {$chan != "#abocy"} { return 0 }
  if {$nick == "AbocyFM"} {
  if {[string match -nocase "03AbocyFM11]" [lindex $arg 4]]} {
	foreach chans [channels] {
		if {[channel get $chans req]} { return 0 }
		channel set $chans +req
#puthelp "PRIVMSG AbocyFM :bcast %color2AutoRJ %bold%color3ON%bold"
set nicknames "AutoRJ"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
exec rm -f webreq; exec touch webreq
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" w+]
puts $temp $djnickname
close $temp
catch { unset reqplud(protection) }
	}
     }
  }
}
proc [decrypt 64 "5UMMZ0ODEXx0"] {nick uhost hand chan arg} {
       	if {$chan != "#abocyFM"} { return 0 }
	set temp [open "kunci" r] ; set lock [gets $temp] ; close $temp
	if {$nick == $lock} { putserv "privmsg AbocyFM :raw NOTICE $nick :Maaf, Anda kena banned AutoRJ karena berkali2 Disconnect, Tunggu 30menit ..!!!"; return 0}
	foreach chans [channels] {
		if {![channel get $chans req]} {
			puthelp "privmsg AbocyFM :raw NOTICE $nick :Already Closed"
			return 0
		}
		channel set $chans -req
set nicknames "$nick"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $djnickname
close $temp
set req "AbocyFM"
set djreq $req
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" w+]
puts $temp $djreq
close $temp
putserv "PRIVMSG AbocyFM :bcast %bold%color4AutoRJ%bold %color12diambil alih %bold%color3Rj-$djnickname%bold"
		putquick "PRIVMSG AbocyFM :autodj-force"
		puthelp "NOTICE $nick :\[AutoRJ OFF\] 4- Segera Sambungkan APP anda -"
			}
}
proc [decrypt 64 "RORAW/97MMG/"] {nick uhost hand chan arg} {
       	if {$chan != "#abocyFM"} { return 0 }
	foreach chans [channels] {
	set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" r]
	set dj [gets $temp]
	close $temp
	if {$dj == "AutoRJ"} { return 0 }
	if {$dj != $nick } { return 0 }
set nicknames "$nick"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" w+]
puts $temp $djnickname
close $temp
puthelp "NOTICE $nick :Request ON"
putquick "PRIVMSG AbocyFM :!reqlogin"
puthelp "PRIVMSG AbocyFM :bcast %boldRj-$djnickname%bold %color3Live DJ and Open Request Now.."
	}
}
proc [decrypt 64 "dZiKe0BSaiq0gKeyI/n05Ky/"] {nick uhost hand chan arg} {
       	if {$chan != "#abocyFM"} { return 0 }
	foreach chans [channels] {
	set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" r]
	set dj [gets $temp]
	close $temp
	if {$dj == "AutoRJ"} { return 0 }
	if {$dj != $nick } { return 0 }
	if {$dj == "AbocyFM"} { puthelp "privmsg AbocyFM :raw NOTICE $nick :Request already Closed"; return 0 }
set nicknames "AbocyFM"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" w+]
puts $temp $djnickname
close $temp
putquick "PRIVMSG AbocyFM :!reqlogout"
puthelp "NOTICE $nick :Request OFF"
puthelp "PRIVMSG AbocyFM :bcast %color4DJ Close Request Now..."		}
}
proc [decrypt 64 "xiYPx.uxTMI1"] {nick uhost hand chan arg} {
       	if {$chan != "#abocyFM"} { return 0 }
	foreach chans [channels] {
			puthelp "NOTICE $nick :Host     : abocy.my.id"
			puthelp "NOTICE $nick :Pass     : 2019"
			puthelp "NOTICE $nick :Port     : 8000"
			puthelp "NOTICE $nick :StreamID : 1"
			puthelp "NOTICE $nick :Bitrate  : 24/32kbps"
			puthelp "NOTICE $nick :ketik !cmd untuk command bot"
			return 0
		}
}
proc [decrypt 64 "bzR15.swiXu/"] {nick uhost hand chan arg} {
       	if {$chan != "#abocyFM"} { return 0 }
	foreach chans [channels] {
			puthelp "NOTICE $nick :!off     : mematikan AutoRJ"
			puthelp "NOTICE $nick :!in      : Buka/Open Request"
			puthelp "NOTICE $nick :!out     : Tutup/Close Request"
			puthelp "NOTICE $nick :!on      : Menghidupkan AutoRJ"
		if {[matchattr $nick m]} {
			puthelp "NOTICE $nick :.ceklist : Untuk melihat ip/app/durasi Listener"
			puthelp "NOTICE $nick :!kill	 : Mengkill Rj Yang sedang OnaiR dengan paksa"
			puthelp "NOTICE $nick :.next	 : Menyekip Lagu Yang sedang Play"
			}
			return 0
		}
}
proc [decrypt 64 "DiwrH.KL8GL."] {nick uhost hand arg chan} {
	putquick "privmsg AbocyFM :autodj-next"
	#putserv "privmsg AbocyFM :bcast %song dinext oleh %bold$nick%bold ..!! "
	putserv "NOTICE $nick :\002$nick:\002 Lagu telah dinext...!!"
	}
proc [decrypt base64 "c3RyZWFt"] {nick uhost hand arg chan} {
	putserv "privmsg AbocyFM :bcast %color1Streaming  %color4»» %color12http://abocy.my.id:8000/listen.pls %color4««  %color1via|web  %color4»» %color12http://abocy.my.id %color4««"
	}
proc [decrypt 64 "ORdwj/ms0T5/"] {nick uhost hand arg chan} {
	putserv "privmsg AbocyFM :bcast Playing Song %color12%bold%song%bold "
	}
proc [decrypt 64 "0nCbQ0AID5//6bFEt.vzuwM0"] {nick uhost hand arg chan} {
	putserv "privmsg AbocyFM :bcast %bold%dj%bold Yang lagi Onair "
	}
proc [decrypt 64 "oaZHS0GDtOH/HH/.q1mMkh50"] { nick arg } {
global radiochans
if {$nick != "ehsan"} { return 0 }
if {[string match ".stream" [lindex $arg 1]]} { putserv "privmsg AbocyFM :bcast %color1Streaming  %color4»» %color12http://abocy.my.id:8000/listen.pls %color4««  %color1via|web  %color4»» %color12http://abocy.my.id %color4««"; return 0}
if {[string match "!stream" [lindex $arg 1]]} { putserv "privmsg AbocyFM :bcast %color1Streaming  %color4»» %color12http://abocy.my.id:8000/listen.pls %color4««  %color1via|web  %color4»» %color12http://abocy.my.id %color4««"; return 0}
}
proc [decrypt 64 "r2FMm.Q2WGN.2fARM0e6CF30"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { streaming $nick $arg }}
proc [decrypt 64 "/8.KM1bLd2v0"] { nick arg } {
global radiochans
if {$nick != "ehsan"} { return 0 }
if {[string match ".song" [lindex $arg 1]]} { putserv "privmsg AbocyFM :bcast Playing Song %color12%bold%song%bold"; return 0}
if {[string match "!song" [lindex $arg 1]]} { putserv "privmsg AbocyFM :bcast Playing Song %color12%bold%song%bold"; return 0}
if {[string match "!lis" [lindex $arg 1]]} { putserv "privmsg AbocyFM :bcast Jumlah Pendengar: %color4%bold%clients%bold"; return 0}
}
proc [decrypt 64 "xTBbF1ejzyv1EBLLt1zFhhK0"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { lagus $nick $arg }}
proc [decrypt 64 "rgyJI0HkE3G0"] { nick arg } {
global radiochans
if {$nick != "ehsan"} { return 0 }
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" r]
set djf [gets $temp]
close $temp
if {[string match "!rj" [lindex $arg 1]]} { putserv "Privmsg AbocyFM :bcast %bold%dj%bold Yang lagi Onair"; return 0}
if {[string match ".rj" [lindex $arg 1]]} { putserv "Privmsg AbocyFM :bcast %bold%dj%bold Yang lagi Onair"; return 0}
if {$djf == "AutoRJ"} { putserv "Privmsg AbocyFM :bcast %boldAutoRJ%bold Yang lagi Onair"; return 0}
if {[string match "!dj" [lindex $arg 1]]} { putserv "Privmsg AbocyFM :bcast %bold$djf%bold Yang lagi Onair"; return 0}
if {[string match ".dj" [lindex $arg 1]]} { putserv "Privmsg AbocyFM :bcast %bold$djf%bold Yang lagi Onair"; return 0}
}
proc [decrypt 64 "gHk6T/09cue/23Nra0kQr5u0"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { siaran $nick $arg }}
set [decrypt 64 "yS/XW.rUdLj0e8e8p0CDRiY0"] "#abocy"
set [decrypt 64 "ZiK111SmlsS1AWg/B1a4OaV/"] ".dj"
set [decrypt 64 "ZiK111SmlsS16cgzn1zPpT20"] "!dj"
set [decrypt 64 "/FB4W1nnNWS1"] ".req"
set [decrypt 64 "EHZPo1v6p1Z/"] "!req"
set [decrypt 64 "EHZPo1v6p1Z/ci7fS0GEaP40"] "!rek"
set [decrypt 64 "HBV0c0KYzZY.lVLR21W8smF."] ".pesan"
set [decrypt 64 "HBV0c0KYzZY.TchSp0s0mgJ0"] "!pesan"
bind pub - $scdjtrigger [decrypt 64 "KrQEH/IoJrN/"]
bind pub - $scdjtriggers [decrypt 64 "KrQEH/IoJrN/"]
bind pub - $rekwish [decrypt 64 "XLoox/A8IQt1uckaW/VPX/9."]
bind pub - $rekwishs [decrypt 64 "XLoox/A8IQt1uckaW/VPX/9."]
bind pub - $rekwishss [decrypt 64 "XLoox/A8IQt1uckaW/VPX/9."]
bind pub - $scgreettrigger [decrypt 64 "eb3gv/bYBdp.gKeyI/n05Ky/"]
bind pub - $scgreettriggers [decrypt 64 "eb3gv/bYBdp.gKeyI/n05Ky/"]
bind nick - * djnickchange
proc [decrypt 64 "NlrD8/ZJ1mD/"] {nickname djnickname } {
if {$djnickname == "" } { set djnickname $nickname }
global streamip streamport streampass
putlog "shoutcast: new dj: $djnickname ($nickname)"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $nickname
close $temp
}
proc [decrypt 64 "aH1Al1DpikD0FusI0/AogVP/"] {nickname djnickname} {
set nicknames "AutoRJ"
set djnickname $nicknames
putlog "shoutcast: new dj: $djnickname ($nicknames)"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" w+]
puts $temp $djnickname
close $temp
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $nicknames
close $temp
}
proc [decrypt 64 "ERV58/swD7K0"] { nick arg } {
 global reqplud
if {$arg == ""} { putquick "privmsg AbocyFM :raw NOTICE $nick :Ketik !req <Artist - Judul> atau .req"; catch { unset reqplud(protection) }; return 0}
if { [status] == "1" } {
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {$djnick == "AbocyFM"} { puthelp "privmsg AbocyFM :bcast %bold$nick:%bold %color4Sorry, Dj Close Request,..."; puthelp "NOTICE $nick :4Sorry, Dj Close Request,..."; return 0 }
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {$djnick == "AutoRJ"} {
        pub_get $nick $arg
    } else {
        putserv "privmsg $djnick :(6Request dari $nick )12  $arg"
	puthelp "privmsg AbocyFM :raw NOTICE $nick :Request Sent..."
    }
  } else {
	puthelp "privmsg AbocyFM :raw NOTICE $nick :sorry radio is currently offline"
    }
}
proc [decrypt 64 "CxF0t.qIL/b0"] {nick arg} {
global radiochans reqplud path durasi jadul yturl apis id key cekjudul
set [decrypt 64 "15L/00.xYXh1"] [open "count" r]; set [decrypt 64 "sC/l31f2zqJ1"] [gets $file1]; close $file1
if {$angka == "6"} { putserv "privmsg AbocyFM :raw NOTICE $nick :max 6, Tunggu lagu berikut selesai diputar..."; catch { unset reqplud(protection) }; return 0}
	if {[info exists reqplud(protection)]} {
		set rest [expr [clock seconds] - $reqplud(protection)]
		if {$rest < $reqplud(rest)} {
		    if {[matchattr $nick m]} {
			exec echo "$nick $arg|web" >> webreq
		    } else {
			puthelp "privmsg AbocyFM :raw NOTICE $nick : ï¿½ï¿½ Tunggu Req sebelumnya selesai Diproses, Baru Req lagi... ï¿½ï¿½"
			}
			return 0
		}
		catch { unset rest }
	}
	set reqplud(protection) [clock seconds]
set o [open webreq r] ; set wr [gets $o] ; close $o
if {($wr != "") && ($wr == "$nick $arg|web")} { exec sed -i "1d" webreq }
if {($wr != "") && ($wr == "$nick $arg|app")} { exec sed -i "1d" webreq }
if {[string match "*kontol*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*crot*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*vagina*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*desah*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*jembut*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*JEMBUT*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*DESAH*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*crut*" [lrange $arg 0 end]]} {
catch { unset reqplud(protection) }
} elseif {[string match "*/ensembles" [lindex $arg 0]]} {
catch { unset reqplud(protection) }
} elseif {[string match "https://www.smule.com/*/*" [lindex $arg 0]] || [string match "https://www.smule.com/recording/*/*" [lindex $arg 0]] || [string match "https://link.smule.com/*" [lindex $arg 0]]} {
smuleng $nick $arg
} elseif {[string match "*/performance/*" [lindex $arg 0]]} {
if {[lindex $arg 0] == "" } { puthelp "privmsg AbocyFM :raw NOTICE $nick :ketik !req/.req <link file> <judulfile>"; catch { unset reqplud(protection) }; return 0 }
if {[lindex $arg 1] == "" } { puthelp "privmsg AbocyFM :raw NOTICE $nick :ketik !req/.req <link file> <judulfile>"; catch { unset reqplud(protection) }; return 0 }
set jemb [lindex $arg 0]
set itil [lrange $arg 1 end]
regsub -all " " $itil "_" judul
regsub -all " " $itil " " title

set [decrypt 64 "uo52l.UD3ya."] [open "count" w]
puts $file2 [expr $angka + 1]
set [decrypt 64 "sC/l31f2zqJ1"] [expr $angka + 1]
close $file2

putquick "privmsg AbocyFM :bcast %bold$nick:%bold Request Smule $title diproses...."
puthelp "privmsg AbocyFM :autodj-reload"
catch {exec ffmpeg -y -loglevel repeat+info -i $jemb -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$title $path/$judul.mp3} link
set f [open "a.txt" a+]
puts $f $link
close $f
set fp [open "a.txt" r]
while { [gets $fp line] >= 0 } {
    if {[string match *error* $line]} {
        puthelp "NOTICE $nick :4$line"
	catch { unset reqplud(protection) }
        exec rm -f /home/egg/eggdrop/a.txt
        return 0
    }
 }
close $fp
set jdu "$title"
set lepen $jdu
set kirik [open "jadul" w+]
puts $kirik $lepen
close $kirik
utimer 3 [list puthelp "privmsg AbocyFM :request $judul.mp3"]
exec rm -f /home/egg/eggdrop/a.txt
timer 240 [list exec rm -f "$path/$judul.mp3"]
return 0
} elseif {[string match "*youtube.com/watch?v=*" [lindex $arg 0]] || [string match "*youtu.be*" [lindex $arg 0]] || [string match "*soundcloud.com*" [lindex $arg 0]]} {
putserv "privmsg AbocyFM :bcast %bold$nick:%bold %color4Req Link %color1,0%boldYou%color0,4Tube%bold %color1,0 Tidak Aktif "; catch { unset reqplud(protection) }
} elseif {[string match "*xvideo*" [lindex $arg 0]] || [string match "*xnxx*" [lindex $arg 0]]} {
putserv "privmsg AbocyFM :bcast %bold$nick:%bold %color4Req tidak diijinkan"; catch { unset reqplud(protection) }
} elseif {[string match "*http*" [lindex $arg 0]]} {
putserv "privmsg AbocyFM :bcast %bold$nick:%bold %color4Req Link cuma tersedia %color1,0%boldYou%color0,4Tube%bold%color1,0 %color7,1SOUNDCLOUD%color1,0 dan %color0,2 SMULE "; catch { unset reqplud(protection) }
} else {
set [decrypt 64 "pvlK31zkZDL/"] [lrange $arg 0 end]
if {[string match "* -*" [string tolower $arg]]} { regsub {\-} $arg {} arg }
if {[string match "*%*" [string tolower $arg]]} { regsub {\%} $arg { persen} arg }
regsub -all -- "\[^A-Za-z0-9\]" $arg " " arg

if {$apis == "1"} { set key "AIzaSyDlm0jcPyZ0V25-3a51RX4b6gz5tx9bfhQ"; search $nick $arg; putlog "apis 1" 
} elseif {$apis == "0"} { set key "AIzaSyAvCZv9QY9KzbgUsFhdnT71MqNZ1dQ86Pc"; search $nick $arg; putlog "apis 0"
} elseif {$apis == "2"} { move $arg; putlog "YT-DL" }

if {$id == ""} { puthelp "privmsg AbocyFM :bcast %bold$nick:%bold %color4 ERROR..., %color1%boldID youtube tidak tersedia%bold"; catch { unset reqplud(protection) }; return 0 }
if {[string match *ontol* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *vagina* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *sange* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *lajel* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *memek* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *crot* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *bombastis* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *crut* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *croo* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *crotz* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *crutz* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *nenen* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *bagio* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *adzan* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *azan* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *ngentot* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *ozawa* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *desah* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *kovinima* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *uting* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *jorok* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *tumpakan* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *muadzin* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {[string match *kinderjump* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
if {$durasi == "stream"} { catch { unset reqplud(protection) }; return 0 }
if {$durasi == "0"} { catch { unset reqplud(protection) }; return 0 }
regsub -all {\[} $jadul "(" jadul1
regsub -all {\]} $jadul1 ")" jadul2
regsub -all {\|} $jadul2 "" jadul3
regsub -all {\/} $jadul3 " " jadul4
regsub -all {\#} $jadul4 "" jadul5
regsub -all {\~} $jadul5 "-" jadul6
regsub -all {\%} $jadul6 " persen" jadul7
regsub -all "," $jadul7 " " ooo
regsub -all {\s+} $ooo " " oko

if {$oko == $cekjudul} { putserv "privmsg AbocyFM :raw NOTICE $nick :Maaf, Request mu sedang diputar saat ini..."; catch { unset reqplud(protection) }; return 0 }
set upperBoundLength 1024 ; set h [open "main.lst" r] ; catch {seek $h -$upperBoundLength end} ; set datas [read -nonewline $h] ; close $h
set repeat [lindex [split $datas "\n"] end]
if {$repeat == "$ooo.mp3"} {
	putserv "privmsg AbocyFM :raw NOTICE $nick :Jangan Request lagu yang sama dari sebelumnya..."
	catch { unset reqplud(protection) }
	return 0
}
set [decrypt 64 "uo52l.UD3ya."] [open "count" w]
puts $file2 [expr $angka + 1]
set [decrypt 64 "sC/l31f2zqJ1"] [expr $angka + 1]
close $file2
putquick "privmsg AbocyFM :bcast %bold$nick:%bold $jadul diproses...."
set dur "[string index $durasi end-4][string index $durasi end-3]"
if {($dur >= 13) || ([string index $durasi end-5] == ":" )} { puthelp "privmsg AbocyFM :bcast %bold$nick:%bold %bold$jadul%bold %color4ERROR..., %color1%boldDurasi:%color5 $durasi menit %color1==>%bold %color4MAX 13menit"; catch { unset reqplud(protection) }; return 0 }
if {[file exists "$path/$ooo.mp3"]} { pub_file $nick $ooo $jadul ; return 0}
#catch {exec youtube-dl -6 --no-cache-dir --no-playlist --no-part --youtube-skip-dash-manifest --max-filesize 20000000 --limit-rate 850000 $yturl --audio-quality 5 --postprocessor-args "-ar 44100" --extract-audio --audio-format mp3 -w -o "$path/$ooo.%(ext)s" >/dev/null &}
catch {exec ./youtube-dl -6 --no-cache-dir --no-resize-buffer --no-call-home --no-playlist --no-color --no-mark-watched --no-mtime --no-part --youtube-skip-dash-manifest --max-filesize 16000000 --limit-rate 850000 $yturl --audio-quality 6 --postprocessor-args "-ar 44100" --extract-audio --audio-format mp3 -w -o "$path/$ooo.%(ext)s" >/dev/null &}
utimer 10 [list ngecek $nick $jadul $ooo]
}}
proc [decrypt 64 "XLoox/A8IQt1uckaW/VPX/9."] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { putquick "privmsg AbocyFM :raw NOTICE $nick :Please Wait..!!!"; request $nick $arg }}
proc [decrypt 64 "wjGOC/dDklN."] { nick arg } {
global dj
if {$arg == ""} { putquick "privmsg AbocyFM :raw NOTICE $nick :ketik !pesan <pesan anda> atau .pesan <pesan anda>"; return 0}
if { [status] == "1" } {
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {$djnick != "AutoRJ"} { putserv "privmsg $djnick :(3Pesan dari $nick )4  $arg"; puthelp "privmsg AbocyFM :raw NOTICE $nick :Pesan Sent..."; return 0 }
} else {
putserv "privmsg AbocyFM :raw NOTICE $nick :sorry radio is currently offline"
}}
proc [decrypt 64 "eb3gv/bYBdp.gKeyI/n05Ky/"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreet $nick $arg }}
proc [decrypt 64 "JPjHX1x7MYt0JBkep1uW8yN."] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreeet $nick $arg }}
proc [decrypt 64 "kdjhE/iBF3V/FusI0/AogVP/"] { nick uhost hand arg } { global radiochans; setdj $nick $arg }
proc [decrypt 64 "6CnPv/juqUf.FusI0/AogVP/"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { setdj $nick $arg }}
proc [decrypt 64 "oJeHV/SbEq3/fm6rE/ZJhJy1"] { nick uhost hand arg } { global radiochans; setautodj $nick $arg }
proc [decrypt 64 "8qFYv0rDx5R/fm6rE/ZJhJy1"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { setautodj $nick $arg }}
proc [decrypt 64 "Gg6qV.JCljB1xpFlY/9L1pJ1"] { oldnick uhost hand chan newnick } {
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {$oldnick == $djnick} {
putlog "shoutcast: dj nickchange $oldnick -> $newnick"
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" w+]
puts $temp $newnick
close $temp
}}
proc [decrypt 64 "SZJRG0FG2xS."] { nick } {
set target "$nick"
putlog "shoutcast: $target asked for dj info"
if {[file exists dj]} {
set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" r]
set dj [gets $temp]
close $temp
putserv "Privmsg AbocyFM :bcast %bold$dj%bold Yang lagi Onair"
}}
proc [decrypt 64 "KrQEH/IoJrN/"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { dj $nick  }}
proc [decrypt 64 "MdN/b.zT8yb/"] { nick arg } {
if {$nick != "ehsan"} { return 0 }
set bbb [lindex $arg 0]
set sus [lrange $arg 2 end]
regsub -all {\} $bbb "" xyz
if {[lindex $arg 2] == ""} { putserv "Privmsg AbocyFM :bcast %bold$xyz%bold Ketik .req <Artist - Judul> atau !req/!rek"; return 0}
if { [status] == "1" } {
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djreq" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {$djnick == "AbocyFM"} { puthelp "privmsg AbocyFM :bcast %bold$xyz:%bold %color4Sorry, Dj Close Request,..."; return 0 }
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {[string match "!req" [lindex $arg 1]] || [string match ".req" [lindex $arg 1]] || [string match "!rek" [lindex $arg 1]]} {
if {$djnick == "AutoRJ"} {
	#pub_crot $nick $arg $xyz $sus
    } else {
	putserv "privmsg $djnick :(6Request dari $xyz )12  $sus"
	puthelp "privmsg AbocyFM :bcast %bold$xyz:%bold %color12Request $sus Sent..."
        }
    }
  } else {
	puthelp "privmsg AbocyFM :bcast %bold$xyz:%bold %color4sorry radio is currently offline"
     }
}
proc [decrypt 64 "bEMFW0n1wWH/"] {nick arg xyz sus} {
 global radiochans reqplud path durasi jadul yturl apis id key
  set [decrypt 64 "15L/00.xYXh1"] [open "count" r]; set [decrypt 64 "sC/l31f2zqJ1"] [gets $file1]; close $file1
  if {$angka == "6"} { putserv "privmsg AbocyFM :bcast %bold$xyz%bold %color4max 6, Tunggu lagu berikut selesai diputar.."; catch { unset reqplud(protection) }; return 0}
   if {[info exists reqplud(protection)]} {
	set rest [expr [clock seconds] - $reqplud(protection)]
	if {$rest < $reqplud(rest)} {
		set jasik [open "jadul" r]
		set judule [gets $jasik]
		close $jasik
		puthelp "privmsg AbocyFM :bcast %bold$xyz:%bold %color4Tunggu Request %bold%color14$judule%bold %color4selesai Diproses..."
		return 0
	}
	catch { unset rest }
  }
  set reqplud(protection) [clock seconds]
  if {[string match "*Full*" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "full" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*kontol" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*desah" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*DESAH" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*jembut" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*JEMBUT" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*crot*" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*vagina*" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*/ensembles" [lindex $arg 2]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "https://www.smule.com/*/*" [lindex $arg 2]] || [string match "*https://www.smule.com/recording/*/*" [lindex $arg 2]]} {
  smulerelay $nick $arg $xyz $sus
  } elseif {[string match "*/performance/*" [lindex $arg 2]]} {
  if {[lindex $arg 2] == "" } { catch { unset reqplud(protection) }; return 0 }
  if {[lindex $arg 3] == "" } { catch { unset reqplud(protection) }; return 0 }
  set jemb [lindex $arg 2]
  set itil [lrange $arg 3 end]
  regsub -all " " $itil "_" judul
  regsub -all " " $itil " " title

  set [decrypt 64 "uo52l.UD3ya."] [open "count" w]
  puts $file2 [expr $angka + 1]
  set [decrypt 64 "sC/l31f2zqJ1"] [expr $angka + 1]
  close $file2

  putquick "privmsg AbocyFM :bcast %bold$xyz:%bold Request Smule $title diproses...."
  puthelp "privmsg AbocyFM :autodj-reload"
  catch {exec ffmpeg -y -loglevel repeat+info -i $jemb -vn -acodec libmp3lame -q:a 4 -ar 44100 -metadata title=$title $path/$judul.mp3} link
  set f [open "a.txt" a+]
  puts $f $link
  close $f
  set fp [open "a.txt" r]
  while { [gets $fp line] >= 0 } {
      if {[string match *error* $line]} {
          puthelp "privmsg AbocyFM :bcast Smule 4$line"
	  catch { unset reqplud(protection) }
          exec rm -f /home/egg/eggdrop/a.txt
          return 0
      }
   }
   close $fp
   set jdu "$title"
   set lepen $jdu
   set kirik [open "jadul" w+]
   puts $kirik $lepen
   close $kirik
   utimer 3 [list puthelp "privmsg AbocyFM :request $judul.mp3"]
   exec rm -f /home/egg/eggdrop/a.txt
   timer 255 [list exec rm -f "$path/$judul.mp3"]
   return 0
  } elseif {[string match "*xvideo*" [lrange $arg 2 end]] || [string match "*xnxx*" [lrange $arg 2 end]]} {
  catch { unset reqplud(protection) }
  } elseif {[string match "*http*" [lindex $arg 2]]} {
  catch { unset reqplud(protection) }
  } else {
  if {[string match "* -*" [string tolower $sus]]} { regsub {\-} $sus {} sus }
  if {[string match "*%*" [string tolower $sus]]} { regsub {\%} $sus { persen} sus }
  if {[string match "*_*" [string tolower $sus]]} { regsub {\_} $sus { } sus }
  regsub -all -- "\[^A-Za-z0-9\]" $sus " " sus

  if {$apis == "1"} { set key "AIzaSyBlnL8h7FnukIEj9_QLtunU6x2AIO0H9vQ"; search1 $sus } elseif {$apis == "0"} { set key "AIzaSyAvCZv9QY9KzbgUsFhdnT71MqNZ1dQ86Pc"; search1 $sus }
  if {$apis == "1"} { set key "AIzaSyBlnL8h7FnukIEj9_QLtunU6x2AIO0H9vQ"; autoinfo1 $sus } elseif {$apis == "0"} { set key "AIzaSyAvCZv9QY9KzbgUsFhdnT71MqNZ1dQ86Pc"; autoinfo1 $sus }

  if {$id == ""} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *ontol* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *vagina* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *sange* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *lajel* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *memek* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *crot* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *crut* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *croo* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *crotz* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *crutz* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *nenen* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *bagio* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *adzan* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *azan* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *ngentot* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *ozawa* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *desah* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *uting* [string tolower $jadul]]} { catch { unset reqplud(protection) }; return 0 }
  if {[string match *jorok* [lrange $jadul 0 end]]} { catch { unset reqplud(protection) }; return 0 }
  if {$durasi == "stream"} { catch { unset reqplud(protection) }; return 0 }
  if {$durasi == "0"} { catch { unset reqplud(protection) }; return 0 }
  if {[string match "*: seconds" $durasi]} { regsub {\: seconds} $durasi {:0} durasi; set durasi "$durasi menit"
  } elseif {[string match "*:*" $durasi]} { set durasi "$durasi menit"}
  regsub -all {\[} $jadul "(" jadul1
  regsub -all {\]} $jadul1 ")" jadul2
  regsub -all {\|} $jadul2 "" jadul3
  regsub -all {\/} $jadul3 " " jadul4
  regsub -all {\#} $jadul4 "" jadul5
  regsub -all {\~} $jadul5 "-" jadul6
  regsub -all {\%} $jadul6 " persen" jadul7
  regsub -all "," $jadul7 " " kon

  set [decrypt 64 "uo52l.UD3ya."] [open $::limit w]
  puts $file2 [expr $angka + 1]
  set [decrypt 64 "sC/l31f2zqJ1"] [expr $angka + 1]
  close $file2
  putquick "privmsg AbocyFM :bcast %bold$xyz:%bold $jadul diproses...."
  putserv "privmsg AbocyFM :autodj-reload"
  if {[file exists "$path/$kon.mp3"]} { pub_filerel $kon $jadul ; return 0}
  catch {exec ./youtube-dl -6 --no-playlist --no-part --youtube-skip-dash-manifest --max-filesize 20000000 --limit-rate 750000 $yturl --audio-quality 6 --postprocessor-args "-ar 44100" --extract-audio --audio-format mp3 -w -o "$path/$kon.%(ext)s"} link
  set f [open "a.txt" a+]
  puts $f $link
  close $f
  set fp [open "a.txt" r]
  while { [gets $fp line] >= 0 } {
       if {[string match *ERROR* $line]} {
           puthelp "privmsg AbocyFM :bcast %bold$jadul%bold %color4ERROR..."
	   catch { unset reqplud(protection) }
           exec rm -f /home/egg/eggdrop/a.txt
	   exec rm -f "$path/$kon.mp3"
	   exec rm -f "$path/$kon.webm"
	   exec rm -f "$path/$kon.mp4"
	   exec rm -f "$path/$ooo.m4a"
	   close $fp
	   return 0
	} elseif {[string match *max-filesize* $line]} {
	   puthelp "privmsg AbocyFM :bcast %bold$jadul%bold %color4ERROR..., %color1%boldDurasi:%color5 $durasi%bold"
	   catch { unset reqplud(protection) }
           exec rm -f /home/egg/eggdrop/a.txt
	   exec rm -f "$path/$kon.webm"
	   exec rm -f "$path/$kon.mp4"
	   exec rm -f "$path/$kon.m4a"
	   close $fp
           return 0
	}
  }
  close $fp
  set jdu "$jadul"
  set lepen $jdu
  set kirik [open "jadul" w+]
  puts $kirik $lepen
  close $kirik
  utimer 3 [list puthelp "privmsg AbocyFM :request $kon.mp3"]
  exec rm -f /home/egg/eggdrop/a.txt
  timer 260 [list exec rm -f "$path/$kon.mp3"]
  }
}
proc [decrypt 64 "GcgTn0mPXae/9pI6m1rWNB21"] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { requestt $nick $arg }}
proc [decrypt 64 "y8Q1u.dD2w/1"] { nick arg } {
global radiochans dj
if {$nick != "ehsan"} { return 0 }
set aaa [lindex $arg 0]
set crut [lrange $arg 2 end]
regsub -all -- "\[^A-Za-z0-9\]" $aaa "" abc
if {[lindex $arg 2] == ""} { putserv "Privmsg AbocyFM :bcast %bold$abc:%bold ketik !pesan <pesan anda> atau .pesan <pesan anda>"; return 0} 
if { [status] == "1" } {
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {[string match ".pesan" [lindex $arg 1]] || [string match "!pesan" [lindex $arg 1]]} { 
if {$djnick == "AutoRJ"} { ; return 0}
putserv "privmsg $djnick :(3Pesan dari $abc )4  $crut"
puthelp "privmsg AbocyFM :bcast %bold$abc:%bold %color12Pesan sent..."
}} else {
puthelp "privmsg AbocyFM :bcast %bold$abc:%bold %color4sorry radio is currently offline"
}}

proc [decrypt 64 "JPjHX1x7MYt0JBkep1uW8yN."] { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreeet $nick $arg }}
bind pubm - "*AbocyFM*" [decrypt 64 "Nbb9d1djUDv1PinOh1uwLi3."]
proc [decrypt 64 "Nbb9d1djUDv1PinOh1uwLi3."] {nick uhost hand chan arg} {
  global botnick
  if {$chan != "#abocy"} { return 0 }
  if {$nick == "AbocyFM"} {
  set [decrypt 64 "dmqn5/bkSbl1"] [open "count" w]
  puts $pile "0"
  close $pile
 }
}
bind msgm - *added* [decrypt 64 "lm.Bx0XDGtB/DtHDJ.eW/700"]
proc [decrypt 64 "lm.Bx0XDGtB/DtHDJ.eW/700"] {nick uhost hand rest} {
  global botnick reqplud postrequest kotang
  if {$nick == "AbocyFM"} {
  set gawuk [open "jadul" r]
  set djan [gets $gawuk]
  close $gawuk
  set [decrypt 64 "S23HD0/VKmM0"] [lindex $rest 16]
  set [decrypt 64 "/8.KM1bLd2v0"] [lrange $rest 0 end]
  set temp [open "listreq" w]; puts $temp [expr $konter + 1]; close $temp
  if {$konter == 0 } {
  puthelp "privmsg AbocyFM :bcast %bold$djan%bold diputar setelah lagu berikut..."
  set msgpostrequest [lindex $postrequest [rand [llength $postrequest]]]
  exec echo "$msgpostrequest $kotang%bold" >> nickreq
  catch { unset reqplud(protection) }
  exec rm -rf jadul
  set o [open webreq r] ; set wr [gets $o] ; close $o
  if {$wr != ""} { utimer 4 [list web_request] }
} else {
  set konter [regsub -all {0} $konter "ï¼"]
  set konter [regsub -all {1} $konter "ï¼‘"]
  set konter [regsub -all {2} $konter "ï¼’"]
  set konter [regsub -all {3} $konter "ï¼“"]
  set konter [regsub -all {4} $konter "ï¼”"]
  set konter [regsub -all {5} $konter "ï¼•"]
  set konter [regsub -all {6} $konter "ï¼–"]
  set konter [regsub -all {7} $konter "ï¼—"]
  set konter [regsub -all {8} $konter "ï¼˜"]
  set konter [regsub -all {9} $konter "ï¼™"]
  puthelp "privmsg AbocyFM :bcast %bold$djan%bold diputar setelah %bold($konter)%bold lagu lagi..."
  set msgpostrequest [lindex $postrequest [rand [llength $postrequest]]]
  exec echo "$msgpostrequest $kotang%bold" >> nickreq
  catch { unset reqplud(protection) }
  exec rm -rf jadul
  set o [open webreq r] ; set wr [gets $o] ; close $o
  if {$wr != ""} { utimer 4 [list web_request] }
  }
 }
}
proc [decrypt base64 "Z3JldGluZw=="] { nick uhost hand chan arg } {
 global botnick
  set garet [lrange $arg 0 end]
  if {$chan != "#abocyFM"} { return 0 }
  set [decrypt 64 "2FW7P0.ZlAR0"] [open "dj" r]
  set rjd [gets $temp]
  close $temp
  if {$rjd == "AutoRJ"} { return 0 }
  if {$rjd == $nick } {
  if {[lindex $arg 0] == "" } { puthelp "privmsg AbocyFM :raw NOTICE $nick :ketik !greet <Greeting Anda> diroom RJ"; return 0 }
  puthelp "privmsg AbocyFM :raw NOTICE $nick :Greet sent..."
  putserv "PRIVMSG AbocyFM :bcast %color11,1\[ %color9%dj %color11\] %color13%boldâœ¦â˜€âœ¦%bold %color8%bold[string toupper [string trimleft $garet "#"]]%bold %color13%boldâœ¦â˜€âœ¦%bold %color11\[ %color9Rj GREETING %color11\]"
  return 0
  }
}
set plut(dor) 30
bind pub - !list antrian
bind pub - .list antrian
proc antrian {nick uhost hand arg chan} {
global botnick plut
set [decrypt 64 "2FW7P0.ZlAR0"] [open "djnick" r]
set [decrypt 64 "oXpcm1edDnt0"] [gets $temp]
close $temp
if {$djnick == "AutoRJ"} {
   if {[info exists plut(protection)]} {
       set dor [expr [clock seconds] - $plut(protection)]
       if {$dor < $plut(dor)} {
           putquick "privmsg AbocyFM :raw NOTICE $nick :Tunggu [expr $plut(dor) - $dor] detik untuk melihat Playlist"
           return 0
       }
       catch { unset dor }
   }
   set plut(protection) [clock seconds]
   set temp [open "listreq" r]; set ongko [gets $temp]; close $temp
   if {$ongko == 0 } { putserv "privmsg AbocyFM :raw NOTICE $nick :  Â»Â» Tidak ada Playlist Â«Â«"; return 0 }
   if {$ongko >= 11 } { 
       putserv "privmsg AbocyFM :raw NOTICE $nick :Maaf, Playlist lebih dr 10 lagu tidak bisa ditampilkan ($ongko Lagu)..."
     } else {
	set jembut "$nick"
	set djembut $jembut
	set temp [open "antri" w+]
	puts $temp $djembut
	close $temp
	putquick "NOTICE $jembut : Â»Â» 12Playlist RequesT Â«Â«"
        putserv "privmsg AbocyFM :autodj-reqlist"
	utimer 30 [list exec rm -f antri]
      }
    } else {
        puthelp "privmsg AbocyFM :raw NOTICE $nick :Â»Â» Playlist Sesuai RJ yg Onair Â«Â«"
    }
}
bind msgm - \[* playlist
proc playlist {nick uhost hand rest} {
  global botnick
  set satu [lrange $rest 1 end]
  regsub -all -- ".mp3" $satu "" final
  if {$nick == "AbocyFM"} {
  set temp [open "antri" r]
  set entut [gets $temp]
  close $temp
  puthelp "NOTICE $entut :Â»Â» $final"
 }
}
proc smuleng {nick arg} {
 global reqplud path
   set judul [lindex $arg 0]
   regsub -all "https://www.smule.com/" $judul "" judul1
   regsub -all "http://www.smule.com/" $judul1 "" judul2
   regsub -all "https://link.smule.com/" $judul2 "smulelink/" judul3
   set url "https://www.smuledownloader.download/$judul3"
   http::register https 443 [list ::tls::socket -autoservername true]
   http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https

   set cek "$status"
if {$cek == "timeout"} { puthelp "NOTICE $nick :4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset reqplud(protection) }; return 0 }
    set l [regexp -all -inline -- {<meta property="og:description" content="Get Smule Performace : (.*?) on Smule. Sing with lyrics to your favorite karaoke} $data]
    #set f [regexp -all -inline -- {<div id=audiolink><p><a href="(.*?)"} $data]
   set f1 ""; regexp -nocase {<h3>Audio Only</h3>(.*?)Direct Link to Save Audio} $data match f1
   set aud [string map {"\n" "" "\t" ""} $f1]; set aud1 [regsub -all {\s+} $aud ""]
   set f [regexp -inline -all -- {<p><ahref="(.*?)"} $aud1]

set [decrypt 64 "15L/00.xYXh1"] [open "count" r]
set [decrypt 64 "sC/l31f2zqJ1"] [gets $file1]
close $file1
if {$angka == "6"} { putserv "privmsg AbocyFM :raw NOTICE $nick :max 6, Tunggu lagu berikut selesai diputar..."; catch { unset reqplud(protection) }; return 0}
set [decrypt 64 "uo52l.UD3ya."] [open "count" w]
puts $file2 [expr $angka + 1]
set [decrypt 64 "sC/l31f2zqJ1"] [expr $angka + 1]
close $file2
if {[llength $f] == 0} { puthelp "privmsg AbocyFM :bcast %color4Link Smule Tidak Valid"; catch { unset reqplud(protection) }; return 0 }
     foreach {black b} $f {
         set b [string trim $b " \n"]
         regsub -all {<.+?>} $b {} b
        set kumpulin1 "$b"
        append muncrat1 $kumpulin1
	regsub -all {\"} $muncrat1 "" moncrot1
	}
     foreach {black a} $l {
         set a [string trim $a " \n"]
         regsub -all {<.+?>} $a {} a
	 regsub -all "&#x27;" $a "'" a
	 regsub -all "&amp;" $a "and" a
	 regsub -all "&apos;" $a "'" a
	 regsub -all "&quot;" $a "\"" a
	regsub -all -- "\[^A-Za-z0-9'\]" $a " " a1
	regsub -all "recorded" $a1 "" a2
	regsub -all {\s+} $a2 " " a3
	regsub {^\s+} $a3 "" a4
	regsub {\s+$} $a4 "" aa
        set kumpulin "$aa"
        append titles $kumpulin
	}
putquick "privmsg AbocyFM :bcast %bold$nick:%bold Request Smule $titles diproses...."
catch {exec ffmpeg -y -loglevel repeat+info -i $moncrot1 -vn -acodec libmp3lame -q:a 4 -ar 44100 -metadata title=$titles $path/$titles.mp3 >/dev/null &}
set jadul $titles
set ooo $titles
utimer 15 [list ngecek $nick $jadul $ooo]
return 0
}
proc smulerelay {nick arg xyz sus} {
 global reqplud path
   set judul [lindex $arg 2]
   regsub -all "https://www.smule.com/" $judul "" judul1
   regsub -all "http://www.smule.com/" $judul1 "" judul2
   set url "https://www.smuledownloader.download/$judul2"
   http::register https 443 [list ::tls::socket -autoservername true]
   http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https

   set cek "$status"
if {$cek == "timeout"} { putserv "privmsg AbocyFM :bcast %bold$xyz%bold %color4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset reqplud(protection) }; return 0 }
    set l [regexp -all -inline -- {<meta property="og:description" content="Get Smule Performace : (.*?) on Smule. Sing with lyrics to your favorite karaoke} $data]
    #set f [regexp -all -inline -- {<div id=audiolink><p><a href="(.*?)"} $data]
   set f1 ""; regexp -nocase {<h3>Audio Only</h3>(.*?)Direct Link to Save Audio} $data match f1
   set aud [string map {"\n" "" "\t" ""} $f1]; set aud1 [regsub -all {\s+} $aud ""]
   set f [regexp -inline -all -- {<p><ahref="(.*?)"} $aud1]

set [decrypt 64 "15L/00.xYXh1"] [open "count" r]
set [decrypt 64 "sC/l31f2zqJ1"] [gets $file1]
close $file1
if {$angka == "6"} { putserv "privmsg AbocyFM :bcast %bold$xyz%bold %color4max 6, Tunggu lagu berikut selesai.."; catch { unset reqplud(protection) }; return 0}
set [decrypt 64 "uo52l.UD3ya."] [open "count" w]
puts $file2 [expr $angka + 1]
set [decrypt 64 "sC/l31f2zqJ1"] [expr $angka + 1]
close $file2
if {[llength $f] == 0} { puthelp "privmsg AbocyFM :bcast %color4Link Smule Tidak Valid"; catch { unset reqplud(protection) }; return 0 }
     foreach {black b} $f {
         set b [string trim $b " \n"]
         regsub -all {<.+?>} $b {} b
        set kumpulin1 "$b"
        append muncrat1 $kumpulin1
	regsub -all {\"} $muncrat1 "" moncrot1
	}
     foreach {black a} $l {
         set a [string trim $a " \n"]
         regsub -all {<.+?>} $a {} a
	 regsub -all "&#x27;" $a "'" a
	 regsub -all "&amp;" $a "and" a
	 regsub -all "&apos;" $a "'" a
	 regsub -all "&quot;" $a "\"" a
	regsub -all -- "\[^A-Za-z0-9'\]" $a " " a1
	regsub -all "recorded" $a1 "" a2
	regsub -all {\s+} $a2 " " a3
	regsub {^\s+} $a3 "" a4
	regsub {\s+$} $a4 "" aa
        set kumpulin "$aa"
        append titles $kumpulin
	}
putquick "privmsg AbocyFM :bcast %bold$xyz:%bold Request Smule $titles diproses...."
putserv "privmsg AbocyFM :autodj-reload"
catch {exec ffmpeg -y -loglevel repeat+info -i $moncrot1 -vn -acodec libmp3lame -q:a 4 -ar 44100 -metadata title=$titles $path/$titles.mp3}
set jdu "$titles"
set lepen $jdu
set kirik [open "jadul" w+]
puts $kirik $lepen
close $kirik
utimer 4 [list puthelp "privmsg AbocyFM :request $titles.mp3"]
timer 230 [list exec rm -f "$path/$titles.mp3"]
return 0 
}
proc pub_file {nick ooo jadul} {
 global kotang
putquick "privmsg AbocyFM :autodj-reload"
set jdu "$jadul"
set lepen $jdu
set kirik [open "jadul" w+]
puts $kirik $lepen
close $kirik
utimer 6 [list puthelp "privmsg AbocyFM :request $ooo.mp3"]
utimer 7 [list exec echo "$ooo.mp3" >> main.lst]
set kotang $nick
return 0
}
proc pub_smile {nick titid} {
 global kotang
putquick "privmsg AbocyFM :autodj-reload"
set jdu "$titid"
set lepen $jdu
set kirik [open "jadul" w+]
puts $kirik $lepen
close $kirik
utimer 6 [list puthelp "privmsg AbocyFM :request $titid.mp3"]
set ooo $titid
utimer 7 [list exec echo "$ooo.mp3" >> main.lst]
set kotang $nick
return 0 
}
proc pub_filerel {kon jadul} {
  set jdu "$jadul"
  set lepen $jdu
  set kirik [open "jadul" w+]
  puts $kirik $lepen
  close $kirik
  utimer 3 [list puthelp "privmsg AbocyFM :request $kon.mp3"]
  return 0
}
proc web_request {} {
 set o [open webreq r] ; set wr [gets $o] ; close $o
 if {$wr == ""} { return 0 }
 set nick [lindex $wr 0]
 set argg [lrange $wr 1 end]
 regsub -all {\|web} $argg "" arg
 regsub -all {\|app} $arg "" arg
 request $nick $arg
}

proc move {arg} {
	global jadul durasi yturl id
	set [decrypt 64 "1W3.21HbqBm/"] [lrange $arg 0 end]
	regsub -all {\-} $bca1 "" abc1
	regsub -all {\%20} $abc1 " " abc1
	catch {exec ./youtube-dl -4 --no-warnings --get-id "ytsearch1:$abc1"} id
	set yturl "https://youtu.be/$id"
	set ambil [ autoinfo ]
	#set ambil [ autoinfost ]
	set jadul [string range [join [lrange $ambil 1 end]] 0 end]
	set durasi [lindex $ambil 0]
}
proc move1 {arg} {
	global jadul durasi yturl id
	set [decrypt 64 "1W3.21HbqBm/"] [lrange $sus 0 end]
	regsub -all {\-} $bca1 "" abc1
	regsub -all {\%20} $abc1 " " abc1
	catch {exec ./youtube-dl -4 --no-warnings -e --get-duration --get-id "ytsearch1:$abc1"} report
	foreach {namafile id durasi} [split $report "\n"] {
	set jadul [string map {{_} { }} $namafile]
	set jadul [regsub "http.+$" $jadul ""]
	set jadul [regsub {^\s+} $jadul ""]
	set jadul [regsub {\s+$} $jadul ""]
	set yturl "https://youtu.be/$id"
    }
}
proc search {nick arg} {
	global key id yturl apis jadul durasi
	set id ""
	regsub -all {\s+} $arg "%20" arg
	set arg [string map {{"} {'} {`} {'}} $arg]
	set url "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id(videoId))&type=video&maxResults=3&key=$key&q=$arg"
	http::register https 443 [list ::tls::socket -autoservername true]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [http::data [http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { set apis "0"; set key "AIzaSyAvCZv9QY9KzbgUsFhdnT71MqNZ1dQ86Pc" ; timer 120 [list set apis "1"]; search2 $nick $arg; return 0}
	set ids [dict get [json::json2dict $rawpage] items]
	set id [lindex $ids 0 1 1]
	if {[lindex $ids 2 1 1] == "" } { set id ""; return 0 }
	set yturl "https://youtu.be/$id"
	set ambil [ autoinfo ]
	#set ambil [ autoinfost ]
	set jadul [string range [join [lrange $ambil 1 end]] 0 end]
	set durasi [lindex $ambil 0]
}
proc search2 {nick arg} {
	global key id yturl apis jadul durasi
	set id ""
	regsub -all {\s+} $arg "%20" arg
	set arg [string map {{"} {'} {`} {'}} $arg]
	set url "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id(videoId))&type=video&maxResults=3&key=$key&q=$arg"
	http::register https 443 [list ::tls::socket -autoservername true]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [http::data [http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { set apis "2"; timer 120 [list set apis "1"]; move $arg; return 0}
	set ids [dict get [json::json2dict $rawpage] items]
	set id [lindex $ids 0 1 1]
	if {[lindex $ids 2 1 1] == "" } { set id ""; return 0 }
	set yturl "https://youtu.be/$id"
	set ambil [ autoinfo ]
	#set ambil [ autoinfost ]
	set jadul [string range [join [lrange $ambil 1 end]] 0 end]
	set durasi [lindex $ambil 0]
}

proc search1 {sus} {
	global key id yturl apis
	set arg $sus
	regsub -all {\s+} $arg "%20" arg
	set arg [string map {{"} {'} {`} {'}} $arg]
	set url "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id(videoId))&type=video&maxResults=3&key=$key&q=$arg"
	http::register https 443 [list ::tls::socket -tls1 true -ssl2 false -ssl3 false]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [http::data [http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { set key "AIzaSyBlnL8h7FnukIEj9_QLtunU6x2AIO0H9vQ" ; set apis "0"; timer 60 [list set apis "1"]; search1 $sus; return 0}
	set ids [dict get [json::json2dict $rawpage] items]
	set id [lindex $ids 0 1 1]
	if {[lindex $ids 2 1 1] == "" } { set id ""; return 0 }
	set yturl "https://youtu.be/$id"
}

proc autoinfo3 {nick arg} {
	global key id durasi jadul
	if {$id == ""} { return 0 }
	set url "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$key&part=snippet,contentDetails&fields=items(snippet(title),contentDetails(duration))"
	http::register https 443 [list ::tls::socket -tls1 true -ssl2 false -ssl3 false]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [http::data [http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { return 0}
	set ids [dict get [json::json2dict $rawpage] items]

	set jadul [encoding convertfrom [lindex $ids 0 1 1]]
	set jadul [regsub "http.+$" $jadul ""]
	set jadul [regsub {^\s+} $jadul ""]
	set jadul [regsub {\s+$} $jadul ""]
	set durasi [lindex $ids 0 3 1]
	if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	} else {
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {H|M} $durasi ":" durasi
		if {[string index $durasi end-1] == ":" } {
			set sec [string index $durasi end]
			set trim [string range $durasi 0 end-1]
			set durasi ${trim}0$sec
		} elseif {[string index $durasi 0] == "" } {
			set durasi "stream"
		} elseif {[string index $durasi 0] == "0" } {
			set durasi "stream"
		} elseif {[string index $durasi end-2] != ":" } {
			set durasi "${durasi} seconds"
		} elseif {[string index $durasi end-5] == ":" } {
			set durasi "${durasi} hour"
		}
	}
}
proc autoinfo {} {
 global id
	if {$id == ""} { return 0 }

	#set ipq [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
	set ipq [http::config -useragent "lynx"]
	set ipq [http::geturl "http://youtubesongname.000webhostapp.com/index.php?link=https://youtu.be/$id" -timeout 20000]
	set getipq [http::data $ipq]
	set status [http::status $ipq]
	set output [split $getipq "\n"]
	http::cleanup $ipq

	set title [string map { "&amp;" "&" "&#39;" "'" "&quot;" "\""} [lindex $output 0]]
	set title [concat $title]
	set title [regsub "http.+$" $title ""]
	set title [regsub {^\s+} $title ""]
	set title [regsub {\s+$} $title ""]
	set title [regsub -all {\"} $title ""]

	set durasi [lindex $output 6]
	set stream [lindex $output 6]

	if {$durasi == ""} { 
		autoinfo } else {

	if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	} else {
		set tik ""
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {M|S} $durasi ":" durasi
		regexp {^(.+):\d+} $durasi match tik
		regexp {\d+:(.+)$} $durasi match sec
		set menit [expr {int($tik) % 60}]
		set jam [expr {int($tik) / 60 % 60}]

		set waktu "$jam:$menit:$sec"
		if {[string index $waktu end-1] == ":" } { set sec "0$sec"; set waktu "$jam:$menit:$sec"}
		if {[string index $waktu end-4] == ":" } { set menit "0$menit"}
		if {$stream == "PT0M0S" } {
			set infos "stream $title"
		} elseif {$jam != "0" } {
			set infos "$jam:$menit:$sec $title"
		} elseif {$jam == "0"} {
			set infos "$menit:$sec $title"
		} elseif {$menit == "0" } {
			set infos "$sec $title"
		}
	 }
    }
}
proc autoinfost {} {
	global key id
	if {$id == ""} { return 0 }
	set url "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$key&part=snippet,contentDetails&fields=items(snippet(title),contentDetails(duration))"
	http::register https 443 [list ::tls::socket -tls1 true -ssl2 false -ssl3 false]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [http::data [http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { return 0}
	set ids [dict get [json::json2dict $rawpage] items]

	set title [encoding convertfrom [lindex $ids 0 1 1]]
	set title [regsub "http.+$" $title ""]
	set title [regsub {^\s+} $title ""]
	set title [regsub {\s+$} $title ""]
	set durasi [lindex $ids 0 3 1]

	if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	} else {
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {H|M} $durasi ":" durasi
		if {[string index $durasi end-1] == ":" } { 
			set sec [string index $durasi end]
			set trim [string range $durasi 0 end-1]
			set durasi "${trim}0$sec"
			if {[string index $durasi end-4] == ":" } {
				set menit [string index $durasi end-3]
				set trim [string range $durasi 0 end-4]
				set infos "${trim}0$menit:0$sec $title"
			} else {
				set infos "${trim}0$sec $title"
		     }
		} elseif {$durasi == "P0D" } {
			set infos "stream $title"
		} elseif {[string index $durasi 0] == "0" } {
			set infos "stream $title"
		} elseif {[string index $durasi end] == ":" } {
			set infos "${durasi}00 $title"
		} else {
			set infos "$durasi $title"

		}
	}
}

proc autoinfo1 {sus} {
	global key id durasi jadul
	if {$id == ""} { return 0 }
	set url "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$key&part=snippet,contentDetails&fields=items(snippet(title),contentDetails(duration))"
	http::register https 443 [list ::tls::socket -tls1 true -ssl2 false -ssl3 false]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [http::data [http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { return 0}
	set ids [dict get [json::json2dict $rawpage] items]

	set jadul [encoding convertfrom [lindex $ids 0 1 1]]
	set jadul [regsub "http.+$" $jadul ""]
	set jadul [regsub {^\s+} $jadul ""]
	set jadul [regsub {\s+$} $jadul ""]
	set durasi [lindex $ids 0 3 1]
	if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	} else {
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {H|M} $durasi ":" durasi
		if {[string index $durasi end-1] == ":" } {
			set sec [string index $durasi end]
			set trim [string range $durasi 0 end-1]
			set durasi ${trim}0$sec
		} elseif {[string index $durasi 0] == "" } {
			set durasi "stream"
		} elseif {[string index $durasi 0] == "0" } {
			set durasi "stream"
		} elseif {[string index $durasi end-2] != ":" } {
			set durasi "${durasi} seconds"
		} elseif {[string index $durasi end-5] == ":" } {
			set durasi "${durasi} hour"
		}
	}
}

bind pubm - "*AbocyFM*" autongaceng
proc autongaceng {nick uhost hand chan arg} {
 global cekjudul
set titlep [string range [join [lrange $arg 4 end-5]] 0 end]
if {$chan != "#abocy"} { return 0 }
if {$nick == "AbocyFM"} {
set cekjudul $titlep
 }
}

bind msg o .add filter
proc filter {nick uhost hand rest} {
 global path
foreach fales [glob -directory $path -type f *] {
if {[string match -nocase "*$rest*" $fales]} {
exec rm -f $fales}}

set tesi [string tolower [lindex $rest 0]]
exec echo "$tesi" >> filter
putserv "notice $nick :DONE"
}

bind pub o .filter jadwal
proc jadwal {uhost hand nick chan arg } {

set x [open filter r] ; set lihat [read $x] ; close $x
foreach line [split $lihat \n] {
putquick "NOTICE $nick :$line"   
 }
}

 # eggdrop port to bind 
 set port 14613
 # eggdrop ip to bind 
 set host 127.0.0.1

 if {![info exists serverSocket]} { set serverSocket [socket -server main -myaddr $host $port] }

 proc main { sock host port } { 
         fconfigure $sock -buffering line 
         fileevent $sock readable [action $sock $host $port] 
 } 

 proc action { chan host port } {
         global output_chan
 
         if {![eof $chan]} {
                 set soc_data [gets $chan]
 
                 if {($soc_data != "") && ($soc_data != "GET / HTTP/1.1")} {
                         #putquick "PRIVMSG Heh :$host | $port | $soc_data"
			req_web $soc_data
                 }
         } {
                 close $chan
         }
 }

proc req_web {soc_data} {
 global serverSocket
if {[file exists dj]} { set temp [open "dj" r] ; set dj [gets $temp] ; close $temp }
set co "$dj" ; set arg [lrange $soc_data 5 end] ; set nick1 [lindex $soc_data 3]
set pesan [lindex $soc_data 1] ; set ip [lindex $soc_data 0]
set shelltime_setting(format) "%H:%M:%S - %d %B %Y"
exec echo "([clock format [clock seconds] -format $shelltime_setting(format)]) ($ip) $nick1 $arg" >> web.txt

if {$dj != "AutoRJ"} { putquick "PRIVMSG $co : [lrange $soc_data 1 end]"; return 0 }
if {($arg == "") && ($nick == "")} { return 0}
set temp [open "blaklist" r] ; set blacklist [gets $temp] ; close $temp
if {$ip == $blacklist} { return 0 }
if {[pub_proxys $ip] == "yes"} { putlog "Proxy Detected"; return 0 }
if {[string match "*Pesan|ViaWeb*" $pesan]} { return 0}
if {[string match "*Pesan|ViaApp*" $pesan]} { return 0}
if {[string match "*Request|ViaApp*" $pesan]} {
set nick "$nick1|ViaApp"
set x [open banned.txt r] ; set c [read $x] ; close $x ; set xr [split $c "\n"]
if {[string match "*$nick1*" $xr]} { return 0 }
set [decrypt 64 "15L/00.xYXh1"] [open "count" r]; set [decrypt 64 "sC/l31f2zqJ1"] [gets $file1]; close $file1
if {$angka == "6"} { return 0}
exec echo "$nick $arg|app" >> webreq
request $nick $arg
} else {
set nick "$nick1|ViaWeb"
set x [open banned.txt r] ; set c [read $x] ; close $x ; set xr [split $c "\n"]
if {[string match "*$nick1*" $xr]} { return 0 }
if {[string match "*youtube.com/watch?v=*" $arg] || [string match "*youtu.be*" $arg]} { return 0 }
set [decrypt 64 "15L/00.xYXh1"] [open "count" r]; set [decrypt 64 "sC/l31f2zqJ1"] [gets $file1]; close $file1
if {$angka == "6"} { return 0}
exec echo "$nick $arg|web" >> webreq
request $nick $arg
}}

set reloading "0"
proc ngecek {nick jadul ooo} {
 global path kotang reloading reqplud
 if {[file exists "$path/$ooo.webm"] || [file exists "$path/$ooo.mp4"] || [file exists "$path/$ooo.m4a"]} {
   if {$reloading == 70} {
	putquick "privmsg AbocyFM :raw NOTICE $nick :ERROR,.. File Not FOund"
	set reloading "0"
	catch { unset reqplud(protection) }
	putlog "RESET"
	exec rm -f "$path/$ooo.webm"
	exec rm -f "$path/$ooo.mp4"
	exec rm -f "$path/$ooo.m4a"
	return 0
      } else {
        set reloading [expr $reloading + 5]
	putlog "set $reloading"
       }
	putlog "akhir $reloading"
	utimer 5 [list ngecek $nick $jadul $ooo]
    } else {
      putquick "privmsg AbocyFM :autodj-reload"
      set jdu "$jadul"
      set lepen $jdu
      set kirik [open "jadul" w+]
      puts $kirik $lepen
      close $kirik
      utimer 7 [list puthelp "privmsg AbocyFM :request $ooo.mp3"]
      utimer 8 [list exec echo "$ooo.mp3" >> main.lst]
      set kotang $nick
      set reloading "0"
      #timer 250 [list exec rm -f "$path/$ooo.mp3"]
   }
}

set tube(rests) 10
bind msg - reson repor
proc repor {nick uhost hand rest} {
 global tube
 if {$nick != "AbocyFM"} { return 0 }
    if {[info exists tube(protection)]} {
        set rests [expr [clock seconds] - $tube(protection)]
        if {$rests < $tube(rests)} {
            return 0
        }
        catch { unset rests }
    }
    set tube(protection) [clock seconds]
 #exec echo "[lrange $rest 0 end]" >> titided
 set temp [open "nickreq" r]; set nickreq [gets $temp] ; close $temp
 if {$nickreq != "" } {
 putquick "privmsg AbocyFM :bcast $nickreq"
 utimer 2 [list exec sed -i "1d" nickreq]
 utimer 4 [list exec sed -i "1d" main.lst]
 set temp [open "listreq" r]; set ongko [gets $temp]; close $temp
 set temp [open "listreq" w]; puts $temp [expr $ongko - 1]; close $temp
 }
}

proc pub_proxys {ip} {
	set linkd "http://proxycheck.io/v2/$ip?key=s342t5-wm5w83-a1741o-3460z5"
	set ipq [http::config -useragent "lynx"]
	set ipq [::http::geturl $linkd] 
	set data [http::data $ipq]
	::http::cleanup $ipq
	set ids [ngising:json "$ip" $data]
	set proxy [lindex $ids 1]
if {$proxy == "yes"} {
	set kaprok "yes"
	return 0
} else {
	set kaprok "no"
	return 0
	}
	return 0
}


proc ngising:json {get data} {
	global black
	set parse [::json::json2dict $data]
	set return ""
foreach {name info} $parse {
if {[string equal -nocase $name $get]} {
	set return $info
	break;
		}
	}
	return $return
}

bind pub - .lis listeners
proc listeners {nick uhost hand arg chan} {
putserv "privmsg AbocyFM :bcast Jumlah Pendengar: %color4%bold%clients%bold"
}

putlog "Tcl Radio By ucup"

