# !/bin/bash
ELOG=[net_exit.sh]

OPID=`ps |grep net_run.sh|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID

ifconfig ra0 down


