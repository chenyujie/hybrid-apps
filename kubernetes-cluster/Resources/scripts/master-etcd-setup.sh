#!/bin/bash

# $1 - NAME
# $2 - IP
#
service etcd stop
rm -rf /var/lib/etcd
mkdir /var/lib/etcd

sed -i.bkp "s/%%NAME%%/$1/g" default_scripts/etcd-master
sed -i.bkp "s/%%IP%%/$2/g" default_scripts/etcd-master

cp -f default_scripts/etcd-master /etc/default/etcd
cp init_conf/etcd.conf /etc/init/

chmod +x initd_scripts/*
cp initd_scripts/etcd /etc/init.d/
service etcd start
sleep 5

/opt/bin/etcdctl mk /coreos.com/network/config '{"Network":"10.200.0.0/16"}'
