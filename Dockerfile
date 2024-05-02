FROM debian:bookworm-slim as build

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  gcc g++ make cmake git \
  libavcodec-extra libavfilter-dev libcurl4-openssl-dev \
  libevent-dev libhiredis-dev libiptc-dev libjson-glib-dev \
  libopus-dev libpcap-dev libpcre3-dev libspandsp-dev \
  libssl-dev libwebsockets-dev libxmlrpc-core-c3-dev \
  markdown pandoc default-libmysqlclient-dev gperf

WORKDIR /usr/local/src

RUN git clone https://github.com/BelledonneCommunications/bcg729.git \
  && cd bcg729 \
  && cmake . -DCMAKE_INSTALL_PREFIX=/usr && make -j$(nproc) && make install

RUN git clone https://github.com/warmcat/libwebsockets.git -b v4.3.2 \
  && cd /usr/local/src/libwebsockets \
  && mkdir -p build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo && make -j ${BUILD_CPUS} && make install

RUN git clone https://github.com/sipwise/rtpengine.git -b mr11.5.1.24 \
  && cd rtpengine/daemon \
  && make -j$(nproc) with_transcoding=yes \
  && cp rtpengine /usr/local/bin/rtpengine

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl iproute2 \
  libavcodec59 libavformat59 libevent-2.1-7 libevent-pthreads-2.1-7 \
  libglib2.0-0 libhiredis0.14 libip4tc2 libip6tc2 \
  libjson-glib-1.0-0 libmariadb3 libpcap0.8 libpcre3 libspandsp2 \
  libwebsockets17 libxmlrpc-core-c3 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb

COPY --from=build /usr/local/bin/rtpengine /usr/local/bin/rtpengine

COPY ./entrypoint.sh /entrypoint.sh

VOLUME ["/tmp"]

EXPOSE 40000-60000/udp 22222/udp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rtpengine"]
