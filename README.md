# Aroha

Runit, Syslog-ng and Consul with an init script.

This docker is a base docker for some of the MetOcean web-stack.

## dumb-init-hacked

This docker is started using dumb-init-hacked as the master process (PID 1). It then executes runit's runsvdir program.

dumd-init-hacked is based on https://github.com/Yelp/dumb-init, 'hacked' has an added startup script feature.

### dumd-init-hacked does in order:

1) Scans and run any ".sh" or ".py" script found in either "/etc/dumb-init-hacked/startup/" or environment variable "DUMB_INIT_STARTUP_DIR" if set. If any script exits with a none zero, dumb-init-hacked will exit with the same code. If no script or directory is found, nothing is done.

2) Executes the supplied program and parameters as a child process, any signals will be passed to this process. In this docker "/sbin/runsvdir", "-P", "/etc/service.

## runit-hacked

Runit hacked is used for starting / stopping and logging of services. It is haceked version of http://smarden.org/runit/.

The hack made runit's runsvdir program wait until it's services has exited, with a timeout.

### runit services

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
