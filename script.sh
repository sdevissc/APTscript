#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Should be one parameters to this script: the cfg file" >&2
    exit 9
fi
name=$(grep -E "name" $1 | cut -d"=" -f2)
fitsadd=$(grep -E "fitsadd" $1 | cut -d"=" -f2)
wdir=$(grep -E "wdir" $1| cut -d"=" -f2)
apthdir=$(grep -E "APThDir" $1| cut -d"=" -f2)
vqadd=$(grep -E "vqadd" $1 | cut -d"=" -f2)

echo "$name $fitsadd $wdir $voutput $uncorrectedcsv $correctedtsv $vqadd"

mkdir -p $wdir/$name
imgadd=$wdir/$name/img.fits
rm -rf $wdir/$name/*
rm $apthdir/APT.tbl
cp $fitsadd $imgadd

astap -f $imgadd -update 
RA=$(fitsheader $imgadd | grep "CRVAL1" | cut -d"=" -f2 | cut -d"/" -f1 | awk '{printf "%.4f\n", $1}')
DE=$(fitsheader $imgadd | grep "CRVAL2" | cut -d"=" -f2 | cut -d"/" -f1 | awk '{printf "%.4f\n", $1}')
DEu=$(fitsheader $imgadd | grep "CRVAL2" | cut -d"=" -f2 | cut -d"/" -f1 | cut -d"." -f1)
echo $RA
echo $DE
echo $DEu
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
