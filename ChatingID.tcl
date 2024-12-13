#######################################
#          Script Bot Auto-RJ         #
# Developed by ChatingID Network Team #
#######################################

package require http
package require json
package require tls

set key1 "APIKEY YOUTUBE"
set key "APIKEY YOUTUBE"

## Channel Flags ---
setudef flag req

## -----------------
set blockednick "||||||||||||||"
## RJ Command ---
bind pub f .on reqon
bind pub f .off reqoff 

set RJChan "#RCFM"
set radiobotname "Radio"

proc reqon {nick uhost hand chan arg} {
global radiobotname RJChan antrian
	if {$chan != $RJChan} { return 0 }
	set temp [open "djnick" r]; set djnick [gets $temp]; close $temp
	if {([rjcheck] != "EvoChatID") && ($djnick != "$nick") } { putquick "NOTICE $nick :upps. Record RJ sedang Running"; return 0 }
	foreach chans [channels] {
		if {[channel get $chans req]} {
			puthelp "NOTICE $nick :Already Opened"
			return 0
		}
		channel set $chans +req
		puthelp "PRIVMSG $radiobotname :bcast %bold%color3RjEvoChatID%bold on Turn table!!"
		puthelp "PRIVMSG $radiobotname :bcast Ketik %bold!request Artist - Judul Lagu%bold  Untuk Request lagu dari %boldRjEvoChatID"
		putquick "PRIVMSG $radiobotname :autodj-play"
		set nicknames "EvoChatID"
		set djnickname $nicknames
		putlog "shoutcast: new dj: $djnickname ($nicknames)"
		set temp [open "dj" w+]
		puts $temp $djnickname
		close $temp
		set temp [open "djnick" w+]
		puts $temp $djnickname
		close $temp
		catch { unset antrian }
	}
}

proc reqoff {nick uhost hand chan arg} {
global radiobotname RJChan
       	if {$chan != $RJChan} { return 0 }
	foreach chans [channels] {
		if {![channel get $chans req]} {
			puthelp "NOTICE $nick :Already Closed"
			return 0
		}
		channel set $chans -req
		set nicknames "$nick"
		set djnickname $nicknames
		putlog "shoutcast: new dj: $djnickname ($nicknames)"
		set temp [open "dj" w+]
		puts $temp $djnickname
		close $temp
		set temp [open "djnick" w+]
		puts $temp $djnickname
		close $temp
		puthelp "PRIVMSG $radiobotname :bcast %bold%color4RjEvoChatID%color%bold Replaced by %bold%color3RJ-$djnickname%color%bold"
		puthelp "PRIVMSG $radiobotname :bcast Ketik %bold!request Artist - Judul Lagu%bold  Untuk Request lagu ke %boldRJ-$djnickname"
		#puthelp "PRIVMSG $radiobotname :bcast Use %bold!request Artist - Song title%bold To request a song to %boldRJ-$djnickname"
		#putserv "PRIVMSG $radiobotname :adduser $nick +aqsdj mj123 *@*"
		putserv "PRIVMSG $radiobotname :autodj-force"
	}
  	utimer 10 [list cekingplaylist]
}

proc cekingplaylist {} {
global radiobotname
	set temp [open djnick r] ; set djnick [gets $temp] ; close $temp
	if {$djnick == "EvoChatID"} { putlog "Sedang AutoRJ"; return 0 }
	set ol [open requestby.txt r] ; set nickreq [gets $ol] ; close $ol
	if {$nickreq != ""} {
		if {![file exists [lrange $nickreq 1 end]]} {
    		set judul [string map {"/home/radio/mp3/" ""} [lrange $nickreq 1 end]]
    		exec sed -i "1d" requestby.txt
    		putquick "PRIVMSG $radiobotname :autodj-reqdelete $judul"
    		putlog "Remove Playlist dan nickreq"
    	}
   		timer 1 [list cekingplaylist]
		putlog "CEK FIle Playlist"
	} else {
		putlog "Playlist kosong"
  		return 0
	}
}

bind pub o -skip lewat
proc lewat {nick uhost hand arg chan} {
	global radiobotname
	putquick "PRIVMSG $radiobotname :autodj-next"
	putserv "PRIVMSG $radiobotname :bcast %bold%song%bold Request Skipped By %bold$nick ..!%bold "
}

##############################################################
## Folder MP3 Download Lagu
set mp3home "/home/radio/mp3"

set radiochans "#RCFM #radio #Dummy #acs #bekasi"
set scdjtrigger "~dj"
#set scsetdjtrigger "-.off"
#set scsetautodjtrigger "-.on"
set scwishtrigger "!request"
set scgreettrigger "!message"
bind pub - $scdjtrigger  pub_dj
#bind pub - $scsetdjtrigger  pub_setdj
#bind msg - $scsetdjtrigger  msg_setdj
#bind pub - $scsetautodjtrigger  pub_setautodj
#bind msg - $scsetautodjtrigger msg_setautodj
bind pub - $scwishtrigger  pub_request
bind pub - !req pub_request
bind pub - .req pub_request
bind pub - .request pub_request
bind msg - !request msg_request
bind msg - !req msg_request
bind pub - $scgreettrigger  pub_greet
bind pub - .pesan pub_greet
bind pub - .msg pub_greet
bind nick - * djnickchange

