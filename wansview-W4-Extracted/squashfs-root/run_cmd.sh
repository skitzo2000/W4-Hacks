#!/bin/bash
dir=/var/cmd
mkdir -p /var/cmd
count=0
havefile=0
isreset=0
while true; do
havefile=0
for file in `ls $dir/*.sh 2>/dev/null` 
do
    chmod a+x $file
    sh $file
    rm -rf $file
    havefile=1
done

if [ $havefile -eq 0 ] 
then sleep 1
fi
count=$((${count} + 1))
#echo $count
if [ ! -z $( grep 'ssid=\"0\"' /var/syscfg/wpa_supplicant.conf ) ] && [ ! -z $( grep 'psk=\"12345678\"' /var/syscfg/wpa_supplicant.conf ) ]
then
        isreset=1
else
        isreset=0
fi
if [ $( pgrep -f wpa_supplicant | wc -l ) -eq 0 ] && [ $count -ge 10 ] && [ $isreset -eq 0 ]
then 
	echo "wpa_supplicat not run"
	wpa_supplicant -Dnl80211 -ira0 -c/var/syscfg/wpa_supplicant.conf -B
	count=0
fi
done
