FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache ca-certificates tzdata curl \
  && rm -rf /var/cache/apk/*

RUN echo "--> $BUILD_TAG" && curl -L https://ipinfo.io/data/free/country.mmdb?token=${IPINFO_TOKEN} geoip.db \
  && ls -alh geoip.db

RUN echo $BUILD_TAG
