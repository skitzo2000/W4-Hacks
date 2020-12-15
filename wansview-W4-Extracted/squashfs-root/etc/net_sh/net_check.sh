# !/bin/bash
ELOG=[net_check.sh]

if [ -f "/var/net/netsh_exit" ];then
	rm -rf /var/net/netsh_exit
fi

net_run_pid=`ps |grep net_run.sh|grep -v 'grep'|awk '{print $1}'`
if [[ "$net_run_pid" == "" ]]
then
	echo 1 > /var/net/netsh_exit
fi


