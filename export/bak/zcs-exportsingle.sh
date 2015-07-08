#!/bin/sh

echo -n "User email : "
read NAME

echo -n "Domain name : "
read DOMAIN

echo -n "Account name : "
read ACC

#NAME='admin@cidb.gov.my';
#DOMAIN='cidb.gov.my';
#ACC='admin'

VERSION=`su - zimbra -c 'zmcontrol -v'`;
ZCS_VER="/tmp/zcsver.txt"

FOLDER=`pwd`
#echo -n "Export folder : "
#read FOLDER;


ZIMBRA_LDAP_PASSWORD=`su - zimbra -c "zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3"`

touch $ZCS_VER
echo $VERSION > $ZCS_VER

echo -e $ibold"Retrieve Zimbra User.............................."$ebold

grep "Release 5." $ZCS_VER
if [ $? = 0 ]; then
	LDAP_MASTER_URL=`su - zimbra -c "zmlocalconfig -s ldap_master_url | cut -d ' ' -f3"`
fi

grep "Release 6." $ZCS_VER
if [ $? = 0 ]; then
	LDAP_MASTER_URL="ldapi:///"
fi

grep "Release 7." $ZCS_VER
if [ $? = 0 ]; then
        LDAP_MASTER_URL="ldapi:///"
fi


LDIF_FILE="$FOLDER/account.ldif"
NAMA_FILE="$FOLDER/account.zmp"
touch $LDIF_FILE
touch $NAMA_FILE


	OBJECT="(&(objectClass=zimbraAccount)(mail=$NAME))"
	dn=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep dn:`

	displayName=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep displayName: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

	givenName=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep givenName: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

	userPassword=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep userPassword: | cut -d ':' -f3 | sed 's/^ *//g' | sed 's/ *$//g'`
	cn=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep cn: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

	initials=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep initials: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

	sn=`/opt/zimbra/bin/ldapsearch -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep sn: | cut -d ':' -f2 | sed 's/^ *//g' | sed 's/ *$//g'`

                echo "createAccount $NAME passwordtemp displayName '$displayName' givenName '$givenName' sn '$sn' initials '$initials' zimbraPasswordMustChange FALSE" >> $NAMA_FILE

                echo "$dn
changetype: modify
replace: userPassword
userPassword:: $userPassword
" >> $LDIF_FILE
                echo "Adding account $NAME"
