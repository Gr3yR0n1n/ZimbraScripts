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
echo '# Zimbra zcs-dlist-export.sh  ver 0.0.1                                                 #'¬
echo '###################################################################################'¬
echo ""

echo ""
echo -n "Enter Domain Name (ex : zimbra.com) : "
read NAMA_DOMAIN
echo -n "Enter working output folder (e.g.: /tmp/zimbra/) : "
read outputFolder

dlistFolder=$outputFolder'/dlist'

# Ccreate DList Folder
echo "Creating DList output folder: $dlistFolder"
su - zimbra -c 'mkdir '$dlistFolder

echo "Retrieving DList"
dlist=`su - zimbra -c 'zmprov gadl'`

arr=$(echo $dlist | tr " " "\n")
for dlistName in $arr
do
	echo "Exporting $dlistName"
	echo "cdl $dlistName" > $dlistFolder'/'$dlistName
	/opt/zimbra/bin/zmprov gdl $dlistName | grep zimbraMailForwardingAddress > $dlistFolder/$dlistName.tmp
	cat $dlistFolder/$dlistName.tmp | sed 's/zimbraMailForwardingAddress: //g' |
	while read member; do
		echo "adlm $dlistName $member" >> $dlistFolder/$dlistName
	done
done
rm $dlistFolder/*.tmp

echo ""
echo "DList Done!!"

if [ $DEBUG == 1 ]; then
	exit
fi

echo ""
echo '###################################################################################'¬
echo '# Zimbra zcs-cos-export.sh ver 0.0.1                                              #'¬
echo '###################################################################################'¬
echo ""

#echo -n "Enter working output folder for COS (eg: /tmp/zimbra/) : "
#read outputFolder
 
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
echo "COS Done!!"

echo ""
echo "###################################################################################"
echo "# Zimbra export-acc-zcs.sh ver 0.0.2                                              #"
echo "###################################################################################"
echo ""

# /* Variable untuk bold */
FOLDER=$outputFolder

# /* Membuat file hasil export dan mengisi nama domain */
NAMA_FILE="$FOLDER/zcs-acc-add.zmp"
LDIF_FILE="$FOLDER/zcs-acc-mod.ldif"

rm -f $NAMA_FILE
rm -f $LDIF_FILE

touch $NAMA_FILE
touch $LDIF_FILE

echo "createDomain $NAMA_DOMAIN" > $NAMA_FILE

# /* Check versi Zimbra yang digunakan */
VERSION=`su - zimbra -c 'zmcontrol -v'`;
ZCS_VER="/tmp/zcsver.txt"
# get Zimbra LDAP password
ZIMBRA_LDAP_PASSWORD=`su - zimbra -c "zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3"`

touch $ZCS_VER
echo $VERSION > $ZCS_VER

echo "Retrieve Zimbra User.............................."

#grep "Release 8." $ZCS_VER
#if [ $? = 0 ]; then
#USERS=`su - zimbra -c 'zmprov gaa'`;
#LDAP_MASTER_URL=`su - zimbra -c "zmlocalconfig -s ldap_master_url | cut -d ' ' -f3"`
#echo $LDAP_MASTER_URL
#fi

grep "Release 8." $ZCS_VER
if [ $? = 0 ]; then
USERS=`su - zimbra -c 'zmprov -l gaa'`;
LDAP_MASTER_URL="ldapi:///"
echo $LDAP_MASTER_URL
fi

echo $ibold"Processing account, please wait.............................."$ebold
# /* Proses insert account kedalam file hasil export */
for ACCOUNT in $USERS; do
NAME=`echo $ACCOUNT`;
DOMAIN=`echo $ACCOUNT | awk -F@ '{print $2}'`;
ACCOUNT=`echo $ACCOUNT | awk -F@ '{print $1}'`;
ACC=`echo $ACCOUNT | cut -d '.' -f1`

#if [ $NAMA_DOMAIN == $DOMAIN ] ;
if [ X"$NAMA_DOMAIN" = X"$DOMAIN" ] ;
then
OBJECT="(&(objectClass=zimbraAccount)(mail=$NAME))"
dn=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep dn:`


displayName=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep displayName: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`


givenName=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep givenName: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

userPassword=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep userPassword: | cut -d ':' -f3 | sed 's/^ *//g' | sed 's/ *$//g'`


cn=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep cn: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

initials=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep initials: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

sn=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep sn: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

zimbraIsExternalVirtualAccount=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep zimbraIsExternalVirtualAccount: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

	if [ $ACC = "admin" ] || [ $ACC = "wiki" ] || [ $ACC = "galsync" ] || [ $ACC = "ham" ] || [ $ACC = "spam" ] || [ $ACC = "virus-quarantine" ]; then
    		echo "Skipping system account, $NAME..."
	else
		echo "createAccount $NAME passwordtemp displayName '$displayName' givenName '$givenName' sn '$sn' initials '$initials' zimbraIsExternalVirtualAccount '$zimbraIsExternalVirtualAccount' zimbraPasswordMustChange FALSE" >> $NAMA_FILE

#    		echo "$dn
#changetype: modify
#replace: userPassword
#userPassword: $userPassword
#" >> $LDIF_FILE
    		echo "Adding account $NAME"
	fi
else
	echo "Skipping account $NAME"
fi

done

/opt/zimbra/bin/zmprov -l gaa -v $DOMAIN | egrep "^# name |userPassword" | tr '\n' ' ' | tr '#' '\n' | sed 's/^ name/ma/' | tr -d ':' | egrep userPassword > $LDIF_FILE

echo ""
echo "All account has been exported sucessfully into $NAMA_FILE and $LDIF_FILE..."
echo ""


echo ""
echo "-------------------- Provisioning Export Complete !! --------------------"
echo ""
