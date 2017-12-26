FROM debian:jessie

RUN apt-get update \
  && apt-get -y --quiet --force-yes upgrade \
  && apt-get install -y --no-install-recommends ca-certificates gcc g++ make build-essential git iptables-dev libavfilter-dev \
  libevent-dev libpcap-dev libxmlrpc-core-c3-dev markdown \
  libjson-glib-dev libmysqlclient-dev libhiredis-dev libssl-dev \
  libcurl4-openssl-dev \
  && cd /usr/local/src \
  && git clone https://github.com/sipwise/rtpengine.git \
  && cd rtpengine/daemon \
  && make && make install \
  && ln -s /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine \
  && apt-get purge -y --quiet --force-yes --auto-remove \
  ca-certificates gcc g++ make build-essential git \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && rm -Rf /var/log/* \
  && rm -Rf /var/lib/apt/lists/* 

VOLUME ["/tmp"]

EXPOSE 30000-50000/udp

COPY ./entrypoin.rtpengine.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rtpengine"]
