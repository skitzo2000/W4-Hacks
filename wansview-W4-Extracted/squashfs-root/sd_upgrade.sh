echo ""
echo "----enter to upgrade from sdcard----"
bUpgrade=0
insmod /lib/modules/mmc_core.ko
insmod /lib/modules/mmc_block.ko
insmod /lib/modules/jzmmc_v12.ko
sleep 1
if [ ! -f /var/sdcard ];then
	mkdir -p /var/sdcard
fi
sleep 1
mount /dev/mmcblk0p1 /var/sdcard
if [ ! -f /var/sdcard/syscfg.ini ];then
	echo "    syscfg.ini not exist."
else
	cp /var/sdcard/syscfg.ini /var/syscfg/syscfg.ini
	echo "    syscfg.ini is updated."
fi

mkdir /var/syscfg
mkdir /var/sysbak

cp /bin/busybox				/var/
cp /var/syscfg/WorkLedFlash.sh		/var/
chmod +x /var/WorkLedFlash.sh

if [ -f /var/sdcard/ub_boot.bin ];then
	mv /var/sdcard/ub_boot.bin /var/sdcard/ok_ub_boot.bin
fi

if [ -f /var/sdcard/ub_kernel.bin ];then
	mv /var/sdcard/ub_kernel.bin /var/sdcard/ok_ub_kernel.bin
fi

if [ -f /var/sdcard/ub_rootfs.bin ];then
	mv /var/sdcard/ub_rootfs.bin /var/sdcard/ok_ub_rootfs.bin
fi

if [ -f /var/sdcard/ub_user.bin ];then
	mv /var/sdcard/ub_user.bin /var/sdcard/ok_ub_user.bin
fi

if [ -f /var/sdcard/ub_userdb.bin ];then
	mv /var/sdcard/ub_userdb.bin /var/sdcard/ok_ub_userdb.bin
fi

if [ -f /var/sdcard/ub_backdb.bin ];then
	mv /var/sdcard/ub_backdb.bin /var/sdcard/ok_ub_backdb.bin
fi

if [ -f /var/sdcard/AjyIpcFirmware.pkg ];then
	echo "update AjyIpcFirmware.pkg"
	cp /mnt/mtd/app/initApp /var/
	mkdir -p /var/etc/
	export LD_LIBRARY_PATH=/mnt/mtd/lib:/lib
	export PATH=/gm/bin:/bin:/sbin:/usr/bin:/usr/sbin:$PATH
	/var/initApp -u
	echo "Exit AjyIpcFirmware.pkg"
	reboot
fi


if [ ! -f /var/sdcard/uboot.bin ];then
	echo "    uboot.bin not exist."
else
	/var/WorkLedFlash.sh &
	/var/busybox flash_eraseall /dev/mtd0
	/var/busybox flashcp -v  /var/sdcard/uboot.bin /dev/mtd0
	mv /var/sdcard/uboot.bin /var/sdcard/uboot.bin.bak
	bUpgrade=1
	echo "    uboot.bin is updated."
fi

if [ ! -f /var/sdcard/kernel.bin ];then
	echo "    kernel.bin not exist."
else
	/var/WorkLedFlash.sh &
	/var/busybox flash_eraseall /dev/mtd1
	/var/busybox flashcp -v  /var/sdcard/kernel.bin /dev/mtd1
	mv /var/sdcard/kernel.bin /var/sdcard/kernel.bin.bak
	bUpgrade=1
	echo "    kernel.bin is updated."
fi

if [ ! -f /var/sdcard/rootfs.bin ];then
	echo "    rootfs.bin not exist."
else
	/var/WorkLedFlash.sh &
	/var/busybox flash_eraseall /dev/mtd2
	/var/busybox flashcp -v  /var/sdcard/rootfs.bin /dev/mtd2
	mv /var/sdcard/rootfs.bin /var/sdcard/rootfs.bin.bak
	bUpgrade=1
	echo "    rootfs.bin is updated."
fi


if [ -f /var/sdcard/syscfg.bin ];then
	if [ -b /dev/mtdblock0 ];then
	 /var/WorkLedFlash.sh &
	 umount /var/syscfg
	 /var/busybox flash_eraseall /dev/mtd3
	 /var/busybox flashcp -v  /var/sdcard/syscfg.bin /dev/mtd3
	 mv /var/sdcard/syscfg.bin /var/sdcard/syscfg.bin.bak
	 bUpgrade=1
	 echo "    syscfg.bin is updated."
	fi
fi

if [ -f /var/sdcard/sysbak.bin ];then
	if [ -b /dev/mtdblock0 ];then
	 /usr/bin/WorkLedFlash.sh &
	 umount /var/sysbak
	 /var/busybox flash_eraseall /dev/mtd4
	 /var/busybox flashcp -v  /var/sdcard/sysbak.bin /dev/mtd4
	 mv /var/sdcard/sysbak.bin /var/sdcard/sysbak.bin.bak
	 bUpgrade=1
	 echo "    sysbak.bin is updated."
	fi
fi


if [ "$bUpgrade" != "0" ];then
	if [ -f /var/sdcard/after_upgrade.sh ];then
	  /var/sdcard/after_upgrade.sh
	fi
	umount /var/sdcard
	reboot
	echo "----leaved to upgrade from sdcard----"
	exit
fi
echo "----leaved to upgrade from sdcard----"

if [ -f /var/sdcard/wpa_supplicant.conf ];then
cp /var/sdcard/wpa_supplicant.conf  /tmp/wpa_supplicant.conf_sd
fi



umount /var/sdcard
sleep 1
echo "rmmod mmcv12 and mmcblock and mmccore"
#rmmod jzmmc_v12
rmmod mmc_block
#rmmod mmc_core
lsmod
rm -rf /var/busybox


#check sensor id
if [ ! -f /var/syscfg/sinfo.conf ];then
insmod /mnt/mtd/module/sinfo.ko
fi

while [ ! -f /var/syscfg/sinfo.conf ]
do
echo 1 > /proc/jz/sinfo/info
sleep 1
grep "sensor:" /proc/jz/sinfo/info > /dev/null
if [ $? -eq 0 ];then
cp /proc/jz/sinfo/info /var/syscfg/sinfo.conf
else
echo "can't get sensor info"
fi
done

