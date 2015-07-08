#!/bin/sh

#Hapus Layar
clear

echo "###################################################################################"
echo "# Zimbra export-acc-zcs.sh ver 0.0.2                                              #"
echo "# Skrip untuk export account Zimbra berikut profile dan password                  #"
echo "# Masim 'Vavai' Sugianto - vavai@vavai.com - http://www.vavai.com                 #"
echo "# Untuk saran dan pertanyaan silakan menggunakan Milis Komunitas Zimbra Indonesia #"
echo "# Link Komunitas : http://www.zimbra.web.id - http://www.opensuse.or.id           #"
echo "###################################################################################"

# /* Variable untuk bold */
ibold="\033[1m""\n===> "
ebold="\033[0m"

# /* Parameter */
echo ""
echo -n "Enter Domain Name (ex : vavai.com) : "
read NAMA_DOMAIN
echo -n "Enter path folder for exported account (ex : /home/vavai/) : "
read FOLDER

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

echo $ibold"Retrieve Zimbra User.............................."$ebold

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

    		echo "$dn
changetype: modify
replace: userPassword
userPassword: $userPassword
" >> $LDIF_FILE
    		echo "Adding account $NAME"
	fi
else
	echo "Skipping account $NAME"
fi

done
echo $ibold"All account has been exported sucessfully into $NAMA_FILE and $LDIF_FILE..."$ebold


