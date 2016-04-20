FROM gliderlabs/alpine:3.3
MAINTAINER Thomas Coats <thomas@metocean.co.nz>

ENV CONSUL_VERSION=0.6.4 GOMAXPROCS=2

ADD . /install/
RUN /install/install.sh

CMD ["/sbin/dumb-init", "/sbin/runsvdir", "-P", "/etc/service"]
