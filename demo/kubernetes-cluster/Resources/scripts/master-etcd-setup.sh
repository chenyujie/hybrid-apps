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

RETRY=15
while [[ $RETRY -gt 0 && ! `curl -s 127.0.0.1:4001 -o /dev/null` ]]; do sleep 3; RETRY=`expr $RETRY - 1`; done

sleep 3

/opt/bin/etcdctl mk /coreos.com/network/config '{"Network":"10.200.0.0/16"}'
