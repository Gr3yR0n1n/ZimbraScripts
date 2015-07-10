#!/bin/sh

#Hapus Layar
clear

echo '###################################################################################'
echo '# Zimbra import-zcs-acc.sh ver 0.0.1                                              #'
echo '# Skrip untuk import data account Zimbra                                          #'
echo '# Masim 'Vavai' Sugianto - vavai@vavai.com - http://www.vavai.com                 #'
echo '# Untuk saran dan pertanyaan silakan menggunakan Milis Komunitas Zimbra Indonesia #'
echo '# Link Komunitas : http://www.zimbra.web.id - http://www.opensuse.or.id           #'
echo '###################################################################################'

# /* Variable untuk bold */
ibold="\033[1m""\n===> "
ebold="\033[0m"


if [ "$USER" != "zimbra" ]
then
        echo $ibold"You need to be user zimbra to run this script..."$ebold
	exit
fi

CURRENT_FOLDER=`pwd`;

echo ""
echo "Please verify that you have copied zcs-acc-add.zmp & zcs-acc-mod.ldif on current folder !"
echo "Current Folder : $CURRENT_FOLDER, Please change to your folder before running this script."
echo "Press ENTER to continue..."
read jawab

if [ -f ./zcs-acc-add.zmp ];
then
   if [ -f ./zcs-acc-mod.ldif ];
	then
   		echo $ibold"Importing account..."$ebold

		ZIMBRA_LDAP_PASSWORD=`zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3`

#		cat ./zcs-acc-add.zmp | su - zimbra -c zmprov
		zmprov < $CURRENT_FOLDER/zcs-acc-add.zmp

		echo $ibold"Modify password..."$ebold

                
                ldapmodify -f "$CURRENT_FOLDER/zcs-acc-mod.ldif" -x -H ldapi:/// -D cn=config -w $ZIMBRA_LDAP_PASSWORD
                
#		su - zimbra -c '$LDAP_CMD'

		echo $ibold"Zimbra account has been modified sucessfully ..."$ebold

	else
   		echo "Sorry, file $CURRENT_FOLDER/zcs-acc-mod.ldif does not exists, import process will not be continue..."
		exit
	fi
else
   echo "Sorry, file $CURRENT_FOLDER/zcs-acc-add.zmp does not exists, import process will not be continue..."
   exit
fi

