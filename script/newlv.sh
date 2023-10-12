#!/bin/bash

path=/opt/SolarWinds
log=/tmp/newlv-`hostname`-log.txt
flavor=$(uname)
if [ "$flavor" == AIX ] 
then
	if [ -d "$path" ]
	then
  	echo "directory is avilable" > $log
  	ls -ld $path >> $log 2>&1
        stopsrc -s swiagentd >> $log 2>&1
	sleep 1 
  	rm -rf $path >> $log 2>&1
	sleep 1
        mklv -y lvsolar -t jfs2 rootvg 2G && crfs -v jfs2 -d /dev/lvsolar -m "$path" -A yes -a logname=INLINE && mount "$path"  >> $log 2>&1
	sleep 2
        chown zmanageengine:bin $path
        chmod 775 $path
        df -Pg $path
	ls -ld $path
	else
  	echo "directory not available" >> $log
	fi

else
	if [ -d "$path" ]
        then
        echo "directory is avilable" >> $log
	ls -ld $path >> $log 2>&1
	service swiagentd stop
        sleep 1
        rm -rf $path >> $log 2>&1
        sleep 1
        lvcreate -L +2G -n solarwinds rhel && mkfs.xfs /dev/rhel/solarwinds && mkdir -p "$path" && mount /dev/rhel/solarwinds "$path" >> $log 2>&1
	sleep 2
	cp /etc/fstab /etc/fstab-bk$(date +%F)
	echo "/dev/mapper/rhel-solarwinds  /opt/SolarWinds	xfs defaults 1 2" >> /etc/fstab
        chown zmanageengine:bin $path
        chmod 775 $path
        df -Th $path
        ls -ld $path
	tail -1 /etc/fstab	
        else
        echo "directory not available" 
        fi


fi

cp /tmp/newlv-$(hostname)-log.txt /sa_work/sudhan/newlv/



