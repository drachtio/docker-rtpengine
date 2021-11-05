#!/bin/bash
set -e

PATH=/usr/local/bin:$PATH

case $CLOUD in 
  gcp)
    LOCAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
    PUBLIC_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
    ;;
  aws)
    LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    ;;
  digitalocean)
    LOCAL_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
    PUBLIC_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
    ;;
  azure)
    LOCAL_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")
    PUBLIC_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text")
    ;;
  *)
    ;;
esac

if [ -z "$PUBLIC_IP" ]; then
  LOCAL_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
  PUBLIC_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
fi

if [ -z "$RTP_START_PORT" ]; then
  RTP_START_PORT=40000
fi
if [ -z "$RTP_END_PORT" ]; then
  RTP_END_PORT=60000
fi
if [ -z "$LOGLEVEL" ]; then
  LOGLEVEL=7
fi

echo "LOGLEVEL is $LOGLEVEL"

if [ "$1" = 'rtpengine' ]; then
  shift
  echo "starting rtpengine"
  echo "rtpengine --interface private/${LOCAL_IP} --interface public/${LOCAL_IP}'!'${PUBLIC_IP} --listen-ng=22222 --listen-http=8080 --listen-udp=12222 --dtmf-log-dest=127.0.0.1:22223 --listen-cli=127.0.0.1:9900 --pidfile /var/run/rtpengine.pid --port-min ${RTP_START_PORT} --port-max ${RTP_END_PORT} --recording-dir /tmp --recording-method pcap --recording-format eth --log-level ${LOGLEVEL} --delete-delay 0 $@"
  exec rtpengine --interface private/${LOCAL_IP} --interface "public/${LOCAL_IP}'!'${PUBLIC_IP}" --listen-ng=22222 --listen-http=8080 --listen-udp=12222 --dtmf-log-dest=127.0.0.1:22223 --listen-cli=127.0.0.1:9900 --pidfile /var/run/rtpengine.pid --port-min ${RTP_START_PORT} --port-max ${RTP_END_PORT} --recording-dir /tmp --recording-method pcap --recording-format eth --log-level ${LOGLEVEL} --delete-delay 0
else 
  exec "$@"
fi
