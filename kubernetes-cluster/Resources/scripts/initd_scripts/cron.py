import os
import json

rc=os.popen("/opt/bin/kubectl get rc | awk 'NR!=1{print $1}'").read().strip().split("\n")
#print rc
for i in rc:
    y=os.popen("/opt/bin/kubectl get rc %s -o json"%i).read()
    k=json.loads(y)
    if "annotations" in k["metadata"] and k["metadata"]["annotations"]["autoscale"] == "True":
	ips=os.popen("/opt/bin/kubectl get pod -o wide | grep %s | awk '{print $6}'"%(i+'-')).read()
	if len(ips) == 0:
	    continue
	ips=list(set(ips.strip().split("\n")))
	kv={}
	#print ips
        for ip in ips:
            kv[ip]=os.popen("getCpuLoad %s" % ip).read().strip().split("\n")[0]
        for v in kv.itervalues():
	    nrc=int(k["status"]["replicas"])
	    #print nrc
	    #print int(v.strip("%")), int(k["metadata"]["annotations"]["high"]), int(k["metadata"]["annotations"]["low"])
	    if int(v.strip("%")) >= int(k["metadata"]["annotations"]["high"]) and nrc <= 6:
		os.system('/opt/bin/kubectl scale rc %s --replicas=%s' % (i, nrc+1)) 
		print '%s scale up by 1' % i
		break
	    if int(v.strip("%")) <= int(k["metadata"]["annotations"]["low"]) and nrc > 1:
                os.system('/opt/bin/kubectl scale rc %s --replicas=%s' % (i, nrc-1))
		print '%s scale down by 1' % i
		break
