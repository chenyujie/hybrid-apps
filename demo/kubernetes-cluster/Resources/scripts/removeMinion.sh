#!/bin/bash

# $1: IP
echo "Deleting a Minion" >> /tmp/murano-kube.log
/opt/bin/kubectl delete node $1 >> /tmp/murano-kube.log
/opt/bin/etcdctl rm /registry/services/endpoints/mapping/$1:4194 >> /tmp/murano-kube.log
