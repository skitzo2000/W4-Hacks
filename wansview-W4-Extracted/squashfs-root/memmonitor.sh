#!/bin/sh
echo 'Start memory monitor'
TotalFree=0
MemFree=0
Buffers=0
Cached=0
lowcount=0
while true
do
MemFree=$(cat /proc/meminfo |grep 'MemFree' |awk '{print $2}')
Buffers=$(cat /proc/meminfo |grep 'Buffers' |awk '{print $2}')
Cached=$(cat /proc/meminfo |grep '^Cached' |awk '{print $2}')
TotalFree=$(($MemFree+$Buffers+$Cached))
if [ $TotalFree -lt 10000 ]
then
echo 'memory low'
echo 'TotalFree:'$TotalFree
lowcount=$((${lowcount} + 1))
echo "lowcount:"$lowcount
else
lowcount=0
echo 'TotalFree:'$TotalFree
fi
if [ $TotalFree -lt 10000 ] && [ $lowcount -ge 10 ]
then
echo "now kill initApp"
OPID=`ps |grep initApp|grep -v 'grep'|awk '{print $1}'`
kill -9 $OPID
fi
sleep 120
done
