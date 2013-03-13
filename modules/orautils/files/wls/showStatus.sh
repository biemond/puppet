AdminStatus=`/bin/ps -eo pid,cmd | /bin/grep -i AdminServer | /bin/grep -v grep | awk '{print $1}'`
SoaServer1Status=`/bin/ps -eo pid,cmd | /bin/grep -i soa_server1 | /bin/grep -v grep | awk '{print $1}'`
OsbServer1Status=`/bin/ps -eo pid,cmd | /bin/grep -i osb_server1 | /bin/grep -v grep | awk '{print $1}'`
NodeManagerStatus=`/bin/ps -eo pid,cmd | /bin/grep -i nodemanager.javahome | /bin/grep -v grep | awk '{print $1}'`

if [ ${AdminStatus} ]
then
  AdminPid=$AdminStatus
  AdminStatus="Online"
else
  AdminStatus='---'
  AdminPid="---"
fi

if [ ${SoaServer1Status} ]
then
  SoaServer1Pid=$SoaServer1Status
  SoaServer1Status="Online"
else
  SoaServer1Status='---'
  SoaServer1Pid="---"
fi

if [ ${OsbServer1Status} ]
then
  OsbServer1Pid=$OsbServer1Status
  OsbServer1Status="Online"
else
  OsbServer1Status='---'
  OsbServer1Pid="---"
fi

if [ ${NodeManagerStatus} ]
then
  NodeManagerPid=$NodeManagerStatus
  NodeManagerStatus="Online"
else
  NodeManagerStatus='---'
  NodeManagerPid="---"
fi


SEP=`printf "|%18s|%8s|%6s|\n" __________________ ________ ______`


echo " __________________________________"
printf "|%18s|%8s|%6s|\n" NAME STATUS PID
echo $SEP
printf "|%18s|%8s|%6s|\n" "AdminServer " $AdminStatus $AdminPid
printf "|%18s|%8s|%6s|\n" soa_server1 $SoaServer1Status $SoaServer1Pid
printf "|%18s|%8s|%6s|\n" osb_server1 $OsbServer1Status $OsbServer1Pid
echo $SEP
printf "|%18s|%8s|%6s|\n" NodeManager $NodeManagerStatus $NodeManagerPid
echo $SEP
