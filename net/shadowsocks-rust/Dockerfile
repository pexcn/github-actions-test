FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache ca-certificates tzdata curl \
  && rm -rf /var/cache/apk/*

RUN echo "--> $IPINFO_TOKEN"
