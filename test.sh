#!/bin/bash

DNS_PORT=5335
DOMAIN="google.com"

# Perform a DNS query
RESPONSE=$(dig @127.0.0.1 -p $DNS_PORT $DOMAIN +short)

if [ -z "$RESPONSE" ]; then
  echo "DNS query failed."
else
  echo "DNS query succeeded: $RESPONSE"
fi
