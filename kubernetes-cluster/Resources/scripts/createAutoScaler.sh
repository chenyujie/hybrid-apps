#!/bin/bash

# $1 - minreplicas
# $2 - maxreplicas
# $3 - cpuPercent
# $4 - name

/opt/bin/kubectl autoscale rc $4 --cpu-percent=$3 --min=$1 --max=$2