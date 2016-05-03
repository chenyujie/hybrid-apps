#!/bin/bash
# $1 - RC name

rc=$1"-"
echo $rc
/opt/bin/kubectl get pod -o wide | grep $rc | awk '{print $6}' | python -c 'import os;r=os.read(0,2**16);kv={};
if len(r)==0:import sys;print kv;sys.exit(1);
l=list(set(r.strip().split("\n")));p=""
for i in l:kv[i]=os.popen("getCpuLoad %s" % i).read().strip().split("\n")[0];
print kv;'
