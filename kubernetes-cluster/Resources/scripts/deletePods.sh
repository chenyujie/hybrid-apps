#!/bin/bash
echo "Deleting Pods" >> /tmp/murano-kube.log
#/opt/bin/kubectl delete pod -l $1 >> /tmp/murano-kube.log
/opt/bin/kubectl get pod | awk -v name=$1 '$1==name{system("/opt/bin/kubectl delete pod " name)}' >> /tmp/murano-kube.log
