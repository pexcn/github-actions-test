#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_VERSION=v1.15.0-alpha.9
RUN export RUSTFLAGS="-C target-cpu=native" \
  && git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  && case "$(apk --print-arch)" in \
       aarch64) build_features="local-redir local-tun aead-cipher-2022-extra armv8 neon";; \
       *) build_features="local-redir local-tun aead-cipher-2022-extra";; \
     esac \
  && cargo build --release --features "$build_features" \
  && install target/release/ssservice target/release/ssserver target/release/sslocal target/release/ssmanager target/release/ssurl /usr/local/bin/ \
  && cd - \
  && rm -r /shadowsocks-rust

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine

RUN apk update \
  && apk add --no-cache tzdata curl \
  && rm -rf /var/cache/apk/*

COPY --from=builder-ss /usr/local/bin/ /usr/local/bin/

RUN curl --upload-file /usr/local/bin/ssservice https://free.keep.sh
