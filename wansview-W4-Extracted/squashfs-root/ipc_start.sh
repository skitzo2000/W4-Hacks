#2016-7-2 new vg_boot.sh 

mdev -s
#cat /proc/modules

rootfs_date=`ls /|grep 00_2`
mtd_date=`ls /mnt/mtd|grep 00_2`
echo =========================================================================
#echo "  Video Front End: $video_frontend"
#echo "  Chip Version: $chipver"
echo "  RootFS Version: $rootfs_date"
echo "  MTD Version: $mtd_date"
echo =========================================================================

#mkdir -p /var/spool/cron/crontabs
#crond
mkdir -p /var/tmp/
mkdir -p /var/avApp/
cp -rp /etc/* /var/tmp/
busybox mount -t tmpfs -o mode=0755 tmpfs /etc
cp -rp /var/tmp/* /etc/


mkdir -p /tmp/msnap
mkdir -p /var/upload/
mkdir -p /var/etc/
mkdir -p /var/net/
insmod /mnt/mtd/module/tx-isp-t21.ko
insmod /mnt/mtd/module/audio.ko sign_mode=1


grep "sensor:" /proc/jz/sinfo/info > /dev/null
if [ $? -eq 0 ];then
cp /proc/jz/sinfo/info /var/syscfg/sinfo.conf
else
echo "can't get sensor info"
fi
/sbin/insmod /lib/modules/mt7601Usta.ko

ip link set dev wlan0  name ra0
insmod  /mnt/mtd/module/peripher_drv.ko
insmod  /mnt/mtd/module/reset_drv.ko
insmod  /mnt/mtd/module/NetLED_drv.ko
wpa_supplicant -Dnl80211 -ira0 -c/var/syscfg/wpa_supplicant.conf -B

ifconfig lo 127.0.0.1
ifconfig eth0 0.0.0.0  
ifconfig ra0 0.0.0.0
export LD_LIBRARY_PATH=/mnt/mtd/lib:/lib
export PATH=/gm/bin:/bin:/sbin:/usr/bin:/usr/sbin:$PATH

echo 512 > /proc/sys/vm/min_free_kbytes

sh /memmonitor.sh &
sh /run_cmd.sh &

while true;do
if [ -f /var/cloud/firmware.bin ];then
cp /mnt/mtd/app/initApp /var/cloud/initApp
/var/cloud/initApp
else
/mnt/mtd/app/initApp
OPID=`ps |grep net_run.sh|grep -v 'grep'|awk '{print $1}'`
kill $OPID

OPID=`ps |grep udhcpc|grep -v 'grep'|awk '{print $1}'`
kill $OPID

OPID=`ps |grep wpa_supplicant|grep -v 'grep'|awk '{print $1}'`
kill $OPID

OPID=`ps |grep ajy.cgi|grep -v 'grep'|awk '{print $1}'`
kill $OPID

fi
sleep 2
echo 3 > /proc/sys/vm/drop_caches
sleep 3
done
