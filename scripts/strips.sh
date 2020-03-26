#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>> /config/logs/striplog.txt 2>&1
####################################################################
# Credits for the code.                                            #
#  https://github.com/theskyisthelimit/ubtuntumkvtoolnix           #
#                                                                  #
# I've just made some tweaks.                                      #
####################################################################

###############  PushOver API  ############ So altere esses campos #
APP_TOKEN="aur35g2u3o7k6wy6rg5rcuoh4nokxr"
USER_TOKEN="ukov8ca9heddn3f429qr212w2a51za"
####################################################################


fpath="$sonarr_episodefile_path"
file=$(basename "$fpath")
ss=$(dirname "$fpath")
cd "$ss"

   echo 
   echo $file
   mkvmerge -I "$file"
   audio=$(mkvmerge -I "$file" | sed -ne '/^Track ID [0-9]*: audio .* language:\(por\|eng\|jpn\|und\).*/ { s/^[^0-9]*\([0-9]*\):.*/\1/;H }; $ { g;s/[^0-9]/,/g;s/^,//;p }')
   audiocount=$(echo $audio | tr "," "\n" | wc -l)
   echo "1: found $audio ($audiocount) to keep"
   subs=$(mkvmerge -I "$file" | sed -ne '/^Track ID [0-9]*: subtitles [(HDMV\/PGS)|(VobSub)|(SubRip\/SRT)].* language:\(por\|eng\).*/ { s/^[^0-9]*\([0-9]*\):.*/\1/;H }; $ { g;s/[^0-9]/,/g;s/^,//;p }')
   subscount=$(echo $subs | tr "," "\n" | wc -l)
   echo "2: found $subs ($subscount) to keep"
   totalaudio=$(mkvmerge -I "$file" | grep audio | wc -l)
   totalsubs=$(mkvmerge -I "$file" | grep subtitles | wc -l)
  
   diffaudio=$(expr $totalaudio - $audiocount)
   diffsubs=$(expr $totalsubs - $subscount)
	if [ -z "$subs" ] # Loop if there is no valid subtitle.
     then
       audio=$(mkvmerge -I "$file" | sed -ne '/^Track ID [0-9]*: audio .* language:\(por\|eng\|jpn\|und\).*/ { s/^[^0-9]*\([0-9]*\):.*/\1/;H }; $ { g;s/[^0-9]/,/g;s/^,//;p }')
       echo "4: found $audio to keep"
       subs=$(mkvmerge -I "$file" | sed -ne '/^Track ID [0-9]*: subtitles [(SubStationAlpha)|(ASS)|(HDMV/PGS)|(VobSub)].*/ { s/^[^0-9]*\([0-9]*\):.*/\1/;H }; $ { g;s/[^0-9]/,/g;s/^,//;p }')
       echo "5: found $subs to remove"

       if [ -z "$subs" ] # Loop if there is no invalid subtitle.
       then
   			if [ $diffaudio -gt 0 ] # Loop if there are more audio than valid audios.
			then
				echo diffaudio= $diffaudio
				echo "6: Only needed audio found."
				subs="-S";
				audio="-a $audio";
				mkvmerge $subs $audio -o "${file%.mkv}".edited.mkv "$file";
				mv "${file%.mkv}".edited.mkv "$file"
				echo "7: Unwanted audio found and removed!"
				# mv "$1" /media/Trash/;
				if [ $APP_TOKEN != "YOUR_TOKEN_HERE" ] #Don't alter
				then 
					wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN=$file - Audio Removed!&title=SonarrM" -qO- > /dev/null 2>&1 &
				fi
			else
				echo "6: Nothing found to remove. Will exit script now."
				if [ $APP_TOKEN != "YOUR_TOKEN_HERE" ] #Don't alter
				then 
					wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Nothing found to remove.&title=SonarrM" -qO- > /dev/null 2>&1 &
				fi
			fi
       else
         subs="-S";
         audio="-a $audio";
         mkvmerge $subs $audio -o "${file%.mkv}".edited.mkv "$file";
         mv "${file%.mkv}".edited.mkv "$file"
         echo "7: PGS/ASS/VobSub Subtitles found and removed!"
         # mv "$1" /media/Trash/;
		 if [ $APP_TOKEN != "YOUR_TOKEN_HERE" ] #Don't alter
			then 
				wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Unwanted subtitles removed&title=SonarrM" -qO- > /dev/null 2>&1 &
			fi
       fi
	
	 elif [ $diffsubs -eq 0 -a $diffaudio -eq 0 ]
	 then
	   echo "3: Only needed audio and subtitles found" 
	   if [ $APP_TOKEN != "YOUR_TOKEN_HERE" ] #Don't alter
		then 
				wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Nothing found to remove.&title=SonarrM" -qO- > /dev/null 2>&1 &
		fi
	  
     else
       echo "3: Found Subtitles. Will multiplex now"
       subs="-s $subs";
	   audi=$audio; # keep the value of the original $audio var
       audio="-a $audio";
		if [ -z "$audi" ]
		then
			mkvmerge $subs -o "${file%.mkv}".edited.mkv "$file";
			mv "${file%.mkv}".edited.mkv "$file"
			# mv "$1" /media/Trash/;
				if [ $APP_TOKEN != "YOUR_TOKEN_HERE" ] #Don't alter
				then
					if [ $diffsubs -gt 0 ]
					then 
						wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Only foreign audio, kept it. Unwanted subtitles removed.&title=SonarrM" -qO- > /dev/null 2>&1 &
					elif [ $diffsubs -eq 0 ]
					then
						wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Only foreign audio, kept it.&title=SonarrM" -qO- > /dev/null 2>&1 &
					
					fi
				fi
		
		
		else
			mkvmerge $subs $audio -o "${file%.mkv}".edited.mkv "$file";
			mv "${file%.mkv}".edited.mkv "$file"
			# mv "$1" /media/Trash/;
			if [ $APP_TOKEN != "YOUR_TOKEN_HERE" ] #Don't alter
			then
				if [ $diffsubs -gt 0 -a $diffaudio -gt 0 ]
				then 
					wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Audio and Subtitles removed.&title=SonarrM" -qO- > /dev/null 2>&1 &
				elif [ $diffaudio -gt 0 ]
				then
					wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Audio removed.&title=SonarrM" -qO- > /dev/null 2>&1 &
				elif [ $diffsubs -gt 0 ]
				then	
					wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file - Subtitles removed.&title=SonarrM" -qO- > /dev/null 2>&1 &
				fi
			fi
		fi
	fi
exit
