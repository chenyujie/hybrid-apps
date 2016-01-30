#!/bin/bash

# $1 - NAME
# $2 - MASTER_IP
# $3 - availabilityZone

for((i=0;i<15;i++)) ; do 
    /opt/bin/kubectl -s $2:8080 label nodes $1 az=$3 && break
	sleep 2
done
