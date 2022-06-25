FROM ubuntu:22.04 as builder


ENV BRANCH master

RUN apt update
RUN apt install -y git make g++ pkg-config zlib1g-dev ca-certificates \
    --no-install-recommends && \
    apt clean

RUN git clone https://github.com/yarrick/iodine --depth=1 --branch $BRANCH

RUN cd iodine && make && ls -l bin
RUN iodine/bin/iodine -v && \
    iodine/bin/iodined -v

# ===================================

FROM ubuntu:22.04 as runtime

ENV SERVER true

ENV HTTP_PROXY_PORT 8888
ENV DNS_PORT 5353
ENV PASSPHRASE "secretpassword"
ENV DOMAIN "ns1.example.com"
ENV NETWORK "192.168.99.1/24"

COPY --from=builder /iodine/bin/ /

EXPOSE $HTTP_PROXY
EXPOSE $DNS_PORT

RUN apt update && \
    apt install -y curl gettext net-tools bridge-utils tinyproxy --no-install-recommends && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY tinyproxy.conf.template /root/tinyproxy.conf.template
RUN service tinyproxy stop

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod 755 /root/entrypoint.sh

ENTRYPOINT /root/entrypoint.sh

