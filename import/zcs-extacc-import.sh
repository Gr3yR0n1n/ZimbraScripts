#!/bin/bash

# clear screen


echo ""
echo '###################################################################################'
echo '# Zimbra zcs-extacc-import.sh                                                     #'
echo '###################################################################################'
echo ""

echo ""
echo -n "Enter working input folder (e.g.: /tmp/zimbra/) : "
read inputFolder

extAccFolder=$inputFolder'/extacc'

echo "Retrieving External Accounts"
extAccList=`ls $extAccFolder/*`

arr=$(echo $extAccList | tr " " "\n")
for extacc in $arr; do
		echo "Importing $extacc"
		/opt/zimbra/bin/zmprov < $extacc
done 

echo ""
echo "External Account Import Done !!"
echo ""
