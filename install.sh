#!/bin/sh
set -e

apk update
apk upgrade

edge_community_repo="http://dl-4.alpinelinux.org/alpine/edge/community"

echo "$edge_community_repo" >> /etc/apk/repositories
apk update
apk add git gcc make musl-dev bash unzip zip tar curl

echo '----- Installing Consul -----'
cd /tmp
curl -o consul.zip -L https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul.zip
chmod +x consul
mv consul /usr/bin
mkdir /consul

echo '----- Installing Consul UI -----'
cd /tmp
curl -o ui.zip -L https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip
unzip ui.zip
mv static /consul-ui/static
mv index.html /consul-ui/index.html

echo '----- Installing dumb-init -----'
unzip /install/dumb-init-hacked.zip -d /tmp
cd /tmp/dumb-init-hacked
make
mv dumb-init-hacked /sbin/

echo '---- Installing runit ----'
unzip /install/runit-2.1.2-hacked.zip -d /tmp
cd /tmp/runit-2.1.2-hacked/src
make
cp chpst runit runit-init runsv runsvchdir runsvdir sv svlogd utmpset /sbin

echo '----- cleaning up apk packages -----'
apk del git gcc make musl-dev bash unzip zip tar curl
echo "$(grep -v "$edge_community_repo" /etc/apk/repositories)" > /etc/apk/repositories

# Install node.js syslog-ng zeromq initsh bashalias
apk add syslog-ng
cp /install/bash /bin/

mkdir -p /etc/syslog-ng/
cp /install/syslog-ng.conf /etc/syslog-ng/

mkdir -p /etc/service/
cp -r /install/runit-services/* /etc/service/

# Clean up
rm -rf /install
rm -rf /tmp/*
rm -rf /var/cache/apk/*
