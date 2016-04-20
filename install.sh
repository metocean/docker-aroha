#!/bin/sh
set -e

apk update
apk upgrade

edge_community_repo="http://dl-4.alpinelinux.org/alpine/edge/community"

echo "$edge_community_repo" >> /etc/apk/repositories
apk update
apk add go git gcc make musl-dev bash unzip zip tar curl

echo '----- Install Consul -----'
export GOPATH=/tmp/go
go get github.com/hashicorp/consul
cd /tmp/go/src/github.com/hashicorp/consul
git checkout v$CONSUL_VERSION
make
mv bin/consul /usr/bin

echo '----- Install Consul UI -----'
cd /tmp
curl -o ui.zip -L https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip
unzip ui.zip  &&\
mv static /consul-ui

echo '----- Install dumb-init -----'
cd /tmp
curl -o dumb-init.zip -L https://github.com/Yelp/dumb-init/archive/v1.0.1.zip
unzip dumb-init.zip
cd dumb-init-1.0.1
make
mv dumb-init /sbin/

echo '---- installing runit ----'
tar -C /tmp -xvf /install/runit-2.1.2.tar.gz
cd /tmp/admin/runit-2.1.2/src
make
cp chpst runit runit-init runsv runsvchdir runsvdir sv svlogd utmpset /sbin

echo '----- cleaning up apk packages -----'
apk del go git gcc make musl-dev bash unzip zip tar curl
echo "$(grep -v "$edge_community_repo" /etc/apk/repositories)" > /etc/apk/repositories

# Install node.js syslog-ng zeromq initsh bashalias
apk add syslog-ng
cp -R /install/syslog-ng/* /
cp -R /install/initsh/* /
cp -R /install/bashalias/* /

# Clean up
rm -rf /install
rm -rf /tmp/*
rm -rf /var/cache/apk/*
