#!/bin/bash

rc=`/opt/bin/kubectl get rc $1 | awk 'NR!=1{print $5}'`
if [ $((10#${rc})) == 1 ]
then 
  echo 'rc count is 1, cannot scale down'
  exit 
fi
/opt/bin/kubectl scale rc $1 --replicas=$((10#${rc}-1))