proc setdj {nickname djnickname } {
global streamip streamport streampass
	if {$djnickname == "" } { set djnickname $nickname }
	putlog "shoutcast: new dj: $djnickname ($nickname)"
	set temp [open "dj" w+]
	puts $temp $djnickname
	close $temp
	set temp [open "djnick" w+]
	puts $temp $nickname
	close $temp
}

proc setautodj {nickname djnickname} {
	set nicknames "EvoChatID"
	set djnickname $nicknames
	putlog "shoutcast: new dj: $djnickname ($nicknames)"
	set temp [open "dj" w+]
	puts $temp $djnickname
	close $temp
	set temp [open "djnick" w+]
	puts $temp $nicknames
	close $temp
}

proc pub_request { nick uhost hand chan arg } { 
global radiochans radiobotname blockednick
  set temp [open blockednicks.txt r] ; set xx [read $temp] ; close $temp ; set xxx [split $xx "\n"]
  foreach xyz [string map { "\{" "" "\}" ""} $xxx] {
	if {[string match -nocase "*$xyz*" [string tolower $nick]]} { putlog "BLOCKED"; return 0 }
  }
	#regsub -all "/" $arg args
	######### Add Limit request by requestby.txt length by Jaka 07-01-2021 ###	
	set temp [open "djnick" r]; set djnick [gets $temp]; close $temp
	if {$djnick == "EvoChatID"} {
	set fid [open "requestby.txt" r]
	set data [read $fid [file size "requestby.txt"]]
	set lineCount [llength [split $data "\n"]]
		if {$lineCount >= 8} {
		putserv "NOTICE $nick :sabar ya, quota request penuh \[Max 7 request\]"
		return 0
		}
	}
	############################################################################

	if {$nick == $blockednick} { putserv "NOTICE $nick :Maaf, kalau mau rusuh bukan disini \[PermBan Request\]"; return 0 }
	if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { 
		#putquick "PRIVMSG $radiobotname $nick Request: %bold$arg%bold"
		request $nick $arg
	}
}

## New Improve Req dari Luar Network

proc msg_request { nick uhost hand arg } { 
global radiobotname
	set yangreq [lindex $arg end]
	#set lagunya [regsub --all $yangreq $arg " "] 
	regsub -all $yangreq $arg "" lagunya 
	set reqglobal1 [regsub -all "@" $yangreq " "]
	set reqnick1 [lindex $reqglobal1 0]
	set reqvia1 [lindex $reqglobal1 1]

	#putserv "PRIVMSG $radiobotname :bcast $reqnick1 Request: %bold$lagunya%bold (Dari $reqvia1)"
	request $yangreq $lagunya
}

proc request { nick arg } {
global radiobotname antrian
	if {$arg == ""} { putserv "PRIVMSG $radiobotname :bcast %bold$nick%bold Type %bold!request Artist - Song title for Rquest to %boldRJ-%dj%bold..! "; return 0}
	set abc [lindex $arg 0]
	if {$arg == ""} { putserv "PRIVMSG $radiobotname :bcast $abc Type !request <Artist - Song title>"; return 0}
	putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Please Wait.."
	set temp [open "djnick" r]
	set djnick [gets $temp]
	close $temp
	if {$djnick == "EvoChatID"} {
    	if {![info exists antrian]} {
			set antrian ""
        	pub_get $nick $arg
     	} else {
			putlog "masuk antrian"
        	exec echo "$nick $arg" >> antri.txt
     	}
	} else {
		putserv "privmsg $djnick :Permintaan lagu dari $nick : $arg"
	}
	
}

