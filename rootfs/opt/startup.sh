#!/bin/sh


GRAPHITE_HOST=${GRAPHITE_HOST:-graphite}
GRAPHITE_PORT=${GRAPHITE_PORT:-2003}

cfgFile="/etc/carbon-relay-ng.ini"

sed -i \
  -e "s/%GRAPHITE_HOST%/${GRAPHITE_HOST}/" \
  -e "s/%GRAPHITE_PORT%/${GRAPHITE_PORT}/" \
  ${cfgFile}

/usr/bin/carbon-relay-ng ${cfgFile}

# EOF
