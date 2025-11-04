#
# Dockerfile for shadowsocks-rust
#

#
# Runtime stage
#
FROM alpine:3.22
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY shadowsocks-rust.sh /usr/local/bin/

ENV CHILLING_EFFECT=0

ENTRYPOINT ["shadowsocks-rust.sh"]
CMD ["ssserver", "--version"]
