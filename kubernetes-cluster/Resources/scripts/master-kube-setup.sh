#!/bin/bash

# $1 - NAME
# $2 - IP

#add key generate in etcd setup
hostname=`hostname`
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=$hostname" -days 5000 -out ca.crt
openssl genrsa -out server.key 2048
openssl req -new -key server.key -subj "/CN=$hostname" -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 5000
mkdir -p /opt/kube-ca/
cp ca.crt ca.key ca.srl server.crt server.csr server.key /opt/kube-ca/

#service kube-proxy stop
service kube-scheduler stop
service kube-controller-manager stop
#service kubelet stop
service kube-apiserver stop

#Disable controller-manager for now
#chmod -x /etc/init.d/kube-controller-manager

#Create log folder for Kubernetes services
mkdir /var/log/kubernetes
mkdir -p /var/run/murano-kubernetes

sed -i.bkp "s/%%MASTER_IP%%/$2/g" default_scripts/kube-scheduler

cp -f default_scripts/kube-apiserver /etc/default/
cp -f default_scripts/kube-scheduler /etc/default/
cp -f default_scripts/kube-controller-manager /etc/default/

cp init_conf/kube-apiserver.conf /etc/init/
cp init_conf/kube-controller-manager.conf /etc/init/
cp init_conf/kube-scheduler.conf /etc/init/

chmod +x initd_scripts/*
cp initd_scripts/kube-apiserver /etc/init.d/
cp initd_scripts/kube-controller-manager /etc/init.d/
cp initd_scripts/kube-scheduler /etc/init.d/

service kube-apiserver start
service kube-scheduler start
service kube-controller-manager start

sleep 1

RETRY=30
while [[ `ss -tln|grep 8080|wc -l` = 0 && $RETRY -gt 0 ]]; do
  sleep 1
  RETRY=`expr $RETRY - 1`
done

# $3 - REGISTRY
REGISTRY=$3
if [ ${REGISTRY}y = y ]; then REGISTRY='gcr.io'; fi
sed -i.bkp "s/##DOCKER_REGISTRY##/$REGISTRY/g" default_scripts/kube-ui-rc.yaml
/opt/bin/kubectl create -f default_scripts/kube-ui-rc.yaml
/opt/bin/kubectl create -f default_scripts/kube-ui-svc.yaml
/opt/bin/etcdctl mk /registry/services/endpoints/mapping/$2:8080 "8080"

#/opt/bin/kubectl delete node 127.0.0.1

#run heapster service together with influxdb and grafana
sed -i.bkp "s/##DOCKER_REGISTRY##/$REGISTRY/g" default_scripts/influxdb-grafana-controller.yaml
/opt/bin/kubectl create -f default_scripts/kube-account.yaml
/opt/bin/kubectl create -f default_scripts/grafana-service.yaml
/opt/bin/kubectl create -f default_scripts/influxdb-service.yaml
/opt/bin/kubectl create -f default_scripts/influxdb-grafana-controller.yaml

# $4 - gatewayIP
#bash default_scripts/heapster_waiting.sh $1 $2 $3 &
/opt/bin/etcdctl mk /registry/services/endpoints/mapping/$2:8086 "8086"
sed -i.bkp "s/##DOCKER_REGISTRY##/$REGISTRY/g" default_scripts/heapster-controller.yaml
sed -i.bkp "s/##HOST_IP##/$2/g" default_scripts/heapster-controller.yaml
sed -i.bkp "s/##INFLUXDB_IP##/$4/g" default_scripts/heapster-controller.yaml
/opt/bin/kubectl create -f default_scripts/heapster-service.yaml
/opt/bin/kubectl create -f default_scripts/heapster-controller.yaml