catch { unset antrian }
set oldjudul ""
set rereq ""
proc pub_get { nick arg } {
global radiobotname mp3home oldjudul cekjudul rereq
	set temp [open block.txt r] ; set xx [read $temp] ; close $temp ; set xxx [split $xx "\n"]
	foreach xyz [string map { "\{" "" "\}" ""} $xxx] {
		if {[string match -nocase "*$xyz*" [string tolower $arg]]} { putlog "BLOCKED"; susunan; return 0 }
	}
	if {[lrange $arg 0 end] == $rereq} { putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Anda Request lagu yang sama dari sebelumnya"; susunan; return 0 }
	set rereq [lrange $arg 0 end]

	if {[string match "https://www.smule.com/recording/*/*" [lindex $arg 0]] || [string match "https://www.smule.com/sing-recording/*" [lindex $arg 0]] || [string match "https://www.smule.com/c/*" [lindex $arg 0]]} { smule $nick $arg; return 0 }
	if {[string match "http://forchat.my.to*" [lindex $arg 0]]} { xbas $nick $arg; return 0 }
	if {[string match "*http*" [string tolower $arg]]} {
    	set link [lindex $arg 0]
    	set link [regsub "&list=.+$" $link ""]
    	catch {exec yt-dlp -4 --skip-download --no-warnings --get-duration --get-filename -o "%(title)s" $link} report
    	if {[string match *error:* [string tolower $report]]} { putlog "$report"; susunan; return 0 }
		foreach {namafile durasi} [split $report "\n"] {
	 		set judul [string map { "%" " persen" "\'" "" "\/" "" "\\" "" "\[" "\(" "\]" "\)" "\{" "\(" "\}" "\)" } $namafile]
	 		set dur [string map { ":" "" } $durasi]
	 		set yturl $link
			putlog "YT-Link"
			#putserv "PRIVMSG #dummy :YT-Link: $link";
	 	}
	} else {
		set text [string map { "-" "" } [lrange [split $arg] 0 end]]
		catch {exec yt-dlp -4 --skip-download --no-warnings --get-id --get-duration --get-filename -o "%(title)s" "ytsearch1:$text"} report
    	if {[string match *error:* [string tolower $report]]} { putlog "$report"; susunan; return 0 }
		foreach {id namafile durasi} [split $report "\n"] {
	 		set judul [string map { "%" "_persen" "\'" "" "\/" "" "\\" "" "\[" "\(" "\]" "\)" "\{" "\(" "\}" "\)" } $namafile]
	 		set dur [string map { ":" "" } $durasi]
	 		set yturl "http://youtu.be/$id"
			putlog "YT-Search"
			#putserv "PRIVMSG #dummy :YT-Search $yturl";
	 	}
	}
	set judul [recode $judul]
	if {$dur > "1500"} {
    	putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Sorry Bossque.. Durasi Max 15 menit."
    	susunan
    	return 0
	} elseif {($durasi == "") || ($durasi == "0")} {
    	putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. LiveStream tidak diizinkan!"
    	susunan
    	return 0
	} elseif {$oldjudul == $judul} {
    	putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Anda Request lagu yang sama dari sebelumnya"
    	susunan
    	return 0
	} elseif {$cekjudul == $judul} {
    	putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Lagu yang anda request sedang diPlay"
    	return 0
	} else {
		set oleng [open requestby.txt r] ; set play [read $oleng] ; close $oleng
		foreach asu [split $play "\n"] {
			regsub {^.+?\/home\/radio\/mp3\/} $asu {} asu
  			if {[string match -nocase $asu $judul.m4a]} { putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Request anda sudah ada di Playlist"; susunan; return 0 }
		}
		foreach xyz [string map { "\{" "" "\}" ""} $xxx] {
  			if {[string match -nocase "*$xyz*" [string tolower $judul]]} { putlog "BLOCKED"; susunan; return 0 }
		}
		putquick "PRIVMSG $radiobotname :bcast $nick Request: %color10$judul%color"
		
		set oldjudul "$judul"
		if {[file exists $mp3home/$judul.m4a]} { putserv "PRIVMSG $radiobotname :!request $judul.m4a"; exec echo "$nick $mp3home/$judul.m4a" >> requestby.txt; return 0 }
		#catch {exec yt-dlp --downloader aria2c --downloader-args "aria2c:-x 16 -s 16 -k 1M" $yturl --user-agent "Mozilla/5.0 (X11; CrOS x86_64 14092.57.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.85 Safari/537.36" --no-check-certificates --prefer-insecure -4 --no-cache-dir --no-resize-buffer --no-playlist --no-color --no-mark-watched --no-mtime --no-part --ignore-dynamic-mpd -f 140 --extract-audio -w -o "$mp3home/$judul.%(ext)s"} runcmd
		catch {exec yt-dlp -4 --no-warnings -x $yturl -f 140 -o "$mp3home/$judul.%(ext)s" --exec "echo $nick >> requestby.txt"} runcmd
		if {[string match *error* [string tolower $runcmd]]} { putlog "ERROR: Kegagalan Download"; susunan; return 0 }
		::addreq $nick
		putserv "PRIVMSG $radiobotname :!autodj-reload"
		utimer 4 [list cekplelis $judul]
		timer 240 [list delagu $nick $judul.m4a]
 	}
}

proc smule {nick arg} {
global mp3home radiobotname oldjudul cekjudul
set judul [lindex $arg 0]
set url "https://sownloader.com/index.php?url=[url_encode $judul]"
http::register https 443 [list ::tls::socket -autoservername true -require true -cadir /etc/ssl/certs]
   http::config -useragent "Mozilla/5.0 (X11; CrOS x86_64 14092.57.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.85 Safari/537.36"
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https

   putlog $status

	if {$status == "timeout"} { putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Koneksi ke smule.com Terputus"; susunan; return 0 }
    set l [regexp -all -inline -- {downloader.php\?url\=(.*?)\&name\=(.*?)\&ext\=m4a} $data]

   if {[llength $l] == 0} { putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Link Tidak Valid"; susunan; return 0 }
   foreach {blank a b} $l {
   	set judul [string map {"&#x27;" "'" "amp;" "" "&apos;" "'" "&quot;" "\""} $b]
   regsub -all -- "\[^A-Za-z0-9'&\]" $judul " " judul; regsub -all {\s+} $judul " " judul
   regsub {^\s+} $judul "" judul; regsub {\s+$} $judul "" judul
   set judul "$judul \(Smule Cover\)"
   }
if {$oldjudul == $judul} {
    putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Anda Request lagu yang sama dari sebelumnya"
    susunan
    return 0
} elseif {$cekjudul == $judul} {
    putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Lagu yang anda request sedang diPlay"
    susunan
    return 0
} else {
putquick "PRIVMSG $radiobotname :bcast $nick Request: %color10$judul%color"
set oldjudul "$judul"
if {[file exists $mp3home/$judul.m4a]} { putserv "PRIVMSG $radiobotname :!request $judul.m4a"; exec echo "$nick $mp3home/$judul.m4a" >> requestby.txt; return 0 }
catch {exec wget -U "Mozilla/5.0 (X11; CrOS x86_64 14092.57.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.85 Safari/537.36" $a -O "$mp3home/$judul.m4a"} runcmd
foreach line [split $runcmd "\n"] {
if {[string match *error* [string tolower $line]]} { putlog "GAGAL Download"; susunan; return 0 }
if {[string match -nocase *$judul.m4a*saved* [string tolower $line]]} {
  catch {exec exiftool -all= "$mp3home/$judul.m4a"} log
  if {[string match "*updated" [string tolower $log]]} { exec rm -f "$mp3home/$judul.m4a_original" }
  exec echo "$nick $mp3home/$judul.m4a" >> requestby.txt
  ::addreq $nick
  putserv "PRIVMSG $radiobotname :!autodj-reload"
  utimer 4 [list cekplelis $judul]
   }
  }
timer 242 [list delagu $nick $judul.m4a]
 }
}

bind msg - .oke msg_req
proc msg_req { nick args } {
global radiobotname
if { $nick == $radiobotname } {
putlog "$args"
set inireq [lindex $args 2]
set num [lindex [split $args] 7]
	if {[string match "* 0 lagu*" $inireq]} {
		#putserv "PRIVMSG $radiobotname :bcast Requestmu akan diputar setelah lagu ini..."
                putserv "PRIVMSG $radiobotname :bcast %color10[fadebackreq $num]%color akan diputar setelah lagu ini..."
		utimer 4 [list susunan]
	} else {
		#putserv "PRIVMSG $radiobotname :bcast $inireq"
                putserv "PRIVMSG $radiobotname :bcast %color10[fadebackreq $num]%color akan di putar setelah $num lagu lagi..."
		utimer 4 [list susunan]
	}
putlog "Broadcast Terkirim!"
}
}
proc fadebackreq { num } {
set fod [expr $num + 1 ]
catch {exec sed -n "$fod{p}" requestby.txt} requ
set final [lrange [string map {"/home/radio/mp3/" "" ".m4a" ""} $requ] 1 end]
return $final
}

########################## TITLE LAGU YANG DITAMPILKAN DI CHAN DAN TRIGGER PENGURANGAN LIMIT ######################
set cekjudul ""
set jeda(rests) 5
bind msg - "sending" repor
proc repor {nick uhost hand rest} {
global jeda radiobotname cekjudul mp3home
putlog "Sending Song to Play: $nick - $rest"
 if {$nick != $radiobotname} { return 0 }
 if {[lrange $rest 0 end] == ""} { return 0 }
    if {[info exists jeda(protection)]} {
        set rests [expr [clock seconds] - $jeda(protection)]
        if {$rests < $jeda(rests)} {
            return 0
        }
        catch { unset rests }
    }
    set jeda(protection) [clock seconds]
set djname [string range [join [lrange [split $rest] 0 end]] 0 end]
regexp -- {.*\s(.+?)\s--(.+?)--\s(.+)} $djname wholematch listen djset judul
set judul [string range [join [lrange $judul 0 end]] 0 end]
set cekjudul $judul
if {$djset == "EvoChatID"} {
   	set ol [open requestby.txt r] ; set nickreq [gets $ol] ; set data [read -nonewline $ol]; close $ol
    if {![info exists reqby]} { set reqby [lrange $nickreq 1 end] }
	putlog "Req By: $judul"
    if {$nickreq != ""} {
		if {![string match *chating* [string tolower $judul]] && ![string match *jingle* [string tolower $judul]]} {
			if {![string match *$judul* $reqby]} {
		    	catch {exec sed -i "1d" requestby.txt} delsonglist
		    	catch { unset reqby }
		    	#return 0
			} else {
		    	putquick "PRIVMSG $radiobotname :bcast Lagu berikutnya di Request oleh %bold%color7[lindex $nickreq 0]%color%bold"
		    	catch {exec sed -i "1d" requestby.txt} delsonglist
		    	catch { unset reqby }
				set lines [split $data "\n"]
				set i [lsearch -glob $lines *$judul*]
				putlog "Lsearch $i"
				#set lines [lreplace $lines $i $i]
				#set fp [open $ol "w"]
				#puts $fp [join $lines "\n"]
				#close $fp
			}
	    }
    }
}
  putlog "Send Song To Chan"
  putserv "PRIVMSG $radiobotname :bcast %bold%color4.:♊%bold %color10RJ-$djset %color6muterin lagu %color14$judul%color12 (%color7%bold[stripkode [waktu $judul]]%bold%color12)%color6 dengerin di: http://evochat.co.id/%color %bold%color4♊:.%bold"
  #putquick "PRIVMSG $radiobotname :bcast %bold%color4-:%bold %color10RJ-$djset %color6 muterin %color14$judul%color6 dengerin di : http://evochat.co.id/%color  %bold%color4:-%bold"
  #pub_delreqcount $nick $rest
 if {[info exists reqby]} { catch { unset reqby } }
}
##########################################################################################################
set apikey "off"
proc waktu { judul } {
 global apikey mp3home
set judul [string range [join [lrange [split $judul] 0 end]] 0 end]
set judul [regsub -all {Unknown Artist - } $judul ""]
set judul [regsub -all {\s+\(Smule\s+Cover\)} $judul ""]
set temp [open backsound.txt r] ; set xx [read $temp] ; close $temp
foreach cuap [string map { "\{" "" "\}" ""} [split $xx "\n"]] {
if {[string match -nocase "*$cuap*" [string tolower $judul]] || [string match -nocase "*on mic*" [string tolower $judul]]} {
   set jud "ＢａｃｋＳｏｕｎｄ"
   return $jud
   }
}
if {[string match *jingle* [string tolower $judul]] || [string match *chating* [string tolower $judul]]} {
   set jud "Ｊｉｎｇｌｅ"
 } else {
   if {[file exists $mp3home/$judul.m4a]} {
	set jud [exec exiftool -Duration -s "$mp3home/$judul.m4a" | sed {s/ //g} | sed {s/Duration:0://g} | sed {s/(approx)//g}]
   } else {
        if {$apikey == "on"} {
	    set jud [mencari $judul]
        } else {
 	    catch {exec yt-dlp -6 --skip-download --no-warnings --get-duration "ytsearch1:$judul"} jud
	    if {[string match *error* [string tolower $jud]]} {
	        set apikey "on"
	        set jud "ｕｎｋｎｏｗｎ"
	        timer 720 [list set apikey "off"]
  	    } else {
	        set jud $jud
   	    }
   	}
   }
 }
 return $jud
}

proc stripkode { text } {

  set text [regsub -all {0} $text "０"]
  set text [regsub -all {1} $text "１"]
  set text [regsub -all {2} $text "２"]
  set text [regsub -all {3} $text "３"]
  set text [regsub -all {4} $text "４"]
  set text [regsub -all {5} $text "５"]
  set text [regsub -all {6} $text "６"]
  set text [regsub -all {7} $text "７"]
  set text [regsub -all {8} $text "８"]
  set text [regsub -all {9} $text "９"]
     return $text
}

proc recode { judul } {

set judul [regsub "http.+$" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "️" $judul ""]
set judul [regsub -all "⚠" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "" $judul ""]
set judul [regsub -all "\#" $judul ""]
set judul [regsub -all "\;" $judul ""]
set judul [regsub -all "\:" $judul ""]
set judul [regsub -all "\"" $judul ""]
set judul [regsub -all "\/" $judul ""]
set judul [regsub -all "\|" $judul ""]
set judul [regsub -all "_" $judul ""]
set judul [regsub -all "," $judul ""]
set judul [regsub -all "\~" $judul ""]
set judul [regsub {^\s+} $judul ""]
set judul [regsub -all {\([OoLV].+?\)} $judul ""]
set judul [regsub -all {\(\s+[OoLV].+?\)} $judul ""]
set judul [regsub {^\(.+?\)\s+} $judul {}]
set judul [regsub {^\(.+?\)} $judul {}]
set judul [regsub -all " OFFICIAL" $judul ""]
set judul [regsub -all " Official" $judul ""]
set judul [regsub -all "official" $judul ""]
set judul [regsub -all {\s+Music\s+Video} $judul ""]
set judul [regsub -all {\s+Video\s+Clip} $judul ""]
set judul [regsub -all {\s+} $judul " "]
set judul [regsub {\s+$} $judul ""]
     return $judul
}

# TRIGGER untuk mengurangi limit request, jika mengubah text playing radio, ini wajib diubah juga
#bind pubm - "*:*muterin*" pub_delreqcount
proc pub_delreqcount {nick uhost hand chan args} {
global radiobotname
set temp [open djnick r] ; set djnick [gets $temp] ; close $temp
	if {$djnick != "EvoChatID"} { putlog "Sedang Live RJ"; return 0 }

	if {$nick == "Radio" && $chan == "#radio"} {
		set jumlah [open "request.count" r+]
		seek $jumlah 0
		if {[gets $jumlah line] > 0} {
			set banyaknya $line
		}
		close $jumlah
		if { $banyaknya == 0 } { return 0 }
			set ln [expr $banyaknya - 1]
			#set ln "0"
			set temp [open "request.count" w+]
			puts $temp $ln
			close $temp
			putlog "Count direset ke 0"
	        set banyaknya ""
	}
}

proc scgreet { nick arg } {
global radiobotname
if {$arg == ""} { putserv "PRIVMSG $radiobotname :bcast %bold$nick%bold Type %bold!message %boldyour message%bold...!! :"; return 0}
global dj 
set temp [open "djnick" r]
set djnick [gets $temp]
close $temp
putserv "privmsg $djnick :Pesan dari $nick : $arg"
 }
proc pub_greet { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreet $nick $arg }}
bind pubm - "* !message *" pubm_greeet
bind pubm - "* .pesan *" pubm_greeet
bind pubm - "* .msg *" pubm_greeet
proc scgreeet { nick arg } {
global radiobotname
global dj 
if {$nick != "xxxx"} { return 0 }
set abc [lindex $arg 0]
if {$arg == ""} { putserv "PRIVMSG $radiobotname :bcast %bold$abc%bold Type %bold!message %boldyour message%bold...!!"; return 0}

set temp [open "djnick" r]
set djnick [gets $temp]
close $temp
set abc [lindex $arg 0]
set crut [lrange $arg 2 end]
putserv "privmsg $djnick :Pesan dari $abc : $crut"
}
proc pubm_greeet { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { scgreeet $nick $arg }}
proc msg_setdj { nick uhost hand arg } { global radiochans; setdj $nick $arg }
proc pub_setdj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { setdj $nick $arg }}
proc msg_setautodj { nick uhost hand arg } { global radiochans; setautodj $nick $arg }
proc pub_setautodj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { setautodj $nick $arg }}
proc djnickchange { oldnick uhost hand chan newnick } {
set temp [open "djnick" r]
set djnick [gets $temp]
close $temp
if {$oldnick == $djnick} {
putlog "shoutcast: dj nickchange $oldnick -> $newnick"
set temp [open "djnick" w+]
puts $temp $newnick
close $temp
}}
proc dj { nick } {
global radiobotname
set target "$nick"
putlog "shoutcast: $target asked for dj info"
if {[file exists dj]} {
set temp [open "dj" r]
set dj [gets $temp]
close $temp
putserv "PRIVMSG $radiobotname :bcast %bold$dj%bold on Turn Table!!!"
 }
  }
proc pub_dj { nick uhost hand chan arg } { global radiochans; if {([lsearch -exact [string tolower $radiochans] [string tolower $chan]] != -1) || ($radiochans == "")} { dj $nick  }}

set channel "#EvoChat"
set time 240
set text { 
"%color12[%color7%boldAPK CiD%bold%color12]%color[ Install APK EvoChatID + Radio Stream di Android kamu via Google PlayStore [search EvoChatID] ]"
"%color12[%color7%boldRadio EvoChatID%bold%color12]%color[ Join Radio ChattingID...!!! Streaming @ http://radio.evochat.co.id:8000/listen.pls [for Winamp,MP,VLC & XiiaLive] or http://www.evochat.co.id [for all Web browser] ]"
}

if {[string compare [string index $time 0] "!"] == 0} { set timer [string range $time 1 end] } { set timer [expr $time * 30] }
if {[lsearch -glob [utimers] "* co *"] == -1} { utimer $timer co }
proc co {} {
  global channel time text timer radiobotname
  foreach chan $channel {
    set line [lindex $text [rand [llength $text]]]
    putserv "PRIVMSG $radiobotname :bcast $line"
  }
  if {[lsearch -glob [utimers] "* co *"] == -1} { utimer $timer co }
}

# Improve Request From Web & App
set output_chan "#dummy" 
# eggdrop port to bind 
set port 1118 
# eggdrop ip to bind 
set host 0.0.0.0
if {![info exists serverSocket]} { set serverSocket [socket -server main -myaddr $host $port] }

proc main { sock host port } { 
        fconfigure $sock -buffering line 
        fileevent $sock readable [action $sock $host $port] 
} 

proc action { chan host port } { 
        global output_chan radiobotname

        if {![eof $chan]} { 
            set soc_data [gets $chan] 

            if {$soc_data != ""} { 
				set singreq [lindex $soc_data end] 
				set lagun [regsub -all $singreq $soc_data ""]
                set reqglobal [regsub -all "@" $singreq " "]
				
                set reqnick [lindex $reqglobal 0]
                set reqvia [lindex $reqglobal 1]
         		regsub -all "!request " $lagun "" lagune
				regsub -all ".request " $lagune "" lagune
				######### Add Limit request by requestby.txt length by Jaka 07-01-2021 ###
				
				set fid [open "requestby.txt" r]
				set data [read $fid [file size "requestby.txt"]]
				set lineCount [llength [split $data "\n"]]

				if {$lineCount >= 8} {
					putserv "PRIVMSG $output_chan :$reqnick trying to req via web but limited : $banyaknya request"
					putserv "PRIVMSG #radio :maaf $reqnick dari website, gantian reqnya ya : $banyaknya request"
					return 0
				}
				############################################################################
                if {[string match *request* $soc_data]} {
        			putquick "PRIVMSG $output_chan :$reqnick via $reqvia Request: $lagune" 
					putquick "PRIVMSG $radiobotname :$reqnick Request: %bold$lagune%bold ($reqvia)"
					putlog "$singreq $lagune"
					request $singreq $lagune
                }
                if {[string match *pesan* $soc_data]} {
                    set greetarg "$lagune ($reqvia)"
                    putquick "PRIVMSG $output_chan :$reqnick via $reqvia Request: $lagune"
					scgreet $reqnick $greetarg
                }
        

           } 
        } { 
                close $chan 
        } 
} 

proc mencari {judule} {
	global key key1

	set judule [regsub -all {Unknown Artist - } $judule ""]
	set judule [regsub -all {\s+\(Smule\s+Cover\)} $judule ""]
	regsub -all -- "\[^A-Za-z0-9\]" $judule " " judule
	set arg [url_encode $judule]
	set arg [string map {{"} {'} {`} {'}} $arg]
	set url "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id(videoId))&type=video&maxResults=1&key=$key&q=$arg"
	http::register https 443 [list ::tls::socket -autoservername true]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set token [http::geturl $url -timeout 10000]
	set status [http::status $token]
	set rawpage [http::data $token]
	http::cleanup $token
	http::unregister https

putlog "Pencarian Title($status)"
	if {[string match *errors* [string tolower $rawpage]]} {
	  set judule "ｕｎｋｎｏｗｎ"
	  set key $key1
	} else {
	  set ids [dict get [json::json2dict $rawpage] items]
	  set id [lindex $ids 0 1 1]
	  if {$id == ""} {
	     set judule "ｕｎｋｎｏｗｎ"
	     set key $key1
	  } else {
	     set judule [autoinfo $id]
	  }
	}
putlog "Durasi Title($judule)"
return $judule
}

proc autoinfo {id} {
	global key
	set url "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$key&part=contentDetails&fields=items(contentDetails(duration))"
	http::register https 443 [list ::tls::socket -autoservername true]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set token [http::geturl $url -timeout 10000]
	set status [http::status $token]
	set rawpage [http::data $token]
	http::cleanup $token
	http::unregister https
putlog "INFO($status)"

	if {[string match *errors* [string tolower $rawpage]]} {
	   set jud "ｕｎｋｎｏｗｎ"
        } else {
	   set ids [dict get [json::json2dict $rawpage] items]
	   set durasi [lindex $ids 0 1 1]
	 if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	 } else {
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {H|M} $durasi ":" durasi
	   if {[string index $durasi end-0] == ":" } {
		set jud "${durasi}00"
	   } elseif {[string index $durasi end-1] == ":" } {
		set jud "${durasi}0"
	   } else {
		set jud $durasi
	   }
       }
     }
  return $jud
}

proc url_encode {str} {
	set str [string map {"&" "&amp;" "<" "&lt;" ">" "&gt;"} $str]
	set chRE {[^-A-Za-z0-9._~\n]};		# Newline is special case!
	set replacement {%[format "%02X" [scan "\\\0" "%c"]]}
	return [string map {"\n" "%0A"} [subst [regsub -all $chRE $str $replacement]]]
}

### Add 16 Dec 2018 by J
### Auto del song after 2 hour to reduce diskspace
proc delagu { nick judul } {
	global mp3home output_chan radiobotname
   if {[file exists $mp3home/$judul] == 1} {
	exec rm -f $mp3home/$judul

	putserv "PRIVMSG $radiobotname :!autodj-reload"
	#puthelp "PRIVMSG Monitor :.out File $judul telah dihapus (expired 180 menit)"
   putlog "File $judul telah dihapus (expired 240 menit)"
   }
}

### Shoutcast Check ip/app/duration Listener ###
set passadmin "susuperawan"
set stream "http://127.0.0.1:8000"

bind pub f .ceklis ceklis
proc ceklis {nick uhost hand chan arg} {
global passadmin stream RJChan
if {$chan != $RJChan} { return 0 }
set link "$stream/admin.cgi?sid=1&pass=$passadmin&mode=viewjson&page=3"
set dataq [http::config -useragent "Mozilla/5.0 (X11; CrOS x86_64 14092.57.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.85 Safari/537.36"]
set dataq [::http::geturl $link] 
set data [http::data $dataq]
::http::cleanup $dataq
set ids [json::json2dict $data]
if {[llength $ids] == 0 } { putquick "NOTICE $nick :Tidak ada Yg Listen"; return 0 }
for {set i 0} {$i < [llength $ids]} {incr i} {
set host [lindex $ids $i 1]
set app [lindex $ids $i 3]
set dur [lindex $ids $i 5]
set jam [expr {int($dur) / 3600}]; set menit  [expr {int($dur) / 60 % 60}]; set detik  [expr {int($dur) % 60}]
set hasil "1IP 5\[12$host5\]1 Stream With 5\[3$app5\]1 Stream Durasi 5\[6[format "%02d:%02d:%02d" $jam $menit $detik]5\]"
foreach line [split $hasil "\n" ] {
puthelp "NOTICE $nick :$line"
}}}

bind pub - .playlist playlist

set delay(rest) 10
proc playlist {nick uhost hand chan arg} {
 global delay
    if {[info exists delay(protection)]} {
        set rest [expr [clock seconds] - $delay(protection)]
        if {$rest < $delay(rest)} {
	    puthelp "NOTICE $nick :Tunggu \00304\002[expr $delay(rest) - $rest]\002\017 Second(s) untuk melihat Playlist"
            return 0
        }
        catch { unset rest }
    }
    set delay(protection) [clock seconds]
set oleng [open requestby.txt r] ; set play [read $oleng] ; close $oleng
if {$play == ""} { putquick "NOTICE $nick :Playlist Kosong"; return 0 }
foreach si [split [string map {"/home/radio/mp3/" "\00312==> \017" ".m4a" ""} $play] "\n"] {
puthelp "NOTICE $nick :$si"
 }
}

proc susunan {} {
 global antrian
set temp [open antri.txt r] ; set antri [gets $temp] ; close $temp
putlog "cek request"
if {$antri == ""} {
   catch { unset antrian }
 } else {
   set nick [lindex $antri 0]
   set arg [lrange $antri 1 end]
   catch {exec sed -i "1d" antri.txt}
   pub_get $nick $arg
 }
}

bind pub m .find pencarian
bind pub m !find pencarian
bind pub m !del setip
bind pub m .del setip

proc pencarian {nick uhost hand chan arg} {
	global RJChan mp3home
	if {$chan != $RJChan} { return 0 }
	if {[string length $arg] < 2} { puthelp "NOTICE $nick :Minimum 2 characters untuk find" ; return 0 }
	if {[lindex $arg 0] == ""} { puthelp "NOTICE $nick :ketik .find <filenames>" ;return 0 }
	set files ""
	foreach f [glob -directory $mp3home -type f *] {
		if {[string match -nocase "*$arg*" $f]} {
			lappend files [file tail $f] 
		}
	}
         foreach susu [file join $files] {
        if {[string  match -nocase "*$arg*" $susu]} {
	set ukuran [file size "$mp3home/$susu"]
	set size [fixform $ukuran]
         putserv "privmsg $chan :$susu  \00314\002\[\002$size\002\]\002 "
      } else {
		putserv "privmsg $chan :zonk"
      }
   }
}

proc setip {nick uhost hand chan arg} {
 global RJChan mp3home
if {$chan != $RJChan} { return 0 }
set file [string range [join [lrange [split $arg] 0 end]] 0 end]
set oleng [open requestby.txt r] ; set play [read $oleng] ; close $oleng
foreach asu [split $play "\n"] {
regsub {^.+?\/home\/radio\/mp3\/} $asu {} asu
  if {[string match -nocase $asu $file]} { putquick "NOTICE $nick :Oops.. File yang ada Playlist tidak dapat dihapus"; return 0 }
}
if {[file exists $mp3home/$file]} {
    delagu $nick $file
    puthelp "PRIVMSG $chan :$file \00304Dihapus"
  } else {
    puthelp "NOTICE $nick :File tidak ada"
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

proc cekplelis {judul} {
 global radiobotname
set temp [open djnick r] ; set djnick [gets $temp] ; close $temp
if {$djnick != "EvoChatID"} {
   ceklegth $judul
 } else {
   puthelp "PRIVMSG $radiobotname :!request $judul.m4a"
 }
}

proc ceklegth {judul} {
set oleng [open requestby.txt r] ; set play [read $oleng] ; close $oleng
set fade [llength [split $play "\n"]]
set fod [expr $fade - 1 ]
catch {exec sed -n "$fod{p}" requestby.txt} requ
set final [lrange [string map {"/home/radio/mp3/" "" ".m4a" ""} $requ] 1 end]
if {$judul == $final} { catch {exec sed -i "$fod{d}" requestby.txt} }
}

bind msg n .dur apisearch
proc apisearch {nick uhost hand rest} {
set judul [lrange [split $rest] 0 end]
putquick "privmsg $nick :[mencari $judul]"
}
bind msg f !xbas8d reqpm
proc reqpm { nick uhost hand rest } {
global radiobotname
if {$nick != "XbaSs8D"} { return 0 }
set temp [open "djnick" r]; set djnick [gets $temp]; close $temp
if {$djnick == "EvoChatID"} {
set nama [lindex $rest 0]
set arg [lindex $rest 1]
request $nama $arg
} else {
putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Saat Ini Sedang bukan AutoRJ"
}
}

proc xbas {nick arg} {
global mp3home radiobotname oldjudul cekjudul
   set link [lindex $arg 0]
   set judul [string map { "%20" " " ".mp3" ""} $link]
   set judul [regsub "http:\/\/forchat.my.to\/mp3\/" $judul ""]
if {$oldjudul == $judul} {
    putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Anda Request lagu yang sama dari sebelumnya"
    susunan
    return 0
} elseif {$cekjudul == $judul} {
    putquick "PRIVMSG $radiobotname :raw NOTICE $nick :Oops.. Lagu yang anda request sedang diPlay"
    susunan
    return 0
} else {
putquick "PRIVMSG $radiobotname :bcast $nick Request: %color10$judul%color"
set oldjudul "$judul"
if {[file exists $mp3home/$judul.m4a]} { putserv "PRIVMSG $radiobotname :!request $judul.m4a"; exec echo "$nick $mp3home/$judul.m4a" >> requestby.txt; return 0 }
catch {exec wget -U "Mozilla/5.0 (X11; CrOS x86_64 14092.57.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.85 Safari/537.36" $link -O "$mp3home/$judul.m4a"} runcmd
if {[string match *error* [string tolower $runcmd]]} { putlog "GAGAL Download"; exec rm -f "$mp3home/$judul.m4a"; susunan; return 0 }
  exec echo "$nick $mp3home/$judul.m4a" >> requestby.txt
  putserv "PRIVMSG $radiobotname :!autodj-reload"
  utimer 4 [list cekplelis $judul]
timer 242 [list delagu $nick $judul.m4a]
 }
}

bind msg n "record" merekam
set wis(juh) 10
proc merekam {nick host hand rest} {
 global RJChan radiobotname wis
    if {[info exists wis(protection)]} {
        set juh [expr [clock seconds] - $wis(protection)]
        if {$juh < $wis(juh)} {
		putlog "diblok"
            return 0
        }
        catch { unset juh }
    }
    set wis(protection) [clock seconds]
if {$nick != $radiobotname} { return 0 }
if {[lindex $rest 0] == ""} {
set temp [open djnick r] ; set djnick [gets $temp] ; close $temp
::stoprekam $djnick $RJChan 1
} else {
set temp [open djnick r] ; set djnick [gets $temp] ; close $temp
if {[lindex $rest 0] == "EvoChatID"} {
   ::stoprekam $djnick $RJChan 1
  } else {
   ::startrekam $djnick $RJChan ""
  }
 }
}


bind pub f .top toprjs
proc toprjs {nick uhost hand chan arg} {
 global RJChan
if {$chan != $RJChan} { return 0 }
::toprjnick $nick $chan $arg
}

proc rjcheck {} {
 global stream
set link "$stream/stats?json=1"
set dataq [http::config -useragent "Mozilla/5.0 (X11; CrOS x86_64 14092.57.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.85 Safari/537.36"]
set dataq [::http::geturl $link] 
set data [http::data $dataq]
::http::cleanup $dataq
set ids [json::json2dict $data]

set djcek [lindex $ids 23]
return $djcek
}

putlog "ChatingID.tcl loaded"


