#!/bin/sh
set -e
mkdir -p /etc/unbound/unbound.conf.d/

cat << EOF > /etc/unbound/unbound.conf
include: "/etc/unbound/unbound.conf.d/*.conf"
EOF

# Generate Unbound configuration
cat << EOF > /etc/unbound/unbound.conf.d/docker.conf
server:
    verbosity: 0
    log-queries: no
    interface: 0.0.0.0
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: ${UNBOUND_DO_IP6}
    prefer-ip6: no
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no
    edns-buffer-size: ${UNBOUND_EDNS_BUFFER_SIZE}
    prefetch: ${UNBOUND_PREFETCH}
    prefetch-key: ${UNBOUND_PREFETCH_KEY}
    num-threads: ${UNBOUND_NUM_THREADS}
    rrset-cache-size: ${UNBOUND_RRSET_CACHE_SIZE}
    msg-cache-size: ${UNBOUND_MSG_CACHE_SIZE}
    so-reuseport: ${UNBOUND_SO_REUSEPORT}
    cache-max-ttl: ${UNBOUND_CACHE_MAX_TTL}
    cache-min-ttl: ${UNBOUND_CACHE_MIN_TTL}
    outgoing-range: ${UNBOUND_OUTGOING_RANGE}
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10
    private-address: 192.0.2.0/24
    private-address: 198.51.100.0/24
    private-address: 203.0.113.0/24
    private-address: 255.255.255.255/32
    private-address: 2001:db8::/32
    qname-minimisation: yes
    access-control: 127.0.0.1/32 allow
    access-control: 192.168.0.0/16 allow
    access-control: 172.16.0.0/12 allow
    access-control: 10.0.0.0/8 allow
EOF

# Start Unbound in the foreground
exec /usr/local/sbin/unbound -d -c /etc/unbound/unbound.conf
