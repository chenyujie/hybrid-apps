#!/bin/bash
echo "Deleting a Service" $1 >> /tmp/murano-kube.log
/opt/bin/kubectl delete service $1 >> /tmp/murano-kube.log
#/opt/bin/kubectl get service | awk -v name=$1 '$1==name{system("/opt/bin/kubectl delete service " name)}' >> /tmp/murano-kube.log