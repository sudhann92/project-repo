#!/usr/bin/bash

if [ `cat /etc/redhat-release |awk '{print $7}'|cut -d '.' -f 1` -eq 7 ]
then

echo "Stopping swiagentd ...."
systemctl stop swiagentd
sleep 5

df -hP|grep /opt/SolarWinds
DFRC=`echo $?`
if [ "$DFRC" != 0 ] && [ -d /opt/SolarWinds ]
then 
echo "NO /opt/SolarWinds FS"
echo "Deleting /opt/SolarWinds ......"
#rm -rf /opt/SolarWinds
fi

RVG=`df -hP /|grep -v Filesystem|awk '{print $1}'|cut -d '/' -f4|cut -d '-' -f1`
FREEVG=`vgs|grep -i $RVG|awk '($NF ~ /g/){print $NF}'|cut -d '.' -f 1`

if [ $FREEVG > 2 ]
then
echo "Space is avaliable to creating /opt/SolarWinds......."
lvcreate -L +2G -n solarwinds $RVG && mkfs.xfs /dev/$RVG/solarwinds && mkdir -p /opt/SolarWinds
sleep 5
cp /etc/fstab /etc/fstab_`date +%Y%m%d_bkp` 
echo "Backed up fstab"
echo "/dev/mapper/$RVG-solarwinds  /opt/SolarWinds    xfs defaults 1 2" >>/etc/fstab
mount /opt/SolarWinds
df -hP|grep /opt/SolarWinds
MSTAT=`echo $?`
if [ "$MSTAT" = 0 ]
then 
echo "`df -hP|grep /opt/SolarWinds|awk '{print $NF}'` is Mounted."
echo "Changing Ownership & Permission" 
chown zmanageengine:bin /opt/SolarWinds
chmod 775 /opt/SolarWinds
fi 

else
echo "No Space in VG."
fi

elif [ `cat /etc/redhat-release |awk '{print $7}'|cut -d '.' -f 1` -eq 6 ]
then

echo "Stopping swiagentd ...."
service swiagentd stop
sleep 5

df -hP|grep /opt/SolarWinds
DFRC=`echo $?`
if [ "$DFRC" != 0 ] && [ -d /opt/SolarWinds ]
then 
echo "NO /opt/SolarWinds FS"
echo "Deleting /opt/SolarWinds ......"
rm -rf /opt/SolarWinds
fi


cp /etc/fstab /etc/fstab_`date +%Y%m%d`
RVG=`df -hP /|grep -v Filesystem|awk '{print $1}'|cut -d '/' -f4|cut -d '-' -f1`
FREEVG=`vgs|grep -i $RVG|awk '($NF ~ /g/){print $NF}'|cut -d '.' -f 1`

if [ $FREEVG > 2 ]
then
echo "Space is avaliable to creating /opt/SolarWinds......."
lvcreate -L +2G -n solarwinds $RVG && mkfs.ext4 /dev/$RVG/solarwinds && mkdir -p /opt/SolarWinds
sleep 5
echo "Backing up fstab"
cp /etc/fstab /etc/fstab_`date +%Y%m%d` 
echo "/dev/mapper/$RVG-solarwinds  /opt/SolarWinds    ext4 defaults 1 2" >>/etc/fstab
mount /opt/SolarWinds

df -hP|grep /opt/SolarWinds
MSTAT=`echo $?`
if [ "$MSTAT" = 0 ]
then 
echo "`df -hP|grep /opt/SolarWinds|awk '{print $NF}'` is Mounted."
echo "Changing Ownership & Permission" 
chown zmanageengine:bin /opt/SolarWinds
chmod 775 /opt/SolarWinds
fi 

else
echo "No Space in VG."
fi

fi
