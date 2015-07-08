#!/bin/sh

clear

echo -n "Email : "
read USER

/opt/zimbra/bin/ldapsearch -H ldapi:/// -w JV9sKhWgBe -D uid=zimbra,cn=admins,cn=zimbra -x "(&(objectClass=zimbraAccount)(mail=$USER))" | grep userPassword:

