#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:slim-trixie AS builder-ss

RUN apt-get update \
  && apt-get install --no-install-recommends -y curl git clang xz-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG TOOLCHAIN_VERSION=20250929
ARG SS_VERSION=v1.23.5
RUN case "$(dpkg --print-architecture)" in \
      amd64) RUST_TARGET='x86_64-unknown-linux-musl';; \
      arm64) RUST_TARGET='aarch64-unknown-linux-musl';; \
    esac \
  && curl -L https://github.com/cross-tools/musl-cross/releases/download/${TOOLCHAIN_VERSION}/${RUST_TARGET}.tar.xz | \
      tar -xJf - -C /opt/ \
  && PATH="/opt/${RUST_TARGET}/bin:$PATH" \
  && export CC_"${RUST_TARGET//-/_}"=${RUST_TARGET}-gcc \
  && export CXX_"${RUST_TARGET//-/_}"=${RUST_TARGET}-g++ \
  && export AR_"${RUST_TARGET//-/_}"=${RUST_TARGET}-ar \
  && export RANLIB_"${RUST_TARGET//-/_}"=${RUST_TARGET}-ranlib \
  && export STRIP_"${RUST_TARGET//-/_}"=${RUST_TARGET}-strip \
  && export CARGO_TARGET_"$(echo $RUST_TARGET | tr '[:lower:]-' '[:upper:]_')"_LINKER=${RUST_TARGET}-gcc \
  && rustup target add $RUST_TARGET \
  && git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  # fix rustfmt missing when compile librocksdb
  && rustup component add rustfmt \
  # fix librocksdb compile, ref: https://github.com/facebook/rocksdb/issues/13365#issuecomment-2833978676
  && export CXXFLAGS="$CXXFLAGS -include cstdint" \
  && cargo build --release --target $RUST_TARGET --features "full dns-over-h3 local-fake-dns aead-cipher-extra aead-cipher-2022-extra" \
  && install target/${RUST_TARGET}/release/{ssservice,ssserver,sslocal,ssmanager,ssurl} /usr/local/bin/ \
  && cd - \
  && rm -r shadowsocks-rust

#
# Runtime stage
#
FROM alpine:3.22
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder-ss /usr/local/bin/ /usr/local/bin/

RUN cd /usr/local/bin/ \
  && ln -s ssservice service \
  && ln -s ssserver server \
  && ln -s sslocal local \
  && ln -s ssmanager manager \
  && ln -s ssurl url

ENV CHILLING_EFFECT=0

ENTRYPOINT ["shadowsocks-rust.sh"]
CMD ["ssserver", "--version"]
