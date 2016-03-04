#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - MASTER_IP
# $4 - cAdvisor port
# $5 - API Address
# $6 - Auth Host
# $7 - Auth URL
# $8 - username/password
# $9 - region/tenant name

mkdir /var/log/kubernetes
mkdir -p /var/run/murano-kubernetes

AUTHHOST=$6
COMPUTEHOST=${AUTHHOST/identity/compute}
VOLUMEHOST=${AUTHHOST/identity/volume}

echo "$5   ${AUTHHOST}" >> /etc/hosts
echo "$5   ${COMPUTEHOST}" >> /etc/hosts
echo "$5   ${VOLUMEHOST}" >> /etc/hosts

SERVERID=`hostname | cut -c7-42`
echo $SERVERID > /etc/hostname
hostname $SERVERID

AUTHURI=$7
USERNAME_PWD=$8
REGION_TENANT=$9

USERNAME=`echo $USERNAME_PWD | cut -d / -f 1`
PASSWORD=`echo $USERNAME_PWD | cut -d / -f 2`
REGION=`echo $REGION_TENANT | cut -d / -f 1`
TENANT=`echo $REGION_TENANT | cut -d / -f 2`

sed -i.bkp "s%AUTHURL%$7%g" cloud_conf/cloud.conf
sed -i.bkp "s%USERNAME%${USERNAME}%g" cloud_conf/cloud.conf
sed -i.bkp "s%PASSWORD%${PASSWORD}%g" cloud_conf/cloud.conf
sed -i.bkp "s%REGION%${REGION}%g" cloud_conf/cloud.conf
sed -i.bkp "s%TENANTNAME%${TENANT}%g" cloud_conf/cloud.conf
cp cloud_conf/cloud.conf /root/

BODY="{\"auth\": {\"tenantName\": \"${TENANT}\",\"passwordCredentials\": {\"username\": \"${USERNAME}\",\"password\": \"${PASSWORD}\"}}}"
curl ${AUTHURI}/tokens -k -H "Content-Type:application/json" -X POST -d "$BODY" 2>/dev/null | grep "endpoints" >/dev/null && {
true
} || {
sed -i.bkp "s%openstack% %g" default_scripts/kubelet
sed -i.bkp "s%/root/cloud.conf% %g" default_scripts/kubelet
}

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
