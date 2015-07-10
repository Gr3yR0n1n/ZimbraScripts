# clear screen
clear

DEBUG=0

if [ $DEBUG == 1 ]; then
	echo ""
	echo '###################################################################################'
	echo '#                                                                                 #'
	echo '#                                                                                 #'
	echo '#                             Debug Mode: ON                                      #'
	echo '#                                                                                 #'
	echo '#                                                                                 #'
	echo '###################################################################################'
	echo ""
fi

echo ""
echo '###################################################################################'
echo '# Zimbra zcs-cos-import.sh                                                        #'
echo '###################################################################################'
echo ""

echo -n "Enter working input folder (e.g.: /tmp/zimbra/) : "
read inputFolder

# Create COS
cosFolder=$inputFolder'/cos'
cosList=`cat $cosFolder/cos.list`

arr=$(echo $cosList | tr " " "\n");
for cosName in $arr
do
	echo "Creating $cosName"
	su - zimbra -c 'zmprov -l cc '$cosName
done

# Modify Attributes
cosFileList=`ls $cosFolder/*.cos`
arr=$(echo $cosFileList | tr " " "\n");
for cosFile in $arr
do
	echo "Importing $cosFile"
	su - zimbra - c 'zmprov -l < '$cosFile
done

echo ""
echo " COS Import Done !! "
echo ""

echo ""
echo '###################################################################################'
echo "# Zimbra zcs-acc-import.sh
echo '###################################################################################'
echo ""

echo "Importing account..."

ZIMBRA_LDAP_PASSWORD=`/opt/zimbra/bin/zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3`
/opt/zimbra/bin/zmprov < $inputFolder/zcs-acc-add.zmp

echo "Modify password..."
/opt/zimbra/bin/zmprov < $inputFolder/zcs-acc-mod.ldif

echo ""
echo " Accounts Import Done !! "
echo ""

echo ""
echo '###################################################################################'
echo "# Zimbra zcs-dlist-import.sh
echo '###################################################################################'
echo ""

dlistFolder=$outputFolder'/dlist'
dlistFileList=`ls $dlistFolder/`
arr=$(echo $dListFileList | tr " " "\n");
for dlistFile in $arr
do
	echo "Importing $dlistFile"
	/opt/zimbra/bin/zmprov < $dlistFolder/dlistFile
done

echo ""
echo " DList Import Done !! "
echo ""

echo ""
echo '------------------------- Provisioning Export Complete !! -------------------------'
echo ""

