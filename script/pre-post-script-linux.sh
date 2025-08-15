#!/usr/bin/bash

b4reboot () {
logpath=/tmp
log=$logpath/`hostname`_b4reboot.log

rm -f $log
echo "############################################ kernel Version ############################################" >>$log
uname -r >>$log
echo "############################################ kernel_END ############################################" >>$log
echo "############################################ OS Version ############################################" >>$log
cat /etc/os-release | grep -w "VERSION=*" >>$log
echo "############################################ OS_END ############################################" >>$log
echo "############################################ File System ############################################" >>$log
df -Th >>$log
echo "############################################ FS_END ############################################" >>$log
echo "############################################ Running Services ############################################" >>$log
systemctl list-units --type=service --state=running | awk '{print $1}'| grep -vEi 'unit|load|active|sub|[0-9]|^$' >>$log
echo "############################################ Running_Services_END ############################################" >>$log
echo "############################################ Routing Table ############################################" >>$log
netstat -nr >>$log
echo "############################################ RT_END ############################################" >>$log
echo "############################################ netstat -nr ############################################" >>$log
netstat -nr|awk '{print $1 $2}'|sed -e '/^$/d' >>$log
echo "############################################ net_end ############################################" >>$log
echo "############################################ System Memory ############################################" >>$log
free -gh >>$log
echo "############################################ System Memory END ############################################" >>$log
echo "############################################ IPADDRESS ############################################" >>$log
ifconfig -a | grep -i inet | awk '{print $2}' | grep -i ^[0-9] >>$log
echo "############################################ IP_END ############################################" >>$log
echo "############################################ System Memory (MB) ############################################" >>$log
echo "RealMem=`free -gh | grep -i "mem" | awk '{print $2}'`"  >>$log
echo "PagingSpace=`free -gh | grep -i "swap" | awk '{print $2}'`" >>$log
echo "############################################ Mem_END ############################################" >>$log
echo "############################################ CPU ############################################" >>$log
lscpu | grep -iw "^CPU(S)" | sed 's/ //g' >>$log
echo "############################################ CPU_END ############################################" >>$log
echo "############################################ Disks ############################################" >>$log
lsblk >>$log
echo "############################################ D_END ############################################" >>$log
echo "############################################ pvs ############################################" >>$log
pvs >>$log
echo "############################################ pvs_END ############################################" >>$log
echo "############################################ vgs ############################################" >>$log
vgs >>$log
echo "############################################ vgs_END ############################################" >>$log
echo "############################################ lvs ############################################" >>$log
lvs >>$log
echo "############################################ lvs_END ############################################" >>$log
echo "############################################ IP_ROUTE ############################################" >>$log
ip route show >> $log
echo "############################################ IP_ROUTE_END ############################################" >>$log
echo "############################################ END ############################################" >>$log
echo "############################################ fstab ############################################" >>$log
cat /etc/fstab | grep -vE "^#|^$" >> $log
echo "############################################ fstab_END ############################################"  >>$log

}
afterbt () {
logpath=/tmp
log=$logpath/`hostname`_b4reboot.log

if [ ! -f ${log} ]
then
echo "Log file not exist $log"
exit
fi

echo $log
echo -e "\033[36m                            `date` \033[0m"
echo -e "\033[36m                            `hostname` \033[0m"


echo -e "\033[32m  Checking Kernel Version.....\033[0m"
old_version=$(cat $log |sed -n '/^#.*kernel Version.*#$/,/^#.*kernel_END.*#$/p' | grep -v "#" | awk '{print $1}')
current_version=$(uname -r)
if [ "$old_version" != "$current_version" ]
then
    echo -e "\033[31m  Kernel got updated from $old_version to $current_version  \033[0m"
else
        echo "No changes in Kernel version"
fi


echo -e "\033[32m  Filesystem Check.....\033[0m"
for i in `cat $log |sed -n '/^#.*File System.*#$/,/^#.*FS_END.*#$/p'|grep -v "#"|grep -v Filesystem|awk '{print $NF}'`
do
df -Th|grep -v Filesystem|awk '{print $NF}'|grep -x $i >/dev/null
if [ $? -eq 1 ]
then
echo -e "\033[31m Filesystem $i Missing \033[0m"
fi
done


echo -e "\033[32m  Service Check.....\033[0m"
for j in `cat $log |sed -n '/^#.*Running Services.*#$/,/^#.*Running_Services_END.*#$/p' | grep -v "#"`
do
systemctl status $j > /dev/null
if [ $? -ne 0 ]
then
echo -e "\033[31m Service $j not running \033[0m"
fi
done

echo -e "\033[32m  IP ADDRESS CHECK.....\033[0m"
for k in `cat $log|sed -n '/^#.*IPADDRESS.*#$/,/^#.*IP_END.*#$/p'|grep -v "^#"`
do
ifconfig -a | grep -i inet | awk '{print $2}'|grep -w $k > /dev/null
if [ $? -ne 0 ]
then
        echo -e "\033[31m IP address  $k not running \033[0m"
fi
done

echo -e "\033[32m  IP route Check.....\033[0m"
mapfile -t saved_routes < <(
    sed -n '/^#\+ IP_ROUTE #\+/,/^#\+ IP_ROUTE_END #\+/ {
        /^#/d  # Delete comment lines
        /^$/d  # Delete empty lines
        p      # Print remaining lines
    }' $log
)

for route in "${saved_routes[@]}"
do
ip route show | grep -qF "$route"
if [ $? -ne 0 ]
then
echo -e "\033[31m IP route is $route is missing \033[0m"
fi
done

echo -e "\033[32m  Disks Check.....\033[0m"
for disk in `cat $log |sed -n '/^#.*Disks.*#$/,/^#.*D_END.*#$/p'|grep -v "^#" | awk '{print $1}' | grep -i "^[a-z]"|grep -vi "Name"`
do
lsblk | grep -i $disk > /dev/null
if [ $? -ne 0 ]
then
echo -e "\033[31m Disk $disk is missing \033[0m"
fi
done

}

if [ "$1" == "-b" ]
then
b4reboot
if [ -f $log ]
then
echo "Generated log file at $log"
else
echo "can't find log file at $log"
fi
elif [ "$1" == "-a" ]
then
afterbt
else
echo -e "\033[32m  Use -b for before script -a for after script \033[0m"
fi
