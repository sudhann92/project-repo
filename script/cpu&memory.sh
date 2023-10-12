#!/bin/bash
#purpose :
#Today date :Sat Apr 13 17:10:48 EDT 2019
#Author:
#START

critical=98
warning=95

CPULoad=`top -b -n 2 -d1 | grep -i "cpu(s)" | tail -n1 | awk '{print $2}'| awk -F . '{print $1}'`
if [ "$CPULoad" -ge "$warning" ] && ["$CPULoad" -lt "$critical" ]
then
        echo "CPU is $CPULoad warning state" | mail -s "CPU warning alert" xxx@gmail.com


        elif [ "$CPULoad" -ge "$critical" ]
then
        echo "CPU $CPULoad is critical" mail -s "CPU Critical alert" xxx@gmail.com


        else
        echo  "CPU utlisation $CPULoad below warning state"



fi

critical=1000  ## you can give the thereshold valu as per your requirement 
warning=500
Memory=`free -m -c 2 | grep -i "mem:"|awk '{print $3}'|tail -n1`

if [ "$Memory" -ge "$warning" ] && [ "$Memory" -lt "$critical" ]
then
        echo "memory is $Memory warning state" | mail -s "memory warning alert" xxx@gmail.com

        elif [ "$Memory" -ge "$critical" ]
then
        echo "memory $Memory is critical state" | mail -s "memory Critical alert" xxx@gmail.com


else

echo "Memory is $Memory below warning state"

fi






#END
