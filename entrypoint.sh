#!/bin/bash
set -e

MY_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
PATH=/usr/local/bin:$PATH
sed -i -e "s/interface=MY_IP/interface=$MY_IP/g" /etc/rtpengine.conf

if [ "$1" = 'rtpengine' ]; then
  shift
  exec rtpengine --config-file /etc/rtpengine.conf "$@"
fi

exec "$@"