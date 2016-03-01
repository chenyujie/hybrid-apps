#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - MASTER_IP
# $4 - cAdvisor port

mkdir /var/log/kubernetes
mkdir -p /var/run/murano-kubernetes

cp cloud_conf/cloud.conf /root/
echo '58.60.106.60   identity.cloud.hybrid.huawei.com' >> /etc/hosts
echo '58.60.106.60   compute.cloud.hybrid.huawei.com' >> /etc/hosts
echo '58.60.106.60   volume.cloud.hybrid.huawei.com' >> /etc/hosts

SERVERID=`hostname | cut -c7-42`
echo $SERVERID > /etc/hostname
hostname $SERVERID
#source /etc/hostname

sed -i.bkp "s/%%MASTER_IP%%/$3/g" default_scripts/kube-proxy
sed -i.bkp "s/%%MASTER_IP%%/$3/g" default_scripts/kubelet
sed -i.bkp "s/%%IP%%/$2/g" default_scripts/kubelet

cp init_conf/kubelet.conf /etc/init/
cp init_conf/kube-proxy.conf /etc/init/

chmod +x initd_scripts/*
cp initd_scripts/kubelet /etc/init.d/
cp initd_scripts/kube-proxy /etc/init.d/

cp -f default_scripts/kube-proxy /etc/default
cp -f default_scripts/kubelet /etc/default/

service kubelet start
service kube-proxy start

sleep 1

/opt/bin/etcdctl -C http://$3:4001 mk /registry/services/endpoints/mapping/$2:4194 "$4"
