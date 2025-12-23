#!/bin/bash

#if [ "$#" -ne 1 ]; then
#    echo "Should be one parameters to this script: the cfg file" >&2
#    exit 9
#fi


for var in "$@"
do
	echo "Running the script on $var"
	if [ ! -f $var ];
	then
	    echo "File $var not found! --> STOP" && exit 0
	fi

	name=$(grep -E "name" $var | cut -d"=" -f2)
	fitsadd=$(grep -E "fitsadd" $var | cut -d"=" -f2)
	wdir=$(grep -E "wdir" $var| cut -d"=" -f2)
	apthdir=$(grep -E "APThDir" $var| cut -d"=" -f2)
	vqadd=$(grep -E "vqadd" $var | cut -d"=" -f2)


	mkdir -p $wdir/$name
	imgadd=$wdir/$name/img.fits
	rm -rf $wdir/$name/*
	rm $apthdir/APT.tbl
	cp $fitsadd $imgadd

	astap -f $imgadd -update 
	RA=$(fitsheader $imgadd | grep "CRVAL1" | cut -d"=" -f2 | cut -d"/" -f1 | awk '{printf "%.4f\n", $1}')
	DE=$(fitsheader $imgadd | grep "CRVAL2" | cut -d"=" -f2 | cut -d"/" -f1 | awk '{printf "%.4f\n", $1}')
	DEu=$(fitsheader $imgadd | grep "CRVAL2" | cut -d"=" -f2 | cut -d"/" -f1 | cut -d"." -f1)
	if (( "$DEu" > 0 )); then
		sign="+"
	else
		sign="-"
	fi


	$vqadd -mime=tsv -source=UCAC4 -c=$RA$sign$DE,rm=25 -out=_RA,_DE,Vmag  > temp

	while read -r line
	do 
		col1=$(echo $line | cut -d" " -f1)
		le3=$(echo $line | cut -d" " -f3)
		le4=$(echo $line | cut -d" " -f4)
		if (( "${#le3}" > 0 && "${#le4}" == 0)); then
			if [[ $col1 =~ ^[0-9]+(\.[0-9]+)?$ ]] ; then
	        		echo $line >> $wdir/$name/vizierdb.txt
			fi
		fi
		
	done < temp
	
	APT.csh -i $imgadd  -s sourceListByAPT
	n=0
	while read -r line
	do
	        col1=$(echo $line | cut -d" " -f4)
	        col2=$(echo $line | cut -d" " -f5)
	        col3=$(echo $line | cut -d" " -f15)
		let "n=n+1"
		if (( "$n" >2 )); then
	        	echo $col1 $col2 $col3 >> $wdir/$name/sourcesimage.txt
		fi
	done < $apthdir/APT.tbl

	sed '$d' $wdir/$name/sourcesimage.txt > test
	cp test $wdir/$name/sourcesimage.txt

done
