# !/bin/bash
ELOG=[softap_stop.sh]
echo $ELOG"----------------"
OPID=`ps |grep net_run_eth.sh|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep udhcpd|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep hostapd|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID

ifconfig ra0 down

echo 3 > /proc/sys/vm/drop_caches
sleep 1
ifconfig ra0 up

