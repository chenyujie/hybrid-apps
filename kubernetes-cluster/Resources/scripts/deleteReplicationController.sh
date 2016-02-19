#!/bin/bash
echo "Deleting a replication controller" >> /tmp/murano-kube.log
#/opt/bin/kubectl delete replicationcontrollers $1 >> /tmp/murano-kube.log
/opt/bin/kubectl get rc | awk -v name=$1 '$1==name{system("/opt/bin/kubectl delete rc  " name)}' >> /tmp/murano-kube.log

echo "Deleting autoscaler controller" >> /tmp/murano-kube.log
/opt/bin/kubectl get hpa | awk -v name=$1 '$1==name{system("/opt/bin/kubectl delete hpa " name)}' >> /tmp/murano-kube.log