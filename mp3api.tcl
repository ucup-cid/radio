if {![string match 1.8.* $version]} { putlog " update your eggdrop"; die "update your system" }
if {![catch {variable tlsVersion [package require tls]}]} { if {[package vcompare $tlsVersion 1.7.20] < 0} { putlog "update your system"; die "update your system" }}

package require json
package require http
package require tls

set key "APIKEY YOUTUBE"

setudef flag mp3

set tube(rest) 30

set linkdl "http://206.253.166.246/~ucup"

set path "/home/ucup"

bind pub - .dl mptiga
bind pub n .update liat_versi
bind pubm - "* on" pub_on
bind pubm - "* off" pub_off
bind msg - block msg_blok
bind msg - unblock msg_unblok
bind pubm - "* blocklist" daftar_ignore
bind pubm - "* help" daftar_help

set apis "1"

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
    if {[string match "https://www.smule.com/*/*" [lindex $text 0]] || [string match "https://www.smule.com/recording/*/*" [lindex $text 0]]} {
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
	global path linkdl tube durasi id judul yturl apis
	if {[string match "*http*" [lindex $text 0]]} { return 0 }
	putquick "NOTICE $nick :Searching $text ..."
	if {[string match "* -*" [string tolower $text]]} { regsub {\-} $text {} text }
	if {[string match "*%*" [string tolower $text]]} { regsub {\%} $text { persen} text }
	regsub -all -- "\[^A-Za-z0-9\]" $text " " text

	if {$apis == "1"} { search $nick $host $hand $chan $text } elseif {$apis == "0"} { ytsearch $nick $host $hand $chan $text }
	if {$apis == "1"} { autoinfo1 $nick $host $hand $chan $text }
   if {$id == "" } { puthelp "privmsg $chan : id diblock"; return 0 }
   if {$durasi == "stream"} { puthelp "PRIVMSG $nick :Live Stream, not allowed" ;return 0 }
   if {[string match "0:*" $durasi]} { set durasi "$durasi detik"
   } elseif {[string match "*:*" $durasi]} { set durasi "$durasi menit"}
   putquick "NOTICE $nick :ConvertinG $judul ..."
   regsub -all {\%} $judul { persen} judul1
   regsub -all -- "\[^A-Za-z0-9&-\]" $judul1 " " jadul1
   regsub -all {\s+} $jadul1 " " jadul2
   regsub {^\s+} $jadul2 "" jadul3
   regsub {\s+$} $jadul3 "" ooo
   regsub -all " " $ooo "_" judulbaru
   catch {exec youtube-dl $yturl --no-part --no-playlist --youtube-skip-dash-manifest --restrict-filenames --max-filesize 35000000 -x --audio-quality 0 -o "$path/public_html/$judulbaru.%(ext)s" --audio-format mp3 --postprocessor-args "-ar 44100" --add-metadata --metadata-from-title "%(artist)s - %(title)s"} runcmd
   set f [open "a.txt" a+]
   puts $f $runcmd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line] || [string match *max-filesize* $line]} {
           puthelp "privmsg $nick :ERROR $durasi"
	   exec rm -f "$path/public_html/$judulbaru.webm"
	   exec rm -f "$path/public_html/$judulbaru.mp4"
	   exec rm -f "$path/public_html/$judulbaru.m4a"
           exec rm -f $path/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/public_html/$judulbaru.mp3"]
    set besar [fixform $ukuran]
   puthelp "NOTICE $nick :Download Link: 10$linkdl/$judulbaru.mp3 \[Size: \002$besar\002\] \[Duration: \002$durasi\002\]"
   puthelp "NOTICE $nick :Anda punya waktu 20menit untuk download"
   timer 20 [list hapus $chan $judulbaru]
   exec rm -f $path/eggdrop/a.txt
}
proc pub_getylink {nick host hand chan text } {
	global path linkdl
   set wik [lindex $text 0]
   set lonk [regsub "&list=.+$" $wik ""]
	putquick "NOTICE $nick :Sedang Diproses..."
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
   catch {exec youtube-dl --no-part --max-filesize 30000000 $lonk -x --audio-format mp3 --postprocessor-args "-ar 44100" --add-metadata --metadata-from-title "%(artist)s - %(title)s" -o "$path/public_html/$judulbaru.%(ext)s"} runcmd
   set f [open "a.txt" a+]
   puts $f $runcmd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line] || [string match *max-filesize* $line]} {
           puthelp "privmsg $nick :ERROR"
	   exec rm -f "$path/public_html/$judulbaru.webm"
	   exec rm -f "$path/public_html/$judulbaru.mp4"
	   exec rm -f "$path/public_html/$judulbaru.m4a"
           exec rm -f $path/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/public_html/$judulbaru.mp3"]
    set besar [fixform $ukuran]
   puthelp "NOTICE $nick :Download Link: 10$linkdl/$judulbaru.mp3 \[Size: \002$besar\002\] \[Duration: \002$durasi menit\002\]"
   puthelp "NOTICE $nick :Anda punya 20menit untuk download"
   timer 20 [list hapus $chan $judulbaru]
   exec rm -f $path/eggdrop/a.txt
}

