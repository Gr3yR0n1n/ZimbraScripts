# clear screen
clear

DEBUG=0

if [ $DEBUG == 1 ]; then
	echo ""
	echo '###################################################################################'¬
	echo '#                                                                                 #'
	echo '#                                                                                 #'
	echo '#                              Debug Mode: ON                                     #'¬
	echo '#                                                                                 #'
	echo '#                                                                                 #'
	echo '###################################################################################'¬
	echo ""
fi

echo ""
echo '###################################################################################'¬
echo '# Zimbra zcs-mail-export.sh ver 0.0.1                                             #'¬
echo '###################################################################################'¬
echo ""

echo -n "Enter working output folder for Mail (eg: /tmp/zimbra/) : "
read outputFolder
echo -n "Enter destination server : "
read destServer
echo -n "Enter destination user : "
read destUser
echo - "Enter destination password : "
read destPassword
echo -n "Enter destination folder: "
read destFolder


mailFolder=$outputFolder'/mail'
# Create Mail Folder
echo "Creating Mail output folder: $mailFolder"
su - zimbra -c 'mkdir '$mailFolder

echo "Retrieving User list"
userList=`su - zimbra -c 'zmprov -l gaa'`;

arr=$(echo $userList | tr " " "\n");
for userName in $arr
do
	if [ $userName = "default" ] || [ $userName = "defaultExternal" ]; then
		echo "Skipping system user, $userName..."
	else
		su - zimbra -c 'echo '$userName' >> '$mailFolder'/user.lst'
		echo "Exporting $userName"
		#su - zimbra -c 'zmprov -l gc '$cosName' > '$cosFolder'/'$cosName'.tmp'
		#cat $cosFolder/$cosName.tmp | sed 's/^/mc '$cosName' /g' | sed 's/: / /g' > $cosFolder/$cosName.cos
		/opt/zimbra/bin/zmmailbox -z -m $userName getRestURL "//?fmt=tgz" > $mailFolder/$userName.tgz

		echo "Moving $mailFolder/$userName.tgz to $destServer"
		from=$mailFolder'/'$userName'.tgz'
		to=$destUser@$destServer:$destFolder
		./zcs-mail-copy.sh $from $to $destPassword 

		echo "Removing mailbox backup for : $mailFolder/$userName.tgz"
		echo ""
		rm $mailFolder/$userName.tgz

	fi
done

#rm $mailFolder/*.tmp
chown zimbra:zimbra $mailFolder/*

echo ""
echo "Mail Done!!"
echo ""
echo "-------------------- Mail Export Complete !! --------------------"
echo ""
