FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
LABEL maintainer="edifus"

# environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# install flax-blockchain
RUN apt-get update \
    && apt-get install -y \
      curl \
      jq \
      bc \
      python3 \
      tar \
      lsb-release \
      ca-certificates \
      git \
      sudo \
      openssl \
      unzip \
      wget \
      python3-pip \
      build-essential \
      python3-dev \
      python3.8-venv \
      python3.8-distutils \
      && echo "**** cloning latest flax-blockchain ****" \
      && git clone https://github.com/Flax-Network/flax-blockchain.git \
         --branch main \
         --recurse-submodules="mozilla-ca" \
         /app/flax-blockchain \
    && cd /app/flax-blockchain \
    && /bin/sh ./install.sh \
    && mkdir /plots \
    && chown abc:abc -R /plots \
    && chown abc:abc -R /config \
    && chown abc:abc -R /app/flax-blockchain \
    && echo "**** cleanup ****" \
    && apt-get clean \
    && rm -rf \
  	  /tmp/* \
  	  /var/lib/apt/lists/* \
  	  /var/tmp/*

# copy local files
COPY root/ /

# node = 6888 | farmer = 6885
EXPOSE 6888 6885

# flax configuration
VOLUME /config
