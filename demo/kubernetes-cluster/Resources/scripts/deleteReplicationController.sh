#!/bin/bash
echo "Deleting a replication controller" $1 >> /tmp/murano-kube.log
/opt/bin/kubectl delete replicationcontrollers $1 >> /tmp/murano-kube.log
#/opt/bin/kubectl get rc | awk -v name=$1 '$1==name{system("/opt/bin/kubectl delete rc  " name)}' >> /tmp/murano-kube.log
