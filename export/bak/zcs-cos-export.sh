#!/bin/bash

clear¬

echo '###################################################################################'¬
echo '# Zimbra zcs-cos-export.sh ver 0.0.1                                              #'¬
echo '###################################################################################'¬

echo -n "Enter working output folder for COS (eg: /tmp/zimbra/) : "
read outputFolder
 
cosFolder=$outputFolder'/cos'
# Create COS Folder
echo "Creating COS output folder: $cosFolder"
su - zimbra -c 'mkdir '$cosFolder

echo "Retrieving COS name list"
cosList=`su - zimbra -c 'zmprov gac'`;

arr=$(echo $cosList | tr " " "\n");
for cosName in $arr
do
	su - zimbra -c 'echo '$cosName' >> '$cosFolder'/cos.lst'
	echo "Exporting $cosName"
	su - zimbra -c 'zmprov -l gc '$cosName' > '$cosFolder'/'$cosName'.tmp'
	cat $cosFolder/$cosName.tmp | sed 's/^/mc '$cosName' /g' | sed 's/: / /g' > $cosFolder/$cosName.cos
done

rm $cosFolder/*.tmp
chown zimbra:zimbra $cosFolder/*

echo ""
echo "Export Done!!"

