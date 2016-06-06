#!/bin/bash

rc=`/opt/bin/kubectl get rc $1 | awk 'NR!=1{print $5}'`
/opt/bin/kubectl scale rc $1 --replicas=$((10#${rc}+1))
