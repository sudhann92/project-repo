#!/bin/bash

for disk in $(lspv|awk '{print $1}')
do
if [[ $(lsmpio -ql "$disk"|grep  'Vendor Id:'|awk '{print $3}') == "DGC" && $(lsmpio -ql "$disk"|grep  'Product Id:'|awk '{print $3}') == "VRAID" && $(lsmpio -ql "$disk"|grep  'Capacity:'|awk '{print $2}') == "30.00GiB" ]]
then
echo " "
echo "$disk $(lspv|awk -v disks="$disk" '$1 == disks {print $3}')"
echo " "

read -p "READ ABOVE OUTPUT IF THE $disk 'NONE' press[y] OTHERWISE press[n] TO EXIT?" yn
    case $yn in
        [Yy]* ) 
		 echo " "
		 echo "************************************"
       		 echo "stopping avamar process......."
		 echo "************************************"
         	 /etc/rc.d/init.d/avagent stop
        	 sleep 5
		 echo " "
		 echo "************************************"
        	 echo "changing the disk atttributes $disk......."
		 echo "************************************"
        	 chdev -l "$disk" -a algorithm=round_robin -a queue_depth=64 -a reserve_policy=no_reserve -a max_transfer=0x100000 -P
                 process=$(ps -ef | grep -wi avamar | grep -v grep | grep -v "$0" |wc -l)
                 if [ "$process" -eq 0 ]
                 then
			echo "************************************"
		 	echo "service stopped Going to tar the avamar folder in /sa_work/sudhan/avar-folder/....."
			echo "************************************"
         	 	cd /var/avamar/ || exit
        	 	tar -cvf /sa_work/sudhan/avar-folder/avamar-"$(hostname)".tar *
        	 	sleep 10
			echo " "
			echo "****************************************"
		 	echo "Rename the old avamar folder /var/avamar to /var/avamar.old-backup........"
			echo "****************************************"
        	 	cd ..
        	 	mv /var/avamar /var/avamar.old-backup
                 	echo " "
			echo "************************************"
        	 	echo "creating the backup_00 vg & lv on $disk........."
			echo "************************************"
        	 	mkvg -y backupvg_00 -s 512 "$disk"
         	 	mklv -y lvavamar -t jfs2 backupvg_00 25G && crfs -v jfs2 -d /dev/lvavamar -m /var/avamar -A yes -a logname=INLINE && mount /var/avamar
        	 	sleep 5
		 	echo " "
		 else
			echo " Avamar process is running check manually script going to exit......."
		 exit
		 fi
		 
        	 df -Pg | grep -i "avamar" >/dev/null
        	 DIR1=$(echo $?)
         	 if [ "$DIR1" = 0 ]
        	 then
			echo "************************************"
        	 	echo "AVAMAR have a separate FS on servers......"
			echo "************************************"
       	 	 else
       		 	echo "NO AVAMAR Separate FS on servers script going to exit please check manually......"
		 exit
       		 fi
		 echo " "	
		 echo "***************************************"
       		 echo "Untaring the avamar content in new mount point......"
		 echo "****************************************"
       		 tar -xvf /sa_work/sudhan/avar-folder/avamar-"$(hostname)".tar -C /var/avamar/
       		 sleep 10
		 echo " "
       		 old=$(du -sm /var/avamar.old-backup |  awk '{print $1}'|cut -f1 -d ".")
       		 new=$(du -sm /var/avamar |  awk '{print $1}'|cut -f1 -d ".")
       		 if [ "$new" -ge "$old" ]
       		 then
			echo "*************************************"
       		 	echo "Untar completed sucessfully the size of NEW-FS="$new" MB OLD-FLD="$old" MB............ "
			echo "************************************"
      		 else
       		 	echo "some file is missing please check manually"
      		 fi
 		 echo " "
		 echo "************************************"
       		 echo "Starting the avamar agent........"
		 echo "************************************"
       		 /etc/rc.d/init.d/avagent start
      		 sleep 2

      		 service=$(ps -ef | grep -wi avamar | grep -v grep | grep -v "$0" |wc -l)
       		 if [ "$service" -gt 0 ]
       		 then    
			 echo "************************************"
       			 echo "Verified the AVAMAR service is running on server....."
			 echo "************************************"
       		 else
        	 	echo "AVAMAR Service is not running need to check on this server....."  
		 exit
       		 fi
		 echo " "
		 echo "************************************"
        	 echo "removing the tar backup folder only......"
		 echo "************************************"
       	 	#rm -rf /var/avamar.old-backup
       		 rm /sa_work/sudhan/avar-folder/avamar-"$(hostname)".tar
                 ;;
        [Nn]* ) 
        	echo "Seems already $disk assigned on backupvg_00";;
        * ) echo "Please answer yes or no.";;
    esac
fi
done

