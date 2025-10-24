#!/bin/sh
set -e

# Try a DNS query
if dig @127.0.0.1 -p 5335 google.com +time=1 +tries=1 >/dev/null 2>&1; then
    echo "DNS resolution working"
    exit 0
else
    echo "DNS resolution failed"
    exit 1
fi
