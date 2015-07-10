#!/bin/bash

clear¬
 ¬
echo '###################################################################################'¬
echo '# Zimbra zcs-cos-import.sh ver 0.0.1                                              #'¬
echo '###################################################################################'¬

echo -n "Enter working input folder for COS (eg: /tmp/zimbra/) : "
read inputFolder

# Create COS
cosFolder=$inputFolder'/cos'
cosList=`cat $cosFolder/cos.lst`

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
	su - zimbra -c 'zmprov -l < '$cosFile
done

echo "Import Done!!"
echo ""
