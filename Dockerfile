FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  default-libmysqlclient-dev \
  g++ \
  gcc \
  git \
  gperf \
  iproute2 \
  iptables \
  libavcodec-extra \
  libavfilter-dev \
  libcurl4-openssl-dev \
  libevent-dev \
  libhiredis-dev \
  libiptc-dev \
  libjson-glib-dev \
  libmnl-dev \
  libnftnl-dev \
  libopus-dev \
  libpcap-dev \
  libpcre3-dev \
  libspandsp-dev \
  libssl-dev \
  libwebsockets-dev \
  libxmlrpc-core-c3-dev \
  make \
  markdown \
  pandoc

WORKDIR /usr/src
RUN git clone https://github.com/sipwise/rtpengine
WORKDIR /usr/src/rtpengine/daemon
RUN make -j$(nproc) install

FROM debian:bookworm-slim

VOLUME ["/tmp"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["rtpengine"]

EXPOSE 23000-32768/udp 22222/udp

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && apt-get install -y --no-install-recommends \
  curl \
  iproute2 \
  iptables \
  libglib2.0-0 \
  libavcodec-extra \
  libavfilter8 \
  libcurl4 \
  libevent-2.1-7 \
  libevent-pthreads-2.1-7 \
  libhiredis0.14 \
  libip6tc2 \
  libiptc0 \
  libjson-glib-1.0-0 \
  libmariadb3 \
  libmnl0 \
  libnftnl11 \
  libopus0 \
  libpcap0.8 \
  libpcre3 \
  libspandsp2 \
  libssl3 \
  libwebsockets17 \
  libxmlrpc-core-c3 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/src/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine
COPY ./entrypoint.sh /entrypoint.sh
COPY ./rtpengine.conf /etc
