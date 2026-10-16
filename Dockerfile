FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends procps && \
    rm -rf /var/lib/apt/lists/*

COPY sysinfo.sh /usr/local/bin/sysinfo
RUN chmod +x /usr/local/bin/sysinfo

ENTRYPOINT ["sysinfo"]
