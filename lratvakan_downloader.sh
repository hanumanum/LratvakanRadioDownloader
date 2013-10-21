#!/bin/bash
#հեղինակ ։ Հանուման
#նպատակ։ Քաշում է Լրատվական Ռադիոյի նոր փոթքասթները
#ամսաթիվ։ 2012-10-20
#գիթհաբում։ https://github.com/hanumanum/Lratvakan-radio-podcast-downloaderX

#RSS հղումների ֆայլ
FILENAME=feeds
#Փոթքաստները պահել այստեղ
PODCASTDIRECTORY=~/Podcasts/LratvakanRadio/
#ժամանակավոր դիրեկտորիա
TMPDIRECTORY=/tmp/lratvakan

newcount=0
DATE=$(date +%Y-%m-%d);
PODCASTDIRECTORY="$PODCASTDIRECTORY$DATE"
mkdir $PODCASTDIRECTORY

date > log
array=($(< downloaded))
zibil=($(< zibil))

#echo "Սկսում եմ քաշել RSS-ները"
cat $FILENAME | cut -d" " -f1 | while read LINE
do
       echo "$LINE"
       wget $LINE -P $TMPDIRECTORY
done

#echo "RSS ֆայլերը քաշված են"
#echo "Սկսում եմ փարս անելը"

for f in $TMPDIRECTORY/*
do
#echo "սկսում եմ փարսել $f -ը";
cat $f | while read LINE
	do
		if [ "${LINE:0:16}" == "<title><![CDATA[" ]; then
			let LENGH=${#LINE}-11-16
			if [ $LENGH -ge 100 ]; then
				let LENGH=100
			fi
			TITLE="${LINE:16:LENGH}"
			
		fi
	
		if [ "${LINE:0:15}" == "<link><![CDATA[" ]; then
			let LENGH=${#LINE}-10-15
			LINK="${LINE:15:LENGH}"
			
			
			#հոդվածի ID-ն և աուդիոնյութի ID-ն նույնն են, հակառակ դեպքում կպահանջվեր փարսել նաև հոդվածների էջերը
			AUDOID="${LINK:23}"
			
			#echo "http://lratvakan.am/voice/$AUDOID.mp3"

			#ստուգում ենք, հո չենք քաշել արդեն
			ISNEW=1
			for audid in "${array[@]}"
			{
			 
			 if [ "$audid" == "$AUDOID" ]; then
				ISNEW=0
			 fi 		
			}
			#ստուգում ենք արդյոք զիբիլանոցում կա
			for audid in "${zibil[@]}"
			{
			 
			 if [ "$audid" == "$AUDOID" ]; then
				ISNEW=0
			 fi 		
			}


			#չենք քաշում արդեն քաշածները կամ զիբլանոցում գտնվողները
			if [ "$ISNEW" == "1" ]; then
	
				RESULTFILE="$PODCASTDIRECTORY/$AUDOID $TITLE.mp3"
				echo "====================ՔԱՇԻ======================="
				echo $RESULTFILE
				

				wget -O "$PODCASTDIRECTORY/tmp_$AUDOID.mp3" "http://lratvakan.am/voice/$AUDOID.mp3" -P $PODCASTDIRECTORY 
				
				
				#մի կիլոբայթից փոքր ֆայլը ենթադրվում ա , որ պիտի աղբ լինի
				s=$(stat -c %s "$PODCASTDIRECTORY/tmp_$AUDOID.mp3")
				if [ $s -ge 1024 ]; then
					mv "$PODCASTDIRECTORY/tmp_$AUDOID.mp3" "$RESULTFILE"
					echo "==========================================" >> log
					echo "լավն էր" >> log
					echo "Վերնագիր։ $TITLE" >> log
					echo "Հոդվածի հղում։ $LINK" >> log
					echo "Ֆայլի անուն։ $RESULTFILE" >> log
				else
					echo "==========================================" >> log
					echo "աղբ  էր" >> log
					echo "$AUDOID" >> zibil
					echo "Վերնագիր։ $TITLE" >> log
					echo "Հոդվածի հղում։ $LINK" >> log

				fi
				
				
				if [ -e "$RESULTFILE" ]; then
				  echo $AUDOID>>downloaded
				  newcount=`expr $newcount + 1` #TODO: չի հաշվում քանակը
				fi
				
				echo "====================ՖՌՌԱ===================="
				echo "====================ՖՍՍԱ ։)===================="
			fi  
			 			
			
		fi
	
	done
done

#ջնջում եմ ժամանակավոր ֆայլերը
rm $TMPDIRECTORY/*
rm $PODCASTDIRECTORY/tmp_*

date >> log
echo "===========+++++ՔԱՇՎԵՑ $newcount ՆՈՐ ՀՈԴՎԱԾ+++++++=====================" >> log
cat log
