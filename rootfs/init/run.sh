#!/bin/sh

set -x

GRAPHITE_HOST=${GRAPHITE_HOST:-graphite}
GRAPHITE_PORT=${GRAPHITE_PORT:-2003}
GRAPHITE_SPOOLING=${GRAPHITE_SPOOLING:-"false"}
GRAPHITE_PICKLE=${GRAPHITE_PICKLE:-"false"}
METRIC_PREPEND=${METRIC_PREPEND:-""}
HOSTNAME=${HOSTNAME:-$(hostname -s)}

if [[ "${GRAPHITE_SPOOLING}" != "false" ]] || [[ "${GRAPHITE_SPOOLING}" != "true" ]]
then
  GRAPHITE_SPOOLING="false"
fi

if [[ "${GRAPHITE_PICKLE}" != "false" ]] || [[ "${GRAPHITE_PICKLE}" != "true" ]]
then
  GRAPHITE_PICKLE="false"
fi

if [[ ! -f /etc/carbon-relay-ng/storage-schemas.conf ]] && [[ -f /etc/carbon-relay-ng/storage-schemas.conf-DIST ]]
then
  cp -a /etc/carbon-relay-ng/storage-schemas.conf-DIST /etc/carbon-relay-ng/storage-schemas.conf
fi

if [[ "${GRAPHITE_SPOOLING}" = "true" ]]
then
  mkdir /var/spool/${HOSTNAME}
  chown -R nobody:nobody /var/spool/${HOSTNAME}
fi

config_file="/etc/carbon-relay-ng.ini"

sed -i \
  -e "s/%HOSTNAME%/${HOSTNAME}/" \
  -e "s/%GRAPHITE_HOST%/${GRAPHITE_HOST}/" \
  -e "s/%GRAPHITE_PORT%/${GRAPHITE_PORT}/" \
  -e "s/%GRAPHITE_SPOOLING%/${GRAPHITE_SPOOLING}/" \
  -e "s/%GRAPHITE_PICKLE%/${GRAPHITE_PICKLE}/" \
  -e "s/%METRIC_PREPEND%/${METRIC_PREPEND}/" \
  ${config_file}

/usr/bin/carbon-relay-ng ${config_file}

# EOF
