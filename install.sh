#!/bin/sh
set -e

apk update
apk upgrade

edge_community_repo="http://dl-4.alpinelinux.org/alpine/edge/community"

echo "$edge_community_repo" >> /etc/apk/repositories
apk update
apk add go git gcc make musl-dev bash unzip zip tar curl

echo '----- Installing Consul -----'
export GOPATH=/tmp/go
go get github.com/hashicorp/consul
cd /tmp/go/src/github.com/hashicorp/consul
git checkout v$CONSUL_VERSION
make
mv bin/consul /usr/bin

echo '----- Installing Consul UI -----'
cd /tmp
curl -o ui.zip -L https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip
unzip ui.zip  &&\
mv static /consul-ui

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
apk del go git gcc make musl-dev bash unzip zip tar curl
echo "$(grep -v "$edge_community_repo" /etc/apk/repositories)" > /etc/apk/repositories

# Install node.js syslog-ng zeromq initsh bashalias
apk add syslog-ng
cp -R /install/syslog-ng/* /
cp -R /install/bashalias/* /

# Clean up
rm -rf /install
rm -rf /tmp/*
rm -rf /var/cache/apk/*
