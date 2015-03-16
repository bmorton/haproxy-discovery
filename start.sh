#!/bin/bash

export DOCKER_HOST_IP=`/sbin/ip route | awk '/default/ { print $3 }'`
export ETCDCTL_PEERS="http://${DOCKER_HOST_IP}:4001/"

service rsyslog restart

confd -onetime -backend etcd -node ${DOCKER_HOST_IP}:4001/ -verbose
/usr/local/sbin/haproxy -f /etc/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
nohup tail -f /var/log/haproxy.log &
confd -watch -backend etcd -node ${DOCKER_HOST_IP}:4001/ -verbose
