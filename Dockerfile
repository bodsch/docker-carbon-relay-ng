
FROM bodsch/docker-alpine-base:1701-02

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.2.0"

EXPOSE 2003
EXPOSE 2004
EXPOSE 8081

ENV \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    build-base \
    go \
    git \
    mercurial && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  go get -d github.com/graphite-ng/carbon-relay-ng || true && \
  go get github.com/jteeuwen/go-bindata/... && \
  cd ${GOPATH}/src/github.com/graphite-ng/carbon-relay-ng && \
  make && \
  mv carbon-relay-ng /usr/bin && \
  mkdir -p /var/spool/carbon-relay-ng && \
  chown nobody: /var/spool/carbon-relay-ng && \
  apk del --purge \
    bash \
    build-base \
    curl \
    nano \
    go \
    git \
    mercurial \
    tree && \
  rm -rf \
    ${GOPATH} \
    /tmp/* \
    /var/cache/apk/* \
    /root/.n* \
    /usr/local/bin/phantomjs

COPY rootfs/ /

CMD [ "/opt/startup.sh" ]

# EOF
