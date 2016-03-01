#!/bin/bash

#  File with pod is /tmp/pod.json
# $1 new or update
DEFINITION_DIR=/var/lib/murano-kubernetes
mkdir -p $DEFINITION_DIR

podId=$2
fileName=$3
az=$4

echo "$podId Pod $fileName" >> $DEFINITION_DIR/elements.list

if [ $az != "NULL" ]; then
    node=`/opt/bin/kubectl get nodes | grep $az | awk '{print $1}'`
    if [ -z $node ]; then
        echo "AZ ${az} could not be found" 
        exit 1
    fi
fi

if [ "$1" == "True" ]; then
  #new Pod
  echo "Creating a new Pod" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f $fileName >> /tmp/murano-kube.log
else
  echo "Updating a Pod" >> /tmp/murano-kube.log
  /opt/bin/kubectl replace --force -f $fileName >> /tmp/murano-kube.log
fi
