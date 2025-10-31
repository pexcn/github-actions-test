#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:slim-trixie AS builder-ss

RUN apt-get update \
  && apt-get install --no-install-recommends -y git clang \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG SS_VERSION=v1.23.5
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  && cargo build --features "full-extra" \
  && install target/release/ssservice target/release/ssserver target/release/sslocal target/release/ssmanager target/release/ssurl /usr/local/bin/ \
  && cd - \
  && rm -r shadowsocks-rust
