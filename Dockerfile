FROM alpine:3.11.6 AS base

RUN apk add --update-cache \
    unzip

# add the bootstrap file
COPY bootstrap.sh /tshock/bootstrap.sh

FROM mono:6.8.0.96-slim

# install nuget to grab tshock dependencies
RUN apt-get update -y && \
    apt-get install -y nuget unzip curl && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ARG TSHOCKVERSION=v4.4.0-pre12
ARG TSHOCKZIP=TShock4.4.0_Pre12_Terraria1.4.0.5.zip

RUN addgroup --gid 1000 tshock && useradd -b / -m --uid 1000 --gid 1000 tshock && passwd -d tshock

# copy game files
COPY --from=base /tshock/ /tshock/

# Download and unpack TShock
ADD https://github.com/Pryaxis/TShock/releases/download/$TSHOCKVERSION/$TSHOCKZIP /tmp/
RUN unzip /tmp/$TSHOCKZIP -d /tshock && \
    rm /tmp/$TSHOCKZIP && \
    chmod +x /tshock/TerrariaServer.exe && \
    # add executable perm to bootstrap
    chmod +x /tshock/bootstrap.sh

LABEL maintainer="Ryan Sheehan <rsheehan@gmail.com>"

# documenting ports
EXPOSE 7777 7878

# env used in the bootstrap
ARG WORLD_FILENAME=default.wld

# Allow for external data
VOLUME ["/worlds", "/logs", "/plugins"]

RUN chown -R tshock:tshock /tshock

RUN USER=tshock && \
    GROUP=tshock && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml 

## Set working directory to server
WORKDIR /tshock
USER tshock
# run the bootstrap, which will copy the TShockAPI.dll before starting the server
ENTRYPOINT [ "/bin/sh", "bootstrap.sh" ]
