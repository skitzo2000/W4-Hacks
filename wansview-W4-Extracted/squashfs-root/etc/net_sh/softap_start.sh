# !/bin/bash
ELOG=[softap_start.sh]
echo $ELOG"----------------"


OPID=`ps |grep net_run.sh|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep udhcpd|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
OPID=`ps |grep hostapd|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID


sleep 1
echo 3 > /proc/sys/vm/drop_caches
sleep 1

ifconfig ra0 192.168.0.1
rm -rf /var/hostapd.conf
chnum=$((($RANDOM%11)+1))

echo 'interface=ra0' >> /var/hostapd.conf
echo 'ctrl_interface=/var/run/hostapd' >> /var/hostapd.conf
echo 'ctrl_interface_group=0' >> /var/hostapd.conf
echo 'hw_mode=g' >> /var/hostapd.conf
echo 'channel='$chnum >> /var/hostapd.conf
echo 'beacon_int=100' >> /var/hostapd.conf
echo 'ssid='$1 >> /var/hostapd.conf
echo 'auth_algs=3' >> /var/hostapd.conf

hostapd /var/hostapd.conf -B

ifconfig ra0 192.168.0.1 up
mkdir -p /var/lib/misc/
touch /var/lib/misc/udhcpd.leases
udhcpd -f /etc/net_sh/udhcpd.conf&
#/etc/net_sh/net_run_eth.sh&



