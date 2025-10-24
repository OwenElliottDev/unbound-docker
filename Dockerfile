# Stage 1: Build from source with libevent
FROM alpine:latest AS builder
RUN apk add --no-cache build-base git libevent-dev openssl-dev expat-dev flex bison


RUN git clone --branch release-1.24.1 https://github.com/NLnetLabs/unbound.git \
    && cd unbound \
    && ./configure --with-libevent \
    && make \
    && make install

# Stage 2: Minimal final container
FROM alpine:latest

# bind-tools used for HEALTHCHECK
RUN apk add --no-cache libevent openssl expat bind-tools 

COPY --from=builder /usr/local/sbin/unbound /usr/local/sbin/unbound
COPY --from=builder /usr/local/etc/unbound /usr/local/etc/unbound

ENV UNBOUND_NUM_THREADS=8 \
    UNBOUND_MSG_CACHE_SIZE=125m \
    UNBOUND_RRSET_CACHE_SIZE=250m \
    UNBOUND_PREFETCH=yes \
    UNBOUND_DO_IP6=yes \
    UNBOUND_EDNS_BUFFER_SIZE=1232 \
    UNBOUND_SO_REUSEPORT=yes \
    UNBOUND_CACHE_MAX_TTL=86400 \
    UNBOUND_CACHE_MIN_TTL=300 \
    UNBOUND_PREFETCH_KEY=yes \
    UNBOUND_OUTGOING_RANGE=8192 \
    UNBOUND_ALLOW_LAN=no 

# Expose the DNS port
EXPOSE 5335

RUN adduser -D -u 1000 unbound

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

HEALTHCHECK --interval=2s --timeout=20s --start-period=5s --retries=3 CMD [ "/healthcheck.sh" ]

ENTRYPOINT ["/entrypoint.sh"]
