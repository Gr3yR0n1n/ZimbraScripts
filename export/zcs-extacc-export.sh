#!/bin/bash

# clear screen


echo ""
echo '###################################################################################'
echo '# Zimbra zcs-extacc-export.sh                                                     #'
echo '###################################################################################'
echo ""

echo ""
#echo -n "Enter Domain Name (ex : zimbra.com) : "
#read domain
echo -n "Enter working output folder (e.g.: /tmp/zimbra/) : "
read outputFolder

extAccFolder=$outputFolder'/extacc'

# Create extacc Folder
echo "Creating extacc output folder: $extAccFolder"
su - zimbra -c 'mkdir '$extAccFolder

echo "Retrieving External Accounts"
extAccList=`su - zimbra -c 'zmprov -l gaa'`

arr=$(echo $extAccList | tr " " "\n")
isExternalAccount=FALSE
for extacc in $arr; do
	#echo "Exporting External Account: $extacc"
	isExternalAccount=`/opt/zimbra/bin/zmprov ga $extacc | grep zimbraIsExternalVirtualAccount | cut -d' ' -f2`
	#echo $isExternalAccount
	echo -n "."
	if [ "$isExternalAccount" = "TRUE" ]; then 
		echo ""
		echo "Exporting $extacc"
		#echo $extacc >> $extAccFolder/extacc.lst
		/opt/zimbra/bin/zmprov ga $extacc > $extAccFolder/$extacc.tmp
		cat $extAccFolder/$extacc.tmp | sed 's/^/ma '$extacc' /g' | sed 's/: / /g' > $extAccFolder/$extacc
	fi
done 

rm $extAccFolder/*.tmp
chown zimbra:zimbra $extAccFolder/*

echo ""
echo "External Account Export Done !!"
echo ""
