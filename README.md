# Unbound Docker

[Unbound](https://github.com/NLnetLabs/unbound) is a validating, recursive, caching DNS resolver.

This repo is for a dockerised version of unbound with provides recursive resolution of domains. Unlike other alternatives this repo is actively maintained and builds unbound from source to be up to date with the latest security patches, it is also small at 35MB.

## Running with Docker

```bash
docker run -d -p 5335:5335/tcp -p 5335:5335/udp --name unbound owenelliottdev/unbound:latest
```

## Running in a Docker Compose

```yml
services:
  unbound:
    container_name: unbound
    image: owenelliottdev/unbound:latest
    ports:
      - "5335:5335/tcp"
      - "5335:5335/udp"
    restart: unless-stopped
```

## Security Recommendations

Don't expose 5335 to the public internet, if you expose 5335 to the internet then you are vulerable to cache snooping and DNS amplification attacks.

If you want to harden the docker configuration you can run it on an internal docker network to only expose it to services which need it as oppose to sharing it with the entire LAN.

Using a bridge network allows you to limit access to specific containers on that network:
```yml
services:
  unbound:
    container_name: unbound
    image: owenelliottdev/unbound:latest
    restart: unless-stopped
    networks:
    - unbound_dns

networks:
  unbound_dns:
    driver: bridge
```

## Advanced Configuration

There are a number of environment variables which can be customised in your docker run command or docker compose.

### Threading and Performance

+ `UNBOUND_NUM_THREADS=8`
Specifies the number of threads Unbound will use to handle queries.
Recommendation: Set based on the number of CPU cores and expected query load. More threads can increase throughput but may increase memory usage.

+ `UNBOUND_MSG_CACHE_SIZE=125m`
Sets the size of the message cache, which stores raw query responses to improve performance for repeated queries.
Recommendation: Larger cache sizes can reduce query latency but use more memory.

+ `UNBOUND_RRSET_CACHE_SIZE=250m`
Determines the size of the RRset (resource record set) cache. This cache holds DNS records for faster future resolution.
Recommendation: Increase cache size for high-traffic environments.

+ `UNBOUND_OUTGOING_RANGE=8192`
Defines the number of outgoing sockets available for concurrent upstream queries.
Recommendation: Higher values improve parallel resolution but consume more file descriptors.

### DNS Features

+ `UNBOUND_PREFETCH=yes`
Enables prefetching of popular or expiring cache entries to reduce latency for frequently accessed domains.
Recommendation: Useful in high-traffic environments to improve response times.

+ `UNBOUND_DO_IP6=yes`
Enables IPv6 resolution in addition to IPv4.
Recommendation: Keep enabled if your network supports IPv6.

+ `UNBOUND_PREFETCH_KEY=yes`
Prefetches DNSSEC keys before they expire to reduce validation delays.
Recommendation: Useful when DNSSEC is in use.

+ `UNBOUND_EDNS_BUFFER_SIZE=1232`
Sets the EDNS buffer size for UDP DNS messages. This defines the maximum packet size Unbound can send or receive over UDP.
Recommendation: Adjust for networks with MTU constraints; default is usually 1232–4096 bytes.

+ `UNBOUND_SO_REUSEPORT=yes`
Enables SO_REUSEPORT socket option to allow multiple threads to bind to the same port efficiently.
Recommendation: Improves multi-threaded performance on high-load systems.

### Caching and TTL (Time-to-Live)

+ `UNBOUND_CACHE_MAX_TTL=86400`
Maximum TTL (in seconds) for cached records. Records are discarded after this period.
Recommendation: Set according to caching policies; 86400 seconds = 1 day.

+ `UNBOUND_CACHE_MIN_TTL=300`
Minimum TTL (in seconds) for cached records. Records with shorter TTLs are retained for at least this period.
Recommendation: Ensures frequently queried domains remain in cache for a minimum duration.

### Access Control (LAN / Localhost)
+`UNBOUND_ALLOW_LAN=no`
Optionally enable access control for your LAN.
  + `yes`: allows LAN access according to UNBOUND_LAN_SUBNET
  + `no`: only localhost has access (default)

+ `UNBOUND_LAN_SUBNET`
Defines the subnet to allow LAN access, e.g., `192.168.1.0/24`.
Only applied if `UNBOUND_ALLOW_LAN=yes`. Default Localhost Access:
    ```
    access-control: 127.0.0.1/32 allow
    access-control: ::1/128 allow
    ```


## Building the container for development

```bash
docker build -t unbound .
docker run -d -p 5335:5335/tcp -p 5335:5335/udp --name unbound unbound
```