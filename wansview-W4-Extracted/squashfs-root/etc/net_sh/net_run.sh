# !/bin/bash
ELOG=[net_run.sh]
NETFL_PRE=2
mkdir -p /var/net

checkra0needreset()
{	need_reset=0
	usb_error=`cat /proc/wifiUsbStatus | tr -cd "[0-9]"`
	if [ $usb_error -eq 1 ]
	then
		need_reset=1
	fi

	if [ -f "/var/wpa_error" ];then
		need_reset=1
		rm -rf /var/wpa_error
	fi

	ra0_error=`ifconfig |grep ra0|awk '{print $1}'`
	if [[ "$ra0_error" == "" ]]
	then
		need_reset=1
	fi

	if [ $need_reset -eq 1 ]
	then
		OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
		kill -9 $OPID
		OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
		kill -9 $OPID
		echo $ELOG"ra0 ----down"
		ifconfig ra0 down
		sleep 1
		rmmod mt7601Usta
		sleep 2
		echo 3 > /proc/sys/vm/drop_caches
		sleep 3
		insmod /lib/modules/mt7601Usta.ko
		sleep 2
		echo $ELOG"ra0 ----up"
		ifconfig ra0 up
		sleep 2
	fi

	
	return 0      
}

loadwired()
{	
	echo $ELOG"start run wired"
	OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID
	ifconfig ra0 0.0.0.0
	udhcpc -a -b -i eth0 -h IPC
	return 0      
}

loadwireless()
{
	echo $ELOG"start run wireless"
	OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID
	OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID

	ko_str=`lsmod |grep mt7601Usta |awk '{print $1}'`
	if [[ "$WIFI_STATUS" == "" ]]
		then
		echo 3 > /proc/sys/vm/drop_caches
		sleep 3
		insmod /lib/modules/mt7601Usta.ko
		sleep 2	
	fi
	ifconfig ra0 up
	wpa_supplicant -Dnl80211 -ira0 -c/var/syscfg/wpa_supplicant.conf -B
	ifconfig eth0 0.0.0.0
	return 0 
}

loadwirelessOnEth0()
{
	echo $ELOG"start run wireless"
	OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID
	OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID
	
	ifconfig ra0 up
	
	wpa_supplicant -Dnl80211 -ira0 -c/var/syscfg/wpa_supplicant.conf -B
	return 0 
}

dhcpwireless()
{
	echo $ELOG"start dhcp wireless"
	OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID
	udhcpc -a -b -i ra0 -h IPC
	return 0 
}

wifi_disconnect_loop=0
wifi_status=0
add_new_wifi=0
running_loop_cnt=0

while true; do
	NETFL=`cat /sys/class/net/eth0/carrier`
	if [ $NETFL -eq 0 ]
	then
		if [ $NETFL -ne $NETFL_PRE ]
		then
			echo $ELOG"net change to wireless"
			echo 1 > /var/net/wireless
			loadwireless
		fi

		if [ -f "/var/net/wifi_new" ];then
			rm -rf /var/net/wifi_new
			loadwireless
			wifi_status=0
		fi
		
		WIFI_STATUS=`/gm/bin/wpa_cli  -ira0 status |grep wpa_state=COMPLETED`
		if [[ "$WIFI_STATUS" != "" ]]
		then
			#echo $ELOG"wifi Connected"
			echo Connected > /var/net/wifiStatus
			wifi_disconnect_loop=0
			if [ $wifi_status -eq 0 ]
			then
				dhcpwireless
			fi
			wifi_status=1

			OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
			if [[ "$OPID" == "" ]]
			then
				udhcpc -a -b -i ra0 -h IPC
			fi
		else
			#echo $ELOG"wifi disConnect"
			echo disConnect > /var/net/wifiStatus
			wifi_status=0
			if [ $((wifi_disconnect_loop+=1)) -gt 10 ] 
			then 
				checkra0needreset
				echo $wifi_disconnect_loop
				wifi_disconnect_loop=0
				loadwireless
			fi
		fi
		
	else
		if [ $NETFL -ne $NETFL_PRE ]
		then
			echo $ELOG"net change to wired"
			rm -rf /var/net/wireless
			loadwired
		fi

		if [ -f "/var/net/wifi_new" ];then
			loadwirelessOnEth0
			wifi_status=0
			add_new_wifi=1
			echo $ELOG"wifi new------------"
			wpa_cli -ira0 disconnect
			ifconfig ra0 down
			OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
			kill -9 $OPID
			echo 3 > /proc/sys/vm/drop_caches
			ifconfig ra0 up
			sleep 1
			wpa_supplicant -Dnl80211 -ira0 -c/var/syscfg/wpa_supplicant.conf -B
			rm -rf /var/net/wifiStatus
			
			echo disConnect > /var/net/wifiStatus
			wpa_cli -ira0 reconfigure
			sleep 1
			wpa_cli -ira0 reconnect
			sleep 1
			echo disConnect > /var/net/wifiStatus
			rm -rf /var/net/wifi_new
		fi

	
		WIFI_STATUS=`/gm/bin/wpa_cli  -ira0 status |grep wpa_state=COMPLETED`
		if [[ "$WIFI_STATUS" != "" ]]
		then
			echo $ELOG"wifi Connected============================"
			echo Connected > /var/net/wifiStatus
			
			wifi_status=1
			add_new_wifi=0
		else
			echo $ELOG"wifi disConnect=========================="
			echo disConnect > /var/net/wifiStatus
			wifi_status=0
		fi
		
		wifi_disconnect_loop=0
		wifi_status=0

		OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
		if [[ "$OPID" == "" ]]
		then
			udhcpc -a -b -i eth0 -h IPC
		fi
	fi

	NETFL_PRE=$NETFL
	sleep 15

	echo $((running_loop_cnt+=1)) > /var/net/running_loop_cnt
	if [ $running_loop_cnt -gt 10 ] 
		then 
		running_loop_cnt=0
	fi
	
done

