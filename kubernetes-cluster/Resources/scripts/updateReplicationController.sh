#!/bin/bash

if [ $2 != "NULL" ]; then
    node=`/opt/bin/kubectl get nodes | grep $2 | awk '{print $1}'`
    if [ -z $node ]; then
        echo "AZ $2 could not be found" 
        exit 1
    fi    
fi

if [ "$1" == "True" ]; then
  echo "Creating a new Replication Controller" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f /tmp/controller.json >> /tmp/murano-kube.log
else
  echo "Updating a Replication Controller" >> /tmp/murano-kube.log
  /opt/bin/kubectl update -f /tmp/controller.json >> /tmp/murano-kube.log
fi
