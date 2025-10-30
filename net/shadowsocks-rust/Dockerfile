#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_VERSION=v1.23.5
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  && cargo build --release --features "full dns-over-h3 aead-cipher-extra aead-cipher-2022-extra" \
  && install target/release/ssservice target/release/ssserver target/release/sslocal target/release/ssmanager target/release/ssurl /usr/local/bin/ \
  && cd - \
  && rm -r /shadowsocks-rust

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*
