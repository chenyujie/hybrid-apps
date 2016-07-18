#!/bin/bash

source /etc/default/docker
DOCKER_OPTS+=" --registry-mirror=http://$1 --insecure-registry $1"
echo DOCKER_OPTS=\"$DOCKER_OPTS\" > /etc/default/docker

service docker restart