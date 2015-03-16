# HAProxy with etcd discovery

This is a first pass at configuring HAProxy with etcd/confd to function similarly to [vulcand](https://github.com/mailgun/vulcand).  In this implementation, confd will watch the etcd namespaces `/haproxy/hosts` and `/haproxy/backends` to re-parse `haproxy.cfg` and gracefully reload.

Here's a sample of what it would look like to route all traffic from all paths at `hello.dev` to a backend named `hello-world`.

```
etcdctl set /haproxy/hosts/hello.dev/locations/test/path "/"
etcdctl set /haproxy/hosts/hello.dev/locations/test/backend "hello-world"
```

For the backend named `hello-world`, this is the key you'd need to add to start routing traffic to the specified backend/

```
etcdctl set /haproxy/backends/hello-world/servers/hello-world-1 "10.0.0.1:3000"
```

To do this automatically, you'd probably want your Fleet unit file (named `hello-world@.service` to look something like this:

```
[Unit]
Description=hello-world-%i
After=docker.service

[Service]
EnvironmentFile=/etc/environment
User=core
TimeoutStartSec=0
ExecStartPre=/usr/bin/docker pull mmmhm/hello-world:latest
ExecStartPre=-/usr/bin/docker rm -f hello-world-%i
ExecStart=/usr/bin/docker run --name hello-world-%i -p 3000 mmmhm/hello-world:latest
ExecStartPost=/bin/sh -c "sleep 10; /usr/bin/etcdctl set /haproxy/backends/hello-world/servers/hello-world-%i $COREOS_PRIVATE_IPV4:$(echo $(/usr/bin/docker port hello-world-%i 3000) | cut -d ':' -f 2)"
ExecStop=/bin/sh -c "/usr/bin/etcdctl rm '/haproxy/backends/hello-world/servers/hello-world-%i' ; /usr/bin/docker rm -f hello-world-%i"
```

Instead of setting up this configuration manually, you could use [deployster](https://github.com/bmorton/deployster) which has support coming soon for automating zero-downtime deploys using this load balancer setup.
