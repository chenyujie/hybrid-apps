#!/bin/bash
# $1 - RC name

#rc=$1"-"
#echo $rc

/opt/bin/kubectl get node -o wide | awk 'NR!=1{print $1}' | python -c 'import os;r=os.read(0,2**16);kv=0;
if len(r)==0:import sys;print str(kv)+"%";sys.exit(1);
l=list(set(r.strip().split("\n")));p=""
for i in l:kv+=float(os.popen("getCpuLoad %s NULL" % i).read().strip().split("\n")[0].strip("%"));
kv=kv/len(l);print str(kv)+"%";'
