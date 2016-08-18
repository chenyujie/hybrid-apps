#!/bin/bash

sed -i.bkp "s/%%MASTER_IP%%/$1/g" default_scripts/flanneld
sed -i.bkp "s/%%IP%%/$2/g" default_scripts/flanneld

cp init_conf/flanneld.conf /etc/init/
chmod +x initd_scripts/flanneld
cp initd_scripts/flanneld /etc/init.d/
cp -f default_scripts/flanneld /etc/default/


service flanneld start

source /run/flannel/subnet.env 2> /dev/null
while [ -z "$FLANNEL_SUBNET" ]
do
  sleep 1
  source /run/flannel/subnet.env 2> /dev/null
done

ip link set dev docker0 down || echo docker0 failed to be down
brctl delbr docker0 || echo docker0 failed to be deleted

echo DOCKER_OPTS=\"-H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}\" > /etc/default/docker

echo post-up iptables -t nat -A POSTROUTING -s 10.200.0.0/16 ! -d 10.200.0.0/16 -j MASQUERADE >>  /etc/network/interfaces.d/eth0.cfg
iptables -t nat -A POSTROUTING -s 10.200.0.0/16 ! -d 10.200.0.0/16 -j MASQUERADE

service docker restart

touch /etc/default/etcd
