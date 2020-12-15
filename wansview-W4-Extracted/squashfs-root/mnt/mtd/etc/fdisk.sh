#SD Card or TFTP Card,Operating and formatting by Pan 20160617
#!/bin/bash
echo "SD Card or TFTP Card,Operating and formatting by Pan 20160617"
SD_Card_Disk=$1
if [ -z $SD_Card_Disk ];then
SD_Card_Disk=/dev/mmcblk0
echo "Use Default SD or TFT Card Dev 20160617"
fi
fdisk $SD_Card_Disk <<EOF
d
1
d
2
d
3
d
4
n
p
1
 
 
t
c
w
EOF
exit