proc pub_smule {nick host hand chan text } {
   global path linkdl tube
   if {[lindex $text 1] == ""} {
	putquick "NOTICE $nick :Sedang Diproses..."
	set judul [lindex $text 0]
	regexp -nocase {/(\d+_\d+)} $judul match title

   set url "https://www.smuledownloader.download/p/$title"
   http::register https 443 [list ::tls::socket -autoservername true]
   http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https
   puts $status
   set cek "$status"
   if {$cek == "timeout"} { puthelp "privmsg $nick :4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset tube(protection) }; return 0 }
    set l [regexp -all -inline -- {<meta property="og:description" content="Get Smule Performace : (.*?) on Smule. Sing with lyrics to your favorite karaoke} $data]
    set f [regexp -all -inline -- {<div id=audiolink><p><a href="(.*?)"} $data]

if {[llength $f] == 0} { puthelp "privmsg $nick :4Link Smule tidak valid "; return 0 }
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

	catch [list exec ffmpeg -y -loglevel repeat+info -i $link -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$moncrot $path/public_html/$muncrat.mp3]
	set ukuran [file size "$path/public_html/$muncrat.mp3"]
	set besar [fixform $ukuran] 
       puthelp "NOTICE $nick :Download Link: 10$linkdl/$muncrat.mp3 \[Size: \002$besar\002\]"
       puthelp "NOTICE $nick :Anda punya 15menit untuk download"
       timer 15 [list busak $chan $muncrat]
} else {
	putquick "NOTICE $nick :Sedang Diproses...."
	set judul [lindex $text 0]
	set title [lrange $text 1 end]
	regexp -nocase {/(\d+_\d+)} $judul match titles

   set url "https://www.smuledownloader.download/p/$titles"
   http::register https 443 [list ::tls::socket -autoservername true]
   http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
   set token [http::geturl $url -timeout 10000]
   set status [http::status $token]
   set data [http::data $token]
   http::cleanup $token
   http::unregister https
   puts $status
   set cek "$status"
   if {$cek == "timeout"} { puthelp "privmsg $nick :4Koneksi ke smule.com Terputus, Coba Lagi..!!"; catch { unset tube(protection) }; return 0 }
    set f [regexp -all -inline -- {<div id=audiolink><p><a href="(.*?)"} $data]
if {[llength $f] == 0} { puthelp "privmsg $nick :4Link Smule tidak valid "; return 0 }
     foreach {black b} $f {
         set b [string trim $b " \n"]

         regsub -all {<.+?>} $b {} b


        #striphtml $b
        set kumpulin1 "$b"
        append muncrat1 $kumpulin1
	regsub -all {\"} $muncrat1 "" moncrot1
        }
	regsub -all " " $title "_" final
	catch [list exec ffmpeg -y -loglevel repeat+info -i $moncrot1 -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$title $path/public_html/$final.mp3]
	set ukuran [file size "$path/public_html/$final.mp3"]
	set besar [fixform $ukuran]

       puthelp "NOTICE $nick :Download Link: 10$linkdl/$final.mp3 \[Size: \002$besar\002\]"
       puthelp "NOTICE $nick :Anda punya 15menit untuk download"
       timer 16 [list busek $chan $final]
   }
}

proc pub_redirect {nick host hand chan text } {
   global path linkdl tube
   if {[lindex $text 1] == ""} {
	putquick "NOTICE $nick :Sedang Diproses..."
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
utimer 20 [list pub_ganti $linkd $titled $nick $chan]
} else {
	putquick "NOTICE $nick :Sedang Diproses..."
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
utimer 20 [list pub_ganti $linkd $titled $nick $chan]
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
   catch [list exec ffmpeg -y -loglevel repeat+info -i $redirect -vn -acodec libmp3lame -q:a 5 -ar 44100 -metadata title=$titled $path/public_html/$final.mp3]
   set ukuran [file size "$path/public_html/$final.mp3"]
   set besar [fixform $ukuran]

   puthelp "NOTICE $nick :Download Link: 10$linkdl/$final.mp3 \[Size: \002$besar\002\]"
   puthelp "NOTICE $nick :Anda punya 15menit untuk download"
   timer 17 [list busek $chan $final]
}

proc busak {chan muncrat} {
	global path
	if {[file exists $path/public_html/$muncrat.mp3] == 1} {
		exec rm -f $path/public_html/$muncrat.mp3
		#puthelp "PRIVMSG $chan :File\002 $muncrat.mp3 \002Di Hapus."
	}
}

proc busek {chan final} {
	global path
	if {[file exists $path/public_html/$final.mp3] == 1} {
		exec rm -f $path/public_html/$final.mp3
		#puthelp "PRIVMSG $chan :File\002 $final.mp3 \002Di Hapus."
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
	if {[file exists $path/public_html/$judulbaru.mp3] == 1} {
		exec rm -f $path/public_html/$judulbaru.mp3
		#puthelp "PRIVMSG $chan :File\002 $judulbaru.mp3 \002has been deleted."
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
	http::register https 443 [list ::tls::socket -autoservername true]

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

proc search {nick host hand chan text} {
	global key id yturl apis
	regsub -all {\s+} $text "%20" text
	set text [string map {{"} {'} {`} {'}} $text]
	set url "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id(videoId))&type=video&maxResults=3&key=$key&q=$text"
	http::register https 443 [list ::tls::socket -tls1 true -ssl2 false -ssl3 false]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [::http::data [::http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { putquick "privmsg #Djancuk :\00304Api Limit quote"; set apis "0"; timer 10 [list set apis "1"]; ytsearch $nick $host $hand $chan $text; return 0}
	set ids [dict get [json::json2dict $rawpage] items]
	set id [lindex $ids 0 1 1]
	if {[lindex $ids 2 1 1] == "" } { set id ""; return 0 }
	set yturl "https://youtu.be/$id"
}

bind pub - .ling autoinfo
proc autoinfo {nick host hand chan text} {
	global key id durasi judul
set id [lindex $text 0]
	if {$id == ""} { return 0 }
	set url "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$key&part=snippet,contentDetails,statistics&fields=items(snippet(title),contentDetails(duration),statistics(viewCount))"
	http::register https 443 [list ::tls::socket -tls1 true -ssl2 false -ssl3 false]
	http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"
	set rawpage [::http::data [::http::geturl "$url" -timeout 5000]]
	http::cleanup $rawpage
	http::unregister https
	if {[string match *errors* [string tolower $rawpage]]} { return 0}
	set ids [dict get [json::json2dict $rawpage] items]

	set judul [encoding convertfrom [lindex $ids 0 1 1]]
	set durasi [lindex $ids 0 3 1]
	set view [lindex $ids 0 5 1]

	if {$view < 1000 } { puthelp "privmsg $chan :view cuma \00304$view"; return 0 }
	if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	} else {
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {H|M} $durasi ":" durasi
	puthelp "privmsg $chan :1. $durasi ($view)"
		if {[string index $durasi end-1] == ":" } {
			set sec [string index $durasi end]
			set trim [string range $durasi 0 end-1]
			set durasi ${trim}0$sec
	puthelp "privmsg $chan :2. $durasi"
		} elseif {[string index $durasi 0] == "" } {
			set durasi "stream"
		} elseif {[string index $durasi 0] == "0" } {
			set durasi "stream"
		} elseif {[string index $durasi end-2] != ":" } {
			set durasi "${durasi} seconds"
	puthelp "privmsg $chan :3. $durasi"
		} elseif {[string index $durasi end-5] == ":" } {
			set durasi "${durasi} hour"
	puthelp "privmsg $chan :4. $durasi"
		}
	}
}

bind pub - .link autoinfo1
proc autoinfo1 {nick host hand chan text} {
 global key id durasi judul
	if {$id == ""} { return 0 }
	set novideo 0
	set ipq [http::config -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:59.0) Gecko/20100101 Firefox/59.0"]
	set ipq [http::geturl "http://youtubesongname.000webhostapp.com/index.php?link=https://youtu.be/$id" -timeout 50000]
	set getipq [http::data $ipq]
	set output [split $getipq "\n"]
	http::cleanup $ipq
	set title [string map { "&amp;" "&" "&#39;" "'" "&quot;" "\"" } [lindex $output 0]]
	set judul [concat $title]
if {$judul == ""} { set novideo 1}
	set views [lindex $output 1]
if {$views == ""} { set views "N/A" }
	set split_views [split $views " "]
	set views [lindex $split_views 0]
	set views [string map {"&nbsp;" "."} $views]

	set durasi [lindex $output 6]
	set stream [lindex $output 6]
if {$novideo == "1"} {
	return
}
	if {[regexp {^WARNING*} $durasi == 1]} {
		set durasi ""
	} else {
		regsub -all {PT|S} $durasi "" durasi
		regsub -all {M|S} $durasi ":" durasi
		regexp {^(.+):\d+} $durasi match tik
		regexp {\d+:(.+)$} $durasi match sec
		set menit [expr {int($tik) % 60}]
		set jam [expr {int($tik) / 60 % 60}]

		if {$stream == "PT0M0S" } {
			set durasi "stream"
		} elseif {$jam != "0" } {
			set durasi "$jam:$menit:$sec"
		} elseif {$jam == "0"} {
			set durasi "$menit:$sec"
		} elseif {$menit == "0" } {
			set durasi "${$sec} seconds"
		}
	}

}


proc ytsearch {nick host hand chan text} {
	global judul durasi yturl
	set [decrypt 64 "1W3.21HbqBm/"] [lrange $text 0 end]
	regsub -all {\-} $bca1 "" abc1
	regsub -all {\%20} $abc1 " " abc1
	catch {exec youtube-dl -4 --no-warnings -e --get-duration --get-id "ytsearch1:$abc1"} report
	foreach {namafile id durasi} [split $report "\n"] {
	set judul [string map {{_} { }} $namafile]; set yturl "https://youtu.be/$id"
    }
}

putlog "mp3api egg $version by ucup"
