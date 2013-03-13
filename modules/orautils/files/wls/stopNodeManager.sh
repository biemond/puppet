#!/bin/sh
# *************************************************************************
# This script can be used to stop the WebLogic NodeManager
#

echo "Stopping Nodemanager..."

PID=`/bin/ps -eo pid,cmd | /bin/grep -i nodemanager.javahome | /bin/grep -v grep | awk '{print $1}'`

if [ ${PID} ]
then
   kill ${PID}
   echo "NodeManager with process ID ${PID} will be shutdown..."
else
   echo "No NodeManager process found!"
fi
