FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  default-libmysqlclient-dev \
  g++ \
  gcc \
  git \
  gperf \
  libavcodec-extra \
  libavfilter-dev \
  libcurl4-openssl-dev \
  libevent-dev \
  libhiredis-dev \
  libiptc-dev \
  libjson-glib-dev \
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

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  iproute2 \
  libavcodec59 \
  libavformat59 \
  libevent-2.1-7 \
  libevent-pthreads-2.1-7 \
  libglib2.0-0 \
  libhiredis0.14 \
  libip4tc2 \
  libip6tc2 \
  libjson-glib-1.0-0 \
  libmariadb3 \
  libpcap0.8 \
  libpcre3 \
  libspandsp2 \
  libwebsockets17 \
  libxmlrpc-core-c3 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb

COPY --from=build /usr/src/rtpengine/daemon/rtpengine /usr/local/bin/rtpengine
COPY ./entrypoint.sh /entrypoint.sh
COPY ./rtpengine.conf /etc
