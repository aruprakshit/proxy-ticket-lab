FROM ubuntu:24.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends squid \
  && rm -rf /var/lib/apt/lists/*

# Squid runs as the package's proxy user and writes its logs here.
RUN mkdir -p /var/log/squid \
  && chown proxy:proxy /var/log/squid

COPY squid.conf /etc/squid/squid.conf

USER proxy

# Stay in the foreground; startup diagnostics also go to stderr.
CMD ["squid", "-N", "-d", "1", "-f", "/etc/squid/squid.conf"]