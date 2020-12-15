# !/bin/bash
ELOG=[net_wifi_search.sh]

OPID=`ps |grep udhcpd|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID

OPID=`lsmod |grep mt7601Usta|grep -v 'grep'|awk '{print $1}'`
if [[ "$OPID" == "" ]]
then
	/sbin/insmod /lib/modules/mt7601Usta.ko
	sleep 1
fi

ifconfig ra0 up

OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
if [[ "$OPID" == "" ]]
then
	wpa_supplicant -Dnl80211 -ira0 -c/var/syscfg/wpa_supplicant.conf -B
	sleep 2
fi

rm -rf /var/net/WpaCliScanResults.tmp

wpa_cli -ira0 scan
sleep 1
wpa_cli -ira0 scan_results | sed '1d' >/var/net/WpaCliScanResults.tmp
filesize=`ls -l /var/net/WpaCliScanResults.tmp | awk '{ print $5 }'`
if [ $filesize -lt 10 ] 
		then 
		wpa_cli -ira0 scan
		sleep 1
		wpa_cli -ira0 scan_results | sed '1d' >/var/net/WpaCliScanResults.tmp
fi

filesize=`ls -l /var/net/WpaCliScanResults.tmp | awk '{ print $5 }'`
if [ $filesize -lt 10 ] 
		then 
		wpa_cli -ira0 scan
		sleep 1
		wpa_cli -ira0 scan_results | sed '1d' >/var/net/WpaCliScanResults.tmp
fi

