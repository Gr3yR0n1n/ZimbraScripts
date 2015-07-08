#!/bin/sh

#Hapus Layar
clear

echo '###################################################################################'
echo '# Zimbra zcs-mail-import.sh ver 0.0.1                                             #'
echo '###################################################################################'

# /* Variable untuk bold */
ibold="\033[1m""\n===> "
ebold="\033[0m"

echo -n "Enter working input folder for Mail (eg: /tmp/zimbra/) : "
read inputFolder

mailFolder=$inputFolder/'mail'
echo "Mail folder: $mailFolder"
echo "Importing from: $mailFolder/user.lst"
for userName in $(cat $mailFolder/user.lst)
do
	echo "Importing $userName"
	/opt/zimbra/bin/zmmailbox -z -m $userName postRestURL "//?fmt=tgz&resolve=reset" $mailFolder/$userName.tgz
done

echo ""
echo "Mail Import Done!!"
