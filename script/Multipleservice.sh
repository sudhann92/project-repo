HOSTNAME=`hostname`
DATE=`date +%F`

items=( "commvault" "aex" "symantec" "postfix" "snmpd" )

for service in ${items[@]}

do

 if [ "$(ps -ef|grep "$service"|grep -v grep|grep -v $0 | wc -l)" -ne 0 ]

then

        echo -e "Message:$service.service is running \n" >> /tmp/test

else
        echo -e "Message:$service.service is not running \n"
fi

done

mail -s "$HOSTNAME.$DATE" xxx@gmail.com < /tmp/test

> /tmp/test
