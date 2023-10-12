#!/bin/bash
flavor=$(uname)
if [ "$flavor" = Linux ]
then
echo -e "\033[32m Checking the AVAMAR separate FS.......... \033[0m"
df -Th|grep -i avamar >/dev/null
DIR=$(echo $?)
if [ "$DIR" != 0 ] 
then
echo -e "\033[31m NO separate FS for AVAMAR on above servers. \033[0m" 
else
echo -e "\033[32m AVAMAR have a Separate FS on above servers \033[0m"
fi
service=$(ps -ef | grep -wi avamar | grep -v grep | grep -v $0 |wc -l)
if [ $service -gt 0 ]
then
echo -e "\033[32m AVAMAR service is running on above servers \033[0m"
else
echo -e "\033[31m AVAMAR Service is not running need to check on this server  \033[0m"
fi

else
echo "This is AIX server........"
echo -e "\033[32m Checking the AVAMAR separate FS.......... \033[0m"
df -g | grep -i avamar >/dev/null
DIR1=$(echo $?)
if [ "$DIR1" != 0 ] 
then
echo -e "\033[31m NO separate FS for AVAMAR on above servers. \033[0m"
else
echo -e "\033[32m AVAMAR have a Separate FS on above servers \033[0m"
fi
service=$(ps -ef | grep -wi avamar | grep -v grep | grep -v $0 |wc -l)
if [ "$service" -gt 0 ]
then
echo -e "\033[32m AVAMAR service is running on above servers \033[0m"
else
echo -e "\033[31m AVAMAR Service is not running need to check on this server  \033[0m"
fi

fi
