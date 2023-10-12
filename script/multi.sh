#!/bin/bash

process="$#"


if [ 0 -eq "$process" ]
then
       echo "Message: string not supplied as argument!"

exit
fi

#service=$(ps -ef|grep "$process"|grep -v grep|grep -v $0 | wc -l)
for service in "$@"
do

 if [ "$(ps -ef|grep "$service"|grep -v grep|grep -v $0 | wc -l)" -ne 0 ]
then
        echo "Message.Statistic:$service is running"

else
        echo "Message.Statistic:$service is not running"
fi
done


