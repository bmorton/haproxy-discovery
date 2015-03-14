#!/bin/bash

export DOCKER_HOST_IP=`/sbin/ip route | awk '/default/ { print $3 }'`
export ETCDCTL_PEERS="http://${DOCKER_HOST_IP}:4001/"

confd -onetime -backend etcd -node ${DOCKER_HOST_IP}:4001/ -verbose
/usr/local/sbin/haproxy -f /etc/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
confd -watch -backend etcd -node ${DOCKER_HOST_IP}:4001/ -verbose
