FROM ubuntu:14.04
MAINTAINER Brian Morton "brian@mmm.hm"

ENV HAPROXY_VERSION 1.5.11

RUN apt-get update -y && apt-get install -y make gcc

# Compile haproxy
ADD http://www.haproxy.org/download/1.5/src/haproxy-$HAPROXY_VERSION.tar.gz /tmp/haproxy-$HAPROXY_VERSION.tar.gz
RUN cd /tmp && tar -zxvf haproxy-$HAPROXY_VERSION.tar.gz
RUN cd /tmp/haproxy-$HAPROXY_VERSION && make TARGET=generic && make install

# Setup confd for watching etcd for changes, regenerating the template, and reloading haproxy
ADD https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 /bin/confd
RUN chmod +x /bin/confd
RUN mkdir -p /etc/confd/conf.d
RUN mkdir -p /etc/confd/templates

RUN touch /var/run/haproxy.pid

ADD haproxy.toml /etc/confd/conf.d/haproxy.toml
ADD haproxy.cfg.tmpl /etc/confd/templates/haproxy.cfg.tmpl
ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 1936
EXPOSE 80

CMD ["/start.sh"]
