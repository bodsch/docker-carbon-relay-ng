
FROM bodsch/docker-alpine-base:1610-01

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.1.0"

EXPOSE 2003
EXPOSE 2004
EXPOSE 8081

ENV GOPATH=/opt/go
ENV GO15VENDOREXPERIMENT=0

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
  go get -d github.com/graphite-ng/carbon-relay-ng && \
  go get github.com/jteeuwen/go-bindata/... && \
  cd ${GOPATH}/src/github.com/graphite-ng/carbon-relay-ng && \
  make && \
  mv carbon-relay-ng /usr/bin && \
  mkdir -p /var/spool/carbon-relay-ng && \
  chown nobody: /var/spool/carbon-relay-ng && \
  apk del --purge \
    build-base \
    go \
    git \
    mercurial && \
  rm -rf \
    ${GOPATH} \
    /tmp/* \
    /var/cache/apk/* \
    /root/.n* \
    /usr/local/bin/phantomjs

COPY rootfs/ /

#WORKDIR /usr/share/grafana

CMD [ "/opt/startup.sh" ]

# CMD [ '/bin/sh' ]

# EOF
