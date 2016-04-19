#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - REGISTRY
REGISTRY=$3

for((i=0;i<1800;i++)) ; do
    influxdb_ip=`/opt/bin/kubectl get pod --namespace=kube-system | grep 'influxdb-grafana-' | awk 'name=$1{system("/opt/bin/kubectl get pod/" name " --namespace=kube-system --template {{.status.podIP}}")}'`
    if [[ $influxdb_ip != "<no value>" && $influxdb_ip != '' ]]
    then
        break 
    fi
    #echo $influxdb_ip
    sleep 2
done
sed -i.bkp "s/##DOCKER_REGISTRY##/$REGISTRY/g" default_scripts/heapster-controller.yaml
sed -i.bkp "s/##HOST_IP##/$2/g" default_scripts/heapster-controller.yaml
sed -i.bkp "s/##INFLUXDB_IP##/$influxdb_ip/g" default_scripts/heapster-controller.yaml
/opt/bin/kubectl create -f default_scripts/heapster-service.yaml
/opt/bin/kubectl create -f default_scripts/heapster-controller.yaml