# !/bin/bash
ELOG=[net_run_eth.sh]
NETFL_PRE=2
mkdir -p /var/net


loadwired()
{	
	echo $ELOG"start run wired"
	OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
	kill -9 $OPID
	udhcpc -a -b -i eth0 -h IPC
	return 0      
}

while true; do
	NETFL=`cat /sys/class/net/eth0/carrier`
	if [ $NETFL -eq 1 ]
	then

		if [ $NETFL -ne $NETFL_PRE ]
		then
			echo $ELOG"net wired on !!!!!"
			loadwired
		fi
	fi

	NETFL_PRE=$NETFL
	sleep 3
done

