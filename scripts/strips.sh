#!/bin/bash
####################################################################
# Credits for the code.                                            #
#  https://github.com/theskyisthelimit/ubtuntumkvtoolnix           #
#                                                                  #
# I've just made some tweaks.                                      #
####################################################################

######  PushOver API  ############
APP_TOKEN="YOUR_TOKEN_HERE"
USER_TOKEN="YOUR_USER_ID_HERE"
##################################


fpath="$sonarr_episodefile_path"
file=$(basename "$fpath")
ss=$(dirname "$fpath")
cd "$ss"


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
     if [ -z "$subs" ] # Se $Subs for vazio executa - Executa caso não haja nenhum sub válido.
     then
       echo "3: Nothing to remove, will look for ASS & PGS Files"
       audio=$(mkvmerge -I "$file" | sed -ne '/^Track ID [0-9]*: audio .* language:\(por\|eng\|jpn\|und\).*/ { s/^[^0-9]*\([0-9]*\):.*/\1/;H }; $ { g;s/[^0-9]/,/g;s/^,//;p }')
       echo "4: found $audio to keep"
       subs=$(mkvmerge -I "$file" | sed -ne '/^Track ID [0-9]*: subtitles [(SubStationAlpha)|(ASS)|(HDMV/PGS)|(VobSub)].*/ { s/^[^0-9]*\([0-9]*\):.*/\1/;H }; $ { g;s/[^0-9]/,/g;s/^,//;p }')
       echo "5: found $subs to remove"

       if [ -z "$subs" ] # Executa se não tiver nenhum sub não válido
       then
   			if [ $diffaudio -gt 0 ] # Executa se tiver mais áudio que áudio válidos
			then
				echo diffaudio= $diffaudio
				echo "6: Only needed audio found."
				subs="-S";
				audio="-a $audio";
				mkvmerge $subs $audio -o "${file%.mkv}".edited.mkv "$file";
				mv "${file%.mkv}".edited.mkv "$file"
				echo "7: Unwanted audio found and removed!"
				# mv "$1" /media/Trash/;
			else
				echo "6: Nothing found to remove. Will exit script now."
				if [$APP_TOKEN != "YOUR_TOKEN_HERE"]
				then 
					wget https://api.pushover.net/1/messages.json --post-data="token=$APP_TOKEN&user=$USER_TOKEN&message=$file" - Nothing found to remove"&title=SonarrM"
				fi
			fi
       else
         subs="-S";
         audio="-a $audio";
         mkvmerge $subs $audio -o "${file%.mkv}".edited.mkv "$file";
         mv "${file%.mkv}".edited.mkv "$file"
         echo "7: PGS/ASS/VobSub Subtitles found and removed!"
         # mv "$1" /media/Trash/;
       fi
	
	 elif [ $diffsubs -eq 0 -a $diffaudio -eq 0 ]
	 then
	   echo "3: Only needed audio and subtitles found" 
	  
     else
       echo "3: Found Subtitles. Will multiplex now"
       subs="-s $subs";
       audio="-a $audio";

       mkvmerge $subs $audio -o "${file%.mkv}".edited.mkv "$file";
       mv "${file%.mkv}".edited.mkv "$file"
       # mv "$1" /media/Trash/;
     fi
exit
