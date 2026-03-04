FROM gravitl/go-builder:1.25.3 AS builder
WORKDIR /app

COPY . . 

RUN go mod tidy
RUN GOOS=linux CGO_ENABLED=1 /usr/local/go/bin/go build -ldflags="-s -w" -o netclient-app .

FROM ubuntu:22.04

WORKDIR /root/

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        libmnl0 \
        openresolv \
        iproute2 \
        wireguard-tools \
        systemd \
        iptables \
        nftables \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/netclient-app ./netclient
COPY --from=builder /app/scripts/netclient.sh .
RUN chmod 0755 netclient && chmod 0755 netclient.sh

ENV WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go

ENTRYPOINT ["/bin/bash", "./netclient.sh"]
