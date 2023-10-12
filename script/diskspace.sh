#!/bin/bash
#purpose : Monitor the disk space
#Today date :Sun Apr 14 17:43:41 EDT 2019
#Author:Sudhan
#START
Threshould=90
for path in $(df -Th | grep -vE "Filesystem|tmpfs" | awk '{print $6}'|sed 's/%//g')
do
        if [ "$path" -ge "$Threshould" ]
then
        disk=$(df -h | grep "$path")
        echo "$disk space consuming more"| mail -s "Disk Space Alert" xxx@gmail.com
fi

done
