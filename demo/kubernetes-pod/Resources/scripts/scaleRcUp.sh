#!/bin/bash

rc=`/opt/bin/kubectl get rc $1 | awk 'NR!=1{print $5}'`

if [ $2y = y ]
then
  /opt/bin/kubectl scale rc $1 --replicas=$((10#${rc}+1))
else
  /opt/bin/kubectl scale rc $1 --replicas=$((10#${rc}+1)) --scaleTo="$2"
fi
