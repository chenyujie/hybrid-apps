#!/bin/sh

# $1 - CLUSTER
# $2 - MEMBERS
# $3 - NAME
# $4 - MASTER

service mysql stop || echo mysql stopped

sed -i.bkp "s/%%CLUSTER%%/$1/g" initd_scripts/my.cnf
sed -i.bkp "s/%%MEMBERS%%/$2/g" initd_scripts/my.cnf
sed -i.bkp "s/%%NAME%%/$3/g" initd_scripts/my.cnf
cp -f initd_scripts/my.cnf /etc/mysql/my.cnf

if [ $4 = 'true' ] ; then
  service mysql start --wsrep-new-cluster
  cp -f initd_scripts/rc.local.master /etc/rc.local
else
  service mysql start
  cp -f initd_scripts/rc.local.slave /etc/rc.local
fi

sleep 5
mysql -u root -pmagento -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'magento'"
