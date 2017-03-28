
FROM golang:1.8-alpine

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1703-04"

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="v3.5" \
  TERM=xterm \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

EXPOSE 2003 2004 8081

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    build-base \
    git \
    mercurial && \
  mkdir -p ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  go get -d github.com/graphite-ng/carbon-relay-ng || true && \
  go get github.com/jteeuwen/go-bindata/... && \
  cd ${GOPATH}/src/github.com/graphite-ng/carbon-relay-ng && \
  make && \
  mv carbon-relay-ng /usr/bin && \
  mkdir -p /var/spool/carbon-relay-ng && \
  chown nobody: /var/spool/carbon-relay-ng && \
  apk --quiet --purge del \
    build-base \
    go \
    git \
    mercurial && \
  rm -rf \
    ${GOPATH} \
    /go \
    /tmp/* \
    /usr/local/go \
    /usr/local/bin/go-wrapper \
    /var/cache/apk/*

COPY rootfs/ /

CMD [ "/opt/startup.sh" ]

# EOF
