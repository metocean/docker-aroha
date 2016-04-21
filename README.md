# Aroha

Runit, Syslog-ng and Consul with an init script.

This docker is a base docker for some of the MetOcean web-stack.

## dumb-init

The docker is started using dumb-init as the master process (PID 1), it does the following:

## runit

runit is used for starting / stopping and logging of services.

To make runit start a service you either link or copy a sh script called "run" into:
/etc/services/[service name]/run

Nginx exmaple would be:
/etc/services/nginx/run
``` bash
#!/bin/sh -e
exec nginx -g "daemon off;" 2>&1
```
Note:
* nginx is not started as a daemon process, you should try to do this for any processes because we want runsvdir to get stdout.
* stderr is piped to stdout. '2>&1'

http://smarden.org/runit/

## logging

Processes / services started in this docker are expected to output logs to stdout. Initsh (PID 1) then pipes this back to the host running the docker.
Syslog-ng is used for piping dmesg to the initsh (PID 1).
