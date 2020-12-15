echo ""
read -t 2 -p "   Press q -> ENTER to exit boot procedure? " exit_boot
if [ "$exit_boot" == "q" ] ; then
exit
fi
sh /sd_upgrade.sh
sh /ipc_start.sh &
if [ -f /var/syscfg/ipc_after.sh ];then
sh /var/syscfg/ipc_after.sh
fi
