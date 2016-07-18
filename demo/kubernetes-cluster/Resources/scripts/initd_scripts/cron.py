import os
import json

rc=os.popen("/opt/bin/kubectl get rc | awk 'NR!=1{print $1}'").read().strip().split("\n")
#print rc
for i in rc:
    y=os.popen("/opt/bin/kubectl get rc %s -o json"%i).read()
    k=json.loads(y)
    if "annotations" in k["metadata"] and k["metadata"]["annotations"]["autoscale"] == "True":
	ips=os.popen("/opt/bin/kubectl get pod -o wide | grep %s | awk '{print $6}'"%(i+'-')).read()
        containers=os.popen("/opt/bin/kubectl get pod -o wide | grep %s | awk '{print $1}'" % (i+'-')).read().strip().split("\n")
	cons=[]
	for c1 in containers:
	    csr=os.popen("/opt/bin/kubectl get pod %s -o json" % c1).read() 
	    cons.append(json.loads(csr)["status"]["containerStatuses"][0]["containerID"].split('//')[1])
	#print cons
	if len(ips) == 0:
	    continue
	ips=list(ips.strip().split("\n"))
	kv={}
	#print ips
        for n in range(len(ips)):
	    print ips[n], cons[n]
            kv[ips[n]]=os.popen("getCpuLoad %s %s" % (ips[n],cons[n])).read().strip().split("\n")[0]
        for v in kv.itervalues():
	    nrc=int(k["status"]["replicas"])
	    #print nrc
	    #print int(v.strip("%")), int(k["metadata"]["annotations"]["high"]), int(k["metadata"]["annotations"]["low"])
	    print v.strip("%"), k["metadata"]["annotations"]["high"], k["metadata"]["annotations"]["low"]
	    if int(float(v.strip("%"))) >= int(k["metadata"]["annotations"]["high"]) and nrc <= 4:
		os.system('/opt/bin/kubectl scale rc %s --replicas=%s' % (i, nrc+1)) 
		print '%s scale up by 1' % i
		break
	    if int(float(v.strip("%"))) <= int(k["metadata"]["annotations"]["low"]) and nrc > 2:
                os.system('/opt/bin/kubectl scale rc %s --replicas=%s' % (i, nrc-1))
		print '%s scale down by 1' % i
		break
