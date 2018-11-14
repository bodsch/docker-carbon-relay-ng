
FROM golang:1-alpine as builder

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_TYPE
ARG VERSION

ENV \
  TERM=xterm \
  GOPATH=/opt/go \
  PATH="${PATH}:${GOPATH}/bin"

# ---------------------------------------------------------------------------------------

RUN \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add     --quiet \
    g++ git make musl-dev && \
  echo "export BUILD_DATE=${BUILD_DATE}"  > /etc/profile.d/carbon-relay-ng.sh && \
  echo "export BUILD_TYPE=${BUILD_TYPE}" >> /etc/profile.d/carbon-relay-ng.sh && \
  echo "export VERSION=${VERSION}"       >> /etc/profile.d/carbon-relay-ng.sh

WORKDIR ${GOPATH}

RUN \
  go get github.com/graphite-ng/carbon-relay-ng || true && \
  go get github.com/shuLhan/go-bindata/cmd/go-bindata

WORKDIR "${GOPATH}/src/github.com/graphite-ng/carbon-relay-ng"

RUN \
  if [ "${BUILD_TYPE}" == "stable" ] ; then \
    echo "switch to stable Tag v${VERSION}" && \
    git checkout tags/v${VERSION} 2> /dev/null ; \
  fi

RUN \
  export PATH="${PATH}:${GOPATH}/bin" && \
  version=$(git describe --tags --always | sed 's/^v//') && \
  echo "build version: ${version}" && \
  make && \
  mv carbon-relay-ng /tmp/carbon-relay-ng && \
  cp -rv examples /tmp/

# ---------------------------------------------------------------------------------------

FROM alpine:3.8

ENV \
  TERM=xterm \
  TZ='Europe/Berlin'

# ---------------------------------------------------------------------------------------

RUN \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add     --quiet --no-cache --virtual .build-deps \
    tzdata && \
  cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
  echo ${TZ} > /etc/timezone && \
  apk --quiet --purge del .build-deps && \
  mkdir -p /var/spool/carbon-relay-ng && \
  chown nobody: /var/spool/carbon-relay-ng && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

WORKDIR /etc/carbon-relay-ng/

COPY --from=builder /etc/profile.d/carbon-relay-ng.sh  /etc/profile.d/carbon-relay-ng.sh
COPY --from=builder /tmp/carbon-relay-ng               /usr/bin/carbon-relay-ng
COPY --from=builder /tmp/examples/storage-schemas.conf /etc/carbon-relay-ng/storage-schemas.conf-DIST
COPY --from=builder /tmp/examples/carbon-relay-ng.ini  /etc/carbon-relay-ng/carbon-relay-ng.ini-DIST
COPY rootfs/ /

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --retries=12 \
  --start-period=10s \
  CMD ps ax | grep -v grep | grep -c "/usr/bin/carbon-relay-ng" || exit 1

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------

EXPOSE 2003 2004 8081

LABEL \
  version=${BUILD_VERSION} \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="carbon-relay-ng Docker Image" \
  org.label-schema.description="Inofficial carbon-relay-ng Docker Image" \
  org.label-schema.url="https://github.com/graphite-ng/carbon-relay-ng" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-docker-carbon-relay-ng" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="The Unlicense"

# EOF

