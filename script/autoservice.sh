#!/bin/bash

service=`ps -ef | grep "service name" | grep -v grep | grep -v $0|wc -l`

if [ $service -gt 0 ]
then

echo "$service is running" > /dev/null
else

systemctl start "service name"

fi
exit 
