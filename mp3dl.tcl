package require http
package require tls

setudef flag mp3

set tube(rest) 35

set linkdl "http://69.85.88.188/download"

set path "/var/www/html/download"
set piles "/home/abocy"

bind pub - .dl mptiga
bind pub n .update liat_versi
bind pubm - "* on" pub_on
bind pubm - "* off" pub_off
bind msg - block msg_blok
bind msg - unblock msg_unblok
bind pubm - "* blocklist" daftar_ignore
bind pubm - "* help" daftar_help

proc mptiga { nick host hand chan text } {
	global botnick tube
	if {![channel get $chan mp3]} { return 0 }
	if {[lindex $text 0] == ""} {
        puthelp "privmsg $nick :Type \002$botnick help\002 for commands list."
        return 0
    }
    if {[string match "*/ensembles" [lindex $text 0]]} { return 0 }
    if {[info exists tube(protection)]} {
        set rest [expr [clock seconds] - $tube(protection)]
        if {$rest < $tube(rest)} {
            puthelp "NOTICE $nick :Wait [expr $tube(rest) - $rest] second(s)."
            return 0
        }
        catch { unset rest }
    }
    set tube(protection) [clock seconds]
    if {[string match "https://www.smule.com/p/*" [lindex $text 0]] || [string match "https://www.smule.com/recording/*/*" [lindex $text 0]]} {
	pub_smule $nick $host $hand $chan $text
    } elseif {[string match "https://link.smule.com/*" [lindex $text 0]]} {
        pub_redirect $nick $host $hand $chan $text
    } elseif {[string match "*youtube.com*" [lindex $text 0]] || [string match "*youtu.be*" [lindex $text 0]] || [string match "*soundcloud.com*" [lindex $text 0]]} {
        pub_getylink $nick $host $hand $chan $text
    } else {
        pub_get $nick $host $hand $chan $text
    }
}
proc pub_get {nick host hand chan text } {
	global path linkdl piles
	if {[string match "*http*" [lindex $text 0]]} { return 0 }
	putquick "privmsg $chan : 14Sedang Diproses..."
	set wadul [lrange $text 0 end]
   catch {exec youtube-dl --skip-download --no-warnings --get-id --get-duration --restrict-filenames --get-filename -o "%(title)s" "ytsearch1:$wadul"} report
   foreach {id namafile durasi} [split $report "\n"] {
   set jadul [string map {{_} { }} $namafile]
   set yturl "https://youtu.be/$id"
   if {[string match -nocase "*ERROR:*" $id]} { puthelp "PRIVMSG $nick :$id" ; return 0 }
   if {[string match -nocase "*ERROR:*" $namafile] || [string match -nocase "*WARNING:*" $namafile]} { puthelp "PRIVMSG $nick :$namafile" ; return 0 }
   if {[string match -nocase "*ERROR:*" $durasi]} { puthelp "PRIVMSG $nick :$durasi" ; return 0 }
   if {$durasi == "0"} { puthelp "PRIVMSG $nick :Stream not allowed" ;return 0 }
   }
   regsub -all " " $jadul "_" judul
   regsub -all {\[} $judul "(" judul1
   regsub -all {\]} $judul1 ")" judul2
   regsub -all {\|} $judul2 "" judul3
   regsub -all {\/} $judul3 "_" judul4
   regsub -all {\'} $judul4 "" judul5
   regsub -all {\`} $judul5 "" judul6
   regsub -all {\#} $judul6 "" judul7
   regsub -all {\"} $judul7 "" judulbaru
   catch {exec youtube-dl $yturl --no-part --no-playlist --youtube-skip-dash-manifest --max-filesize 30000000 -x -o "$path/$judulbaru.%(ext)s" --audio-format mp3 --postprocessor-args "-ar 44100" --add-metadata --metadata-from-title "%(artist)s - %(title)s"} runcmd
   set f [open "a.txt" a+]
   puts $f $runcmd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line] || [string match *max-filesize* $line]} {
           puthelp "privmsg $nick :4ERROR max durasi 30menit"
	   exec rm -f "$path/$judulbaru.webm"
	   exec rm -f "$path/$judulbaru.mp4"
	   exec rm -f "$path/$judulbaru.m4a"
           exec rm -f $piles/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/$judulbaru.mp3"]
    set besar [fixform $ukuran]
   puthelp "privmsg $chan : 14Download Link: 12$linkdl/$judulbaru.mp3 14\[Size: 1\002$besar\00214\] \[Duration: 1\002$durasi menit\00214\]"
   puthelp "privmsg $chan : 14Anda punya waktu 20menit untuk download"
   timer 20 [list hapus $chan $judulbaru]
   exec rm -f $piles/eggdrop/a.txt
}
proc pub_getylink {nick host hand chan text } {
	global path linkdl piles
   set getlink [lindex $text 0]
   set lonk [regsub "&list=.+$" $getlink ""]
	putquick "privmsg $chan : 14Sedang Diproses..."
   catch {exec youtube-dl $lonk --skip-download --no-warnings --get-duration --restrict-filenames --get-filename -o "%(title)s"} report
   foreach {namafile durasi} [split $report "\n"] {
   set jadul [string map {{_} { }} $namafile]
   if {[string match -nocase "*ERROR:*" $namafile] || [string match -nocase "*WARNING:*" $namafile]} { puthelp "PRIVMSG $nick :$namafile" ; return 0 }
   if {[string match -nocase "*ERROR:*" $durasi]} { puthelp "PRIVMSG $nick :$durasi" ; return 0 }
   if {$durasi == "0"} { puthelp "PRIVMSG $nick :Stream not allowed" ;return 0 }
   }
   regsub -all " " $jadul "_" judul
   regsub -all {\[} $judul "(" judul1
   regsub -all {\]} $judul1 ")" judul2
   regsub -all {\|} $judul2 "" judul3
   regsub -all {\/} $judul3 "_" judul4
   regsub -all {\'} $judul4 "" judul5
   regsub -all {\`} $judul5 "" judul6
   regsub -all {\#} $judul6 "" judul7
   regsub -all {\"} $judul7 "" judul8
   regsub -all "___" $judul8 "_" judul9
   regsub -all "__" $judul9 "_" judulbaru
   catch {exec youtube-dl --no-part --max-filesize 30000000 $lonk -x --audio-format mp3 --postprocessor-args "-ar 44100" -o "$path/$judulbaru.%(ext)s" --add-metadata --metadata-from-title "%(artist)s - %(title)s"} runcmd
   set f [open "a.txt" a+]
   puts $f $runcmd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line] || [string match *max-filesize* $line]} {
           puthelp "privmsg $nick :4ERROR max durasi 30menit"
	   exec rm -f "$path/$judulbaru.webm"
	   exec rm -f "$path/$judulbaru.mp4"
	   exec rm -f "$path/$judulbaru.m4a"
           exec rm -f $piles/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/$judulbaru.mp3"]
    set besar [fixform $ukuran]
   puthelp "privmsg $chan : 14Download Link: 12$linkdl/$judulbaru.mp3 14\[Size: 1\002$besar\00214\] \[Duration: 1\002$durasi menit\00214\]"
   puthelp "privmsg $chan : 14Anda punya 20menit untuk download"
   timer 20 [list hapus $chan $judulbaru]
   exec rm -f $piles/eggdrop/a.txt
}

proc pub_smule {nick host hand chan text } {
   global path linkdl
   if {[lindex $text 1] == ""} {
	putquick "privmsg $chan : 14Sedang Diproses..."
	set judul [lindex $text 0]
	regexp -nocase {/(\d+_\d+)} $judul match title

   set url "https://www.smuledownloader.download/p/$title"
   http::register https 443 [list ::tls::socket -autoservername true]
   set token [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https
   puts $status
   
    set l [regexp -all -inline -- {<meta property="og:description" content="Get Smule Performace : (.*?) on Smule. Sing with lyrics to your favorite karaoke} $data]
    set f [regexp -all -inline -- {<div id=audiolink><p><a href="(.*?)"} $data]

if {[llength $f] == 0} { puthelp "privmsg $chan :4Link Smule tidak valid "; return 0 }
     foreach {black b} $f {
         set b [string trim $b " \n"]

         regsub -all {<.+?>} $b {} b


        #striphtml $b
        set kumpulin1 "$b"
        append muncrat1 $kumpulin1
	regsub -all {\"} $muncrat1 "" link
        }
     foreach {black a} $l {
         set a [string trim $a " \n"]

         regsub -all {<.+?>} $a {} a
	 regsub -all "&#x27;" $a "'" a
	 regsub -all "&amp;" $a "and" a
	 regsub -all "&apos;" $a "'" a

	regsub -all -- "\[^A-Za-z0-9'\]" $a " " a1
	regsub -all "recorded" $a1 "" a2
	regsub -all {\s+} $a2 " " a3
	regsub {^\s+} $a3 "" a4
	regsub {\s+$} $a4 "" aa
        set kumpulin "$aa"
        append moncrot $kumpulin
	regsub -all " " $moncrot "_" fail
	regsub -all "'" $fail "" muncrat
	}

	catch [list exec ffmpeg -y -loglevel repeat+info -i $link -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$moncrot $path/$muncrat.mp3]
	set ukuran [file size "$path/$muncrat.mp3"]
	set besar [fixform $ukuran] 
	set panjang [exec exiftool -Duration -s "$path/$muncrat.mp3" | sed {s/ //g} | sed {s/Duration://g} | sed {s/(approx)//g} | sed {s/0://g}]
       puthelp "privmsg $chan : 14Download Link: 12$linkdl/$muncrat.mp3 14\[Size: 1\002$besar\00214\] \[Duration: 1\002$panjang menit\00214\]"
       puthelp "privmsg $chan : 14Anda punya 15menit untuk download"
       timer 15 [list busak $chan $muncrat]
} else {
	putquick "privmsg $chan : 14Sedang Diproses...."
	set judul [lindex $text 0]
	set title [lrange $text 1 end]
	regexp -nocase {/(\d+_\d+)} $judul match titles

   set url "https://www.smuledownloader.download/p/$titles"
   http::register https 443 [list ::tls::socket -autoservername true]
   set token [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https
   puts $status
    set f [regexp -all -inline -- {<div id=audiolink><p><a href="(.*?)"} $data]
if {[llength $f] == 0} { puthelp "privmsg $chan :4Link Smule tidak valid "; return 0 }
     foreach {black b} $f {
         set b [string trim $b " \n"]

         regsub -all {<.+?>} $b {} b


        #striphtml $b
        set kumpulin1 "$b"
        append muncrat1 $kumpulin1
	regsub -all {\"} $muncrat1 "" moncrot1
        }
	regsub -all " " $title "_" final
	catch [list exec ffmpeg -y -loglevel repeat+info -i $moncrot1 -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$title $path/$final.mp3]
	set ukuran [file size "$path/$final.mp3"]
	set besar [fixform $ukuran]
	set panjang [exec exiftool -Duration -s "$path/$final.mp3" | sed {s/ //g} | sed {s/Duration://g} | sed {s/(approx)//g} | sed {s/0://g}]
       puthelp "privmsg $chan : 14Download Link: 12$linkdl/$final.mp3 14\[Size: 1\002$besar\00214\] \[Duration: 1\002$panjang menit\00214\]"
       puthelp "privmsg $chan : 14Anda punya 15menit untuk download"
       timer 16 [list busek $chan $final]
   }
}
proc pub_redirect {nick host hand chan text } {
   global path linkdl tube
   if {[lindex $text 1] == ""} {
	putquick "privmsg $chan : 14Sedang Diproses..."
	set juduls [lindex $text 0]
   regsub -all ":" $juduls "%3A" juduls1
   regsub -all "/" $juduls1 "%2F" juduls2

   set urel "https://sing.salon/smule-downloader/?url=$juduls2"
   http::register https 443 [list ::tls::socket -autoservername true]
   set token [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
   set token [http::geturl $urel -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https
   puts $status
   set cek "$status"
   if {$cek == "timeout"} { puthelp "privmsg $nick :4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset tube(protection) }; return 0 }
   set titled ""
   regexp -nocase {<p>Description: (.*?) on Smule. Sing with lyrics to your favorite karaoke songs.} $data match titled
   set titled [regsub -all {&#x27;} $titled "'"]
   set titled [regsub -all {amp;} $titled ""]
   set titled [regsub -all {&apos;} $titled "'"]
   set titled [regsub -all -- "\[^A-Za-z0-9'&\]" $titled " "]
   set titled [regsub -all "recorded" $titled ""]
   set titled [regsub -all {\s+} $titled " "]
   set titled [regsub {^\s+} $titled ""]
   set titled [regsub {\s+$} $titled ""]

   set linkd ""
   regexp -nocase {<a class="ipsButton ipsButton_medium ipsButton_important" href="(.*?)" download="} $data match linkd
   set linkd [regsub -all -nocase {\s+} $linkd " "]
   set linkd [regsub -all "amp;" $linkd ""]
if {[llength $linkd] == 0} { puthelp "privmsg $nick :4Link Smule tidak valid "; return 0 }
utimer 30 [list pub_ganti $linkd $titled $nick $chan]
} else {
	putquick "privmsg $chan : 14Sedang Diproses...."
	set juduls [lindex $text 0]
	set titled [lrange $text 1 end]
   regsub -all ":" $juduls "%3A" juduls1
   regsub -all "/" $juduls1 "%2F" juduls2

   set urel "https://sing.salon/smule-downloader/?url=$juduls2"
   http::register https 443 [list ::tls::socket -autoservername true]
   set token [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
   set token [http::geturl $urel -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https
   puts $status
   set cek "$status"
   if {$cek == "timeout"} { puthelp "privmsg $nick :4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset tube(protection) }; return 0 }
   set linkd ""
   regexp -nocase {<a class="ipsButton ipsButton_medium ipsButton_important" href="(.*?)" download="} $data match linkd
   set linkd [regsub -all -nocase {\s+} $linkd " "]
   set linkd [regsub -all "amp;" $linkd ""]
if {[llength $linkd] == 0} { puthelp "privmsg $nick :4Link Smule tidak valid "; return 0 }
utimer 30 [list pub_ganti $linkd $titled $nick $chan]
}}

proc pub_ganti {linkd titled nick chan } {
   global path linkdl tube

   set url1 $linkd
   http::register https 443 [list ::tls::socket -autoservername true]
   http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
   set tok [http::geturl $url1 -timeout 10000]
   set status1 [http::status $tok]
   set data1 [http::data $tok]
   http::cleanup $tok
   http::unregister https
   puts $status1
   set cek "$status1"
   if {$cek == "timeout"} { puthelp "privmsg $nick :4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset tube(protection) }; return 0 }
   set fid [open "data2.txt" w] ; puts $fid $data1 ; close $fid
   set fp [open "data2.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *<h1>502* $line]} {
           puthelp "privmsg $nick :4Redirect Error: 502 Bad Gateway"
	   close $fp
	   exec rm -f data2.txt
           return 0
       }
    }
    close $fp
    exec rm -f data2.txt

   set redirect ""
   regexp -nocase {<html><body>You are being <a href="(.*?)">redirected</a>.</body></html>} $data1 match redirect
   set redirect [regsub -all -nocase {\s+} $redirect " "]
   set redirect [regsub -all -nocase "c-ash.smule.com" $redirect "c-sg.smule.com"]

   regsub -all " " $titled "_" final1
   regsub -all "'" $final1 "" final
   catch [list exec ffmpeg -y -loglevel repeat+info -i $redirect -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$titled $path/$final.mp3]
   set ukuran [file size "$path/$final.mp3"]
   set besar [fixform $ukuran]
   set panjang [exec exiftool -Duration -s "$path/$final.mp3" | sed {s/ //g} | sed {s/Duration://g} | sed {s/(approx)//g} | sed {s/0://g}]
   puthelp "privmsg $chan : 14Download Link: 12$linkdl/$final.mp3 14\[Size: 1\002$besar\00214\] \[Duration: 1\002$panjang menit\00214\]"
   puthelp "privmsg $chan : 14Anda punya 15menit untuk download"
   timer 17 [list busek $chan $final]
}
proc busak {chan muncrat} {
	global path
	if {[file exists $path/$muncrat.mp3] == 1} {
		exec rm -f $path/$muncrat.mp3
		puthelp "PRIVMSG $chan :File\002 $muncrat.mp3 \002Di Hapus."
	}
}

proc busek {chan final} {
	global path
	if {[file exists $path/$final.mp3] == 1} {
		exec rm -f $path/$final.mp3
		puthelp "PRIVMSG $chan :File\002 $final.mp3 \002Di Hapus."
	}
}

proc daftar_help {nick host hand chan text} {
	global botnick
	if {[lindex $text 0] != $botnick} { return 0 }
	if {[channel get $chan mp3]} {
	puthelp "PRIVMSG $nick :Mp3 Commands:"
	puthelp "PRIVMSG $nick :\002.dl <artis - judul>\002 | Example: .dl dewa - dewi"
	puthelp "PRIVMSG $nick :\002.dl <link>\002 | Example: .dl https://www.youtube.com/watch?v=2y-aB3VAaB8"
	puthelp "PRIVMSG $nick :\002.dl <link>\002 | Example: .dl https://www.smule.com/p/508198506_3031557831"
	puthelp "PRIVMSG $nick :\002.dl <link> <artis - judul>\002 | Example: .dl https://www.smule.com/p/508198506_3031557831 <artis - judul>"
	puthelp "PRIVMSG $nick :-"
	puthelp "PRIVMSG $nick :Owner Commands:"
	puthelp "PRIVMSG $nick :\002<botnick> on\002 | Activate the bot."
	puthelp "PRIVMSG $nick :\002<botnick> off\002 | Deactivate the bot."
	puthelp "PRIVMSG $nick :\002<botnick> blocklist\002 | Ignore list."
	puthelp "PRIVMSG $nick :Private Message Commands:"
	puthelp "PRIVMSG $nick :\002block <nick/hostname>\002 | Block user."
	puthelp "PRIVMSG $nick :\002unblock <hostname>\002 | Unblock user."
 }
}

proc msg:userhost {nick host hand rest} {
	global botnick
	bind RAW - 311 user:host
	bind RAW - 402 user:nosuch
	set target [lindex $rest 0]
	set ::nickreq $nick
	set ::whoistarget $target
	putquick "whois $target $target"
}
proc user:host {from key args} {
	set nick [lindex [split $args] 1]
	set ident [lindex [split $args] 2]
	set host [lindex [split $args] 3]
	set hostname "$nick!$ident@$host"
	set nick $::nickreq
	if {[isignore $hostname]} { puthlp "NOTICE $nick :$hostname has been ignored." ; return 0 }
	newignore $hostname $nick "*" 0
	puthlp "NOTICE $nick :Ignoring $hostname"
	unbind RAW - 311 user:host
}
proc user:nosuch { from key args } {
	set target $::whoistarget
	set nick $::nickreq
	putquick "NOTICE $nick :$target not online. Use: \002block <hostname>\002"
	unbind RAW - 402 user:nosuch
}
proc msg_blok {nick host hand rest} {
	global botnick
	if {![matchattr $nick n]} { puthlp "NOTICE $nick :Access Denied!!!" ; return 0 }
	if {![string match *!* [string tolower $rest]] && ![string match *@* [string tolower $rest]]} {
		msg:userhost $nick $host $hand $rest
		return 0
	}
	set rest [lindex $rest 0]
	if {[isignore $rest]} { puthlp "NOTICE $nick :$rest has been ignored." ; return 0 }
	if {$rest == "*!*@*"} { puthlp "NOTICE $nick :Ilegal Hostmask." ; return 0 }
	set usenick [finduser $rest]
	if {$usenick != "*" && [matchattr $usenick f]} { puthlp "NOTICE $nick :FAILED!!!. $rest is in friend list" ; return 0 }
	if {$rest != $nick} { newignore $rest $nick "*" 0 ; puthlp "NOTICE $nick :Ignoring $rest" }
}
proc msg_unblok {nick host hand rest} {
	global botnick
	if {![matchattr $nick n]} { puthlp "NOTICE $nick :Access Denied!!!" ; return 0 }
	set hostmask [lindex $rest 0]
	set nick $::nickreq
	if {![isignore $hostmask]} { puthlp "NOTICE $nick :$hostmask already ignored." ; return 0 }
	if {[isignore $hostmask]} { killignore $hostmask ; puthlp "NOTICE $nick :Unignoring \002\[\002${hostmask}\002\]\002" ; saveuser }
}
proc daftar_ignore {nick host hand chan text} {
	global botnick
	if {![matchattr $nick n]} { puthlp "NOTICE $nick :Access Denied!!!" ; return 0 }
	if {[lindex $text 0] != $botnick} { return 0 }
	if {![matchattr $nick n]} {
		putquick "NOTICE $nick :Access Denied!!!"
		return 0
	}
	if {[ignorelist]==""} {
		puthelp "NOTICE $nick :Ignore list is empty."
		return 0
	}
	foreach x [ignorelist] {
		puthelp "NOTICE $nick :Ignore List"
		puthelp "NOTICE $nick :$x"
	}
	puthelp "NOTICE $nick :Finish"
}
proc hapus {chan judulbaru} {
	global path
	if {[file exists $path/$judulbaru.mp3] == 1} {
		exec rm -f $path/$judulbaru.mp3
		puthelp "PRIVMSG $chan :File\002 $judulbaru.mp3 \002has been deleted."
	}
}
proc pub_on {nick uhost hand chan arg} {
	global botnick
	if {[lindex $arg 0] != $botnick} { return 0 }
	if {![matchattr $nick n]} {
		putquick "NOTICE $nick :Access Denied!!!"
		return 0
	}
	if {[lindex $arg 0] != $botnick} { return 0 }
	if {[channel get $chan mp3]} {
		puthelp "NOTICE $nick :Already Opened"
		return 0
	}
	channel set $chan +mp3
	putquick "PRIVMSG $chan :Mp3 dan Smule downloader \002ACTIVATED\002"
}
proc pub_off {nick uhost hand chan arg} {
	global botnick
	if {[lindex $arg 0] != $botnick} { return 0 }
	if {![matchattr $nick n]} {
		putquick "NOTICE $nick :Access Denied!!!"
		return 0
	}
	if {[lindex $arg 0] != $botnick} { return 0 }
	if {![channel get $chan mp3]} {
		puthelp "NOTICE $nick :Already Closed"
		return 0
	}
	channel set $chan -mp3
	putquick "PRIVMSG $chan :-= Non Aktif =-"
}

proc liat_versi {nick host hand chan text} {
	set versiakhir ""
	set myversi [exec youtube-dl --version]
	set dlurl "https://ytdl-org.github.io/youtube-dl/download.html"
	http::register https 443 ::tls::socket
	
	set tok [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
	set tok [::http::geturl $dlurl]
	set data [::http::data $tok]
	http::cleanup $tok
	http::unregister https
	
	regexp -nocase {<h2>(.*?)>} $data versiakhir
	
	regsub -all "<h2>" $versiakhir "" versiakhir
	regsub -all "<a href=" $versiakhir "" versiakhir
	regsub -all ">" $versiakhir "" versiakhir
	regsub -all {"} $versiakhir {} versiakhir
	regsub -all "https://yt-dl.org/downloads/" $versiakhir "" versiakhir
	regsub -all "/youtube-dl" $versiakhir "" versiakhir
	
	if {[regexp -all -line $myversi $versiakhir]} {
		puthelp "PRIVMSG $chan :YOUTUBE-DL version is: \002$myversi\002 (Latest version)"
		return 0
	} else {
		puthelp "PRIVMSG $chan :YOUTUBE-DL version is: \002$myversi\002 (Updating a new version \002$versiakhir\002)"
		catch {exec youtube-dl -U} updated
		foreach updt [split $updated "\n"] {
			if {[string match -nocase "*installed youtube-dl with a package*" [string tolower $updt]]} {
				catch {exec pip install --upgrade youtube-dl} updatedd
				set lastversi [exec youtube-dl --version]
				if {[regexp -all -line $lastversi $versiakhir]} {
					puthelp "PRIVMSG $chan :Done. (Updated to. \002$lastversi\002)"
				} else {
					puthelp "PRIVMSG $chan :$updatedd"
				}
			} elseif {[string match $versiakhir $updt]} {
				puthelp "PRIVMSG $chan :Done. (Updated to.\002$versiakhir\002)"
			} else {
				puthelp "PRIVMSG $chan :$updt"
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
