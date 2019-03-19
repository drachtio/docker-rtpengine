FROM debian:stretch

RUN apt-get update \
  && apt-get -y --quiet --force-yes upgrade \
  && apt-get install -y --no-install-recommends ca-certificates gcc g++ make build-essential git iptables-dev libavfilter-dev \
  libevent-dev libpcap-dev libxmlrpc-core-c3-dev markdown \
  libjson-glib-dev default-libmysqlclient-dev libhiredis-dev libssl-dev \
  libcurl4-openssl-dev libavcodec-extra gperf \
  && cd /usr/local/src \
  && git clone -b mr7.1 https://github.com/sipwise/rtpengine.git \
  && cd rtpengine/daemon \
  && make && make install \
  && cp /usr/local/src/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine \
  && rm -Rf /usr/local/src/rtpengine \
  && apt-get purge -y --quiet --force-yes --auto-remove \
  ca-certificates gcc g++ make build-essential git markdown \
  && rm -rf /var/lib/apt/* \
  && rm -rf /var/lib/dpkg/* \
  && rm -rf /var/lib/cache/* \
  && rm -Rf /var/log/* \
  && rm -Rf /var/lib/apt/lists/* 

VOLUME ["/tmp"]

EXPOSE 16384-32768/udp

COPY ./entrypoint.sh /entrypoint.sh

COPY ./rtpengine.conf /etc

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rtpengine"]
