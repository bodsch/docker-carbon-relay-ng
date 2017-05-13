
FROM bodsch/docker-golang:1.8

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1705-03"

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="edge" \
  TERM=xterm \
  BUILD_DATE="2017-05-13" \
  GOPATH=/opt/go \
  APK_ADD="build-base git mercurial"

EXPOSE 2003 2004 8081

LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="carbon-relay-ng Docker Image" \
      org.label-schema.description="Inofficial carbon-relay-ng Docker Image" \
      org.label-schema.url="https://github.com/graphite-ng/carbon-relay-ng" \
      org.label-schema.vcs-url="https://github.com/bodsch/docker-docker-carbon-relay-ng" \
      org.label-schema.vendor="Bodo Schulz" \
      org.label-schema.schema-version="1.0" \
      com.microscaling.docker.dockerfile="/Dockerfile" \
      com.microscaling.license="GNU General Public License v3.0"

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  for apk in ${APK_ADD} ; \
  do \
    apk --quiet --no-cache add --virtual build-deps ${apk} ; \
  done && \
  mkdir -p ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  go get -d github.com/graphite-ng/carbon-relay-ng || true && \
  go get github.com/jteeuwen/go-bindata/... && \
  cd ${GOPATH}/src/github.com/graphite-ng/carbon-relay-ng && \
  make && \
  mv carbon-relay-ng /usr/bin && \
  mkdir -p /var/spool/carbon-relay-ng && \
  chown nobody: /var/spool/carbon-relay-ng && \
  apk --purge del \
    build-deps && \
  rm -rf \
    ${GOPATH} \
    /usr/lib/go \
    /usr/bin/go \
    /usr/bin/gofmt \
    /tmp/* \
    /var/cache/apk/*

COPY rootfs/ /

CMD [ "/init/run.sh" ]

# EOF
