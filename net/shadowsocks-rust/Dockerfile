FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache ca-certificates tzdata curl \
  && rm -rf /var/cache/apk/*

RUN --mount=type=secret,id=IPINFO_TOKEN,env=IPINFO_TOKEN \
  echo "--> $IPINFO_TOKEN"
