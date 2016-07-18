#!/bin/bash

# $1 - MASTER_IP
# $2 - IP
# $3 - AZ

mkdir /var/log/kubernetes
mkdir -p /var/run/murano-kubernetes

sed -i.bkp "s/%%MASTER_IP%%/$1/g" default_scripts/kube-proxy
sed -i.bkp "s/%%MASTER_IP%%/$1/g" default_scripts/kubelet
sed -i.bkp "s/%%IP%%/$2/g" default_scripts/kubelet

cp -f init_conf/kubelet.conf /etc/init/
cp -f init_conf/kube-proxy.conf /etc/init/

chmod +x initd_scripts/*
cp -f initd_scripts/kubelet /etc/init.d/
cp -f initd_scripts/kube-proxy /etc/init.d/

cp -f default_scripts/kube-proxy /etc/default
cp -f default_scripts/kubelet /etc/default/

service kubelet start
service kube-proxy start

RETRY=15
while [[ $RETRY -gt 0 && ! `curl -s $1:8080 -o /dev/null` ]]; do sleep 2; RETRY=`expr $RETRY - 1`; done

/opt/bin/kubectl -s $1:8080 label nodes $2 az=$3
