FROM alpine:3.19 AS builder

RUN apk add --no-cache \
  ca-certificates \
  cmake \
  curl-dev \
  ffmpeg-dev \
  g++ \
  gcc \
  git \
  gperf \
  glib-dev \
  hiredis-dev \
  iptables-dev \
  json-glib-dev \
  libevent-dev \
	libmnl-dev \
  libnftnl-dev \
  libpcap-dev \
  libwebsockets-dev \
  make \
  mariadb-connector-c-dev \
  markdown \
  openssl-dev \
  opus-dev \
  pandoc \
  pcre-dev \
  spandsp-dev \
  xmlrpc-c-dev


FROM builder AS bcg729

WORKDIR /usr/src
RUN git clone https://github.com/BelledonneCommunications/bcg729.git && \
    cd /usr/src/bcg729 && \
    cmake . -DCMAKE_INSTALL_PREFIX=/usr && make -j$(nproc) && make install


FROM builder AS rtpengine

COPY --from=bcg729 /usr/include/bcg729 /usr/include/bcg729
COPY --from=bcg729 /usr/lib/libbcg729.a /usr/lib/libbcg729.a
COPY --from=bcg729 /usr/lib/pkgconfig/libbcg729.pc /usr/lib/pkgconfig/libbcg729.pc
WORKDIR /usr/src
RUN git clone https://github.com/sipwise/rtpengine -b mr11.5.1.24 && \
    sed -i 's:/bin/bash:/bin/sh:' rtpengine/utils/build_test_wrapper && \
    cd /usr/src/rtpengine/daemon && \
    make -j$(nproc) with_transcoding=yes && make install


FROM alpine:3.19

RUN apk add --no-cache \
  ca-certificates \
  curl \
  ffmpeg-libavcodec \
  ffmpeg-libavfilter \
  ffmpeg-libavformat \
  ffmpeg-libswresample \
  glib \
  hiredis \
  iptables \
  json-glib \
  libip4tc \
  libip6tc \
  libevent \
  libmnl \
  libnftnl \
  libpcap \
  libwebsockets \
  mariadb-connector-c \
  openssl \
  opus \
  pcre \
  spandsp \
  xmlrpc-c-client

COPY --from=rtpengine /usr/bin/rtpengine /usr/bin/rtpengine
COPY --from=bcg729 /usr/lib/libbcg729.a /usr/lib/libbcg729.a

VOLUME ["/tmp"]

EXPOSE 40000-60000/udp 22222/udp

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["rtpengine"]
