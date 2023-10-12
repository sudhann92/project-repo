#!/bin/bash
#Stopped the AAP related services
#uninstalled the automation controller service from server
#stopped the desired services and Remove the related package from server
#Delete the mount point and folders

service_items=("automation-controller.service" "postgresql.service" "redis.service" "nginx.service" "supervisord.service" "receptor.service")

for service in "${service_items[@]}"
do
systemctl status $service > /dev/null 2>&1
service_val=$(echo $?)
    if [ "$service_val" == 0 ]
    then
        echo "Stopping the $service service......"
        systemctl stop "$service"
        sleep 2 
    else
       echo "Service not available or service already stopped..............."
    fi
done

echo "Stopped the AAP services............"

 

if [ "$(ps -ef|grep "awx"|grep -v grep|grep -v "$0" | wc -l)" == 0 ]
then
   echo "All Service are stopped for AAP proceeding Removal packages............."
   yum remove -y automation-controller\*
   sleep 2
   yum remove -y redis*
   sleep 2
   yum remove -y postgresql*
   sleep 2
   yum remove -y receptor\*
else
   echo "Seems some process runing kindly check manually and proceed it.............."
   exit 1
fi

echo "Removed the AAP package from server successfully........."

echo "take back up for fstab file............."
cp /etc/fstab /etc/fstab_'$(date +%F)_bkup'
for lvs_value in $(lvs | grep -i appvg | grep -ivE "applogvol|appvol|pgbackupvol|aap2" | awk '{print $1}')
do
df -Th|grep -w "$lvs_value" > /dev/null 2>&1
DFRC=$(echo $?)
    if [ "$DFRC" == 0 ]
    then
       mountpoint=$(df -Th | grep -w "$lvs_value" | awk '{print $1}')
       FS_value=$(df -Th | grep -w "$lvs_value" | awk '{print $7}')
       echo "unmount the $FS_value from the FS............"
       umount $FS_value
       echo "commenting the $mountpoint in /etc/fstab file........."
       sed -i "s|$mountpoint|#$mountpoint|g" /etc/fstab
       echo "removing the LVM from FS"
       lvremove -f appvg/"$lvs_value"

    else
      echo "No $lvs_value mount point available in FS.........."
    fi
done

echo "Difference of old & new FSTAB.............."
echo "-----------------------------------------"
diff /etc/fstab /etc/fstab_'$(date +%F)_bkp)'
echo "------------------------------------------"
echo ""
echo " Removing the AAP Related Folder(pgsql,awx,rabbitmq,data,ansible-automation-platform-bundle,receptor) from the Server......"
rm -rf /etc/tower /var/lib/{pgsql,awx,rabbitmq}
rm -rf /var/lib/pgsql/data
rm -rf /var/lib/ansible-automation-platform-bundle
rm -rf /var/lib/receptor


##Delete the mountpoint in /etc/fstab
##df -Th | grep -w awx | awk '{print $1}' | cut -d '/' -f4
## sed  "/$s/d" /etc/fstab
