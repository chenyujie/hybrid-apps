#!/bin/bash

# $1 - NAME
# $2 - IP

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

cp -f initd_scripts/getCpuLoad /usr/bin/
chmod +x /usr/bin/getCpuLoad
cp -f initd_scripts/cron.py /etc/default/
echo "*/1 *   * * *   root    python /etc/default/cron.py >> /var/log/autoscaleRC 2>&1" >> /etc/crontab

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

# $3 - REGISTRY
REGISTRY=$3
if [ ${REGISTRY}y = y ]; then REGISTRY='gcr.io'; fi
sed -i.bkp "s/##DOCKER_REGISTRY##/$REGISTRY/g" default_scripts/kube-ui-rc.yaml

RETRY=15
while [[ $RETRY -gt 0 && ! `curl -s 127.0.0.1:8080 -o /dev/null` ]]; do sleep 2; RETRY=`expr $RETRY - 1`; done

/opt/bin/kubectl create -f default_scripts/kube-ui-rc.yaml
/opt/bin/kubectl create -f default_scripts/kube-ui-svc.yaml

#/opt/bin/kubectl delete node 127.0.0.1
