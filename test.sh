#!/bin/sh

apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

git clone https://github.com/shadowsocks/shadowsocks-rust.git
cd shadowsocks-rust
RUSTFLAGS="-C link-arg=-s" cargo build --release --features "local-redir"
