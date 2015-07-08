myPath=$(pwd)
/opt/zimbra/bin/zmprov gadl | while read listname;
do
   echo "/opt/zimbra/bin/zmprov cdl $listname" > $myPath/$listname
   /opt/zimbra/bin/zmprov gdl $listname | grep zimbraMailForwardingAddress >  $myPath/$listname.tmp
   cat $myPath/$listname.tmp | sed 's/zimbraMailForwardingAddress: //g' |
   while read member; do
     echo "/opt/zimbra/bin/zmprov adlm $listname $member" >> $myPath/$listname
   done
   /bin/rm $myPath/$listname.tmp
done
