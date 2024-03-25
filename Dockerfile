FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get remove --auto-remove nftables \
  && apt-get purge nftables \
  && apt-get -y --quiet --force-yes upgrade curl iproute2 \
  && apt-get install -y --no-install-recommends ca-certificates gcc g++ make cmake  build-essential git libavfilter-dev \
  libevent-dev libpcap-dev libxmlrpc-core-c3-dev markdown  \
  libjson-glib-dev default-libmysqlclient-dev libhiredis-dev libssl-dev \
  libcurl4-openssl-dev libavcodec-extra gperf libspandsp-dev \
  libxtables-dev libip6tc-dev libip4tc-dev  libiptc-dev \
  libjpeg-dev libsqlite3-dev libpcre3-dev libldns-dev libmnl-dev libnftnl-dev pandoc \
  libspeex-dev libspeexdsp-dev libedit-dev libtiff-dev yasm libswscale-dev haveged \
  libopus-dev libopusfile-dev libsndfile-dev libshout3-dev libmpg123-dev libmp3lame-dev \
  && cd /usr/local/src \
  && git clone https://github.com/BelledonneCommunications/bcg729.git \
  && cd bcg729 \
  && echo "building bcg729" \
  && cmake . -DCMAKE_INSTALL_PREFIX=/usr && make && make install \
  && cd /usr/local/src \
  && git clone https://github.com/warmcat/libwebsockets.git -b v4.3.2 \
  && cd /usr/local/src/libwebsockets \
  && mkdir -p build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install \
  && git clone https://github.com/sipwise/rtpengine.git -b mr11.5.1.24 \
  && cd rtpengine/daemon \
  && make with_transcoding=yes \
  && find . -name rtpengine \
  && cp rtpengine /usr/local/bin/rtpengine \
  && rm -Rf /usr/local/src/rtpengine \
  && apt-get purge -y --quiet --force-yes --auto-remove \
  ca-certificates gcc g++ make build-essential git markdown \
  && rm -rf /var/lib/apt/* \
  && rm -rf /var/lib/dpkg/* \
  && rm -rf /var/lib/cache/* \
  && rm -Rf /var/log/* \
  && rm -Rf /usr/local/src/* \
  && rm -Rf /var/lib/apt/lists/* 

VOLUME ["/tmp"]

EXPOSE 40000-60000/udp 22222/udp

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rtpengine"]
