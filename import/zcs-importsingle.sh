#!/bin/sh

CURRENT_FOLDER=`pwd`	
ZIMBRA_LDAP_PASSWORD=`zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3`

echo -e "Adding account..."
zmprov < $CURRENT_FOLDER/account.zmp

echo -e "Modify password..."
ldapmodify -f "$CURRENT_FOLDER/account.ldif" -x -H ldapi:/// -D cn=config -w $ZIMBRA_LDAP_PASSWORD
