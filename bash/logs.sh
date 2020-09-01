#!/bin/bash -x

mkdir -p /tmp/syslog
rm -f /tmp/syslog/syslog.log
for AL in 7 6 5 4 3 2 ; do
    echo "The value of 'AL' variable is '${AL}'"
    gunzip -c /var/log/syslog.${AL}.gz >> /tmp/syslog/syslog.log
done

#/var/log/syslog.3.gz
