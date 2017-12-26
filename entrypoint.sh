#!/bin/bash
set -e

MY_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
PATH=/usr/local/bin:$PATH

if [ "$1" = 'rtpengine' ]; then
  shift
  exec rtpengine --interface "$MY_IP" \
  --foreground --log-stderr --listen-ng --listen-ng 22222 --listen-udp 12222  \
  --port-min 30000 --port-max 60000 --recording-dir /tmp \
  --recording-method pcap --recording-format eth --log-level 6 --delete-delay 0 \
  "$@"
fi

exec "$@"