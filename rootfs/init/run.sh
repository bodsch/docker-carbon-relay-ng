#!/bin/bash

# set -e

. /etc/profile
. /init/output.sh

GRAPHITE_HOST=${GRAPHITE_HOST:-graphite}
GRAPHITE_PORT=${GRAPHITE_PORT:-2003}
GRAPHITE_SPOOLING=${GRAPHITE_SPOOLING:-"false"}
GRAPHITE_PICKLE=${GRAPHITE_PICKLE:-"false"}
METRIC_PREPEND=${METRIC_PREPEND:-""}
HOSTNAME=${HOSTNAME:-$(hostname -s)}

# error warning notice info debug
LOG_LEVEL=${LOG_LEVEL:-error}
valid_log_level="error warning notice info debug"

# ---------------------------------------------------------------------------------------

[ -f "${HOME}/carbon-relay-ng.ini" ] || cp /etc/carbon-relay-ng.ini "${HOME}/carbon-relay-ng.ini"

config_file="${HOME}/carbon-relay-ng.ini"


valid() {
  echo "${2}" | grep -c "${1}"
}


stdbool() {

  if [ -z "${1}" ]
  then
    echo "n"
  else
    # SC2039
    # bash:
    echo "${1:0:1}" | tr '[:upper:]' '[:lower:]'
  fi
}


configure() {

  _graphite_spooling=$(stdbool "${GRAPHITE_SPOOLING}")
  _graphite_pickle=$(stdbool "${GRAPHITE_PICKLE}")

  if [ "${_graphite_spooling}" = "y" ] || [ "${_graphite_spooling}" = "t" ]
  then
    GRAPHITE_SPOOLING="true"
  else
    GRAPHITE_SPOOLING="false"
  fi

  if [ "${_graphite_pickle}" = "y" ] || [ "${_graphite_pickle}" = "t" ]
  then
    GRAPHITE_PICKLE="true"
  else
    GRAPHITE_PICKLE="false"
  fi

  if [ "$(valid "${LOG_LEVEL}" "${valid_log_level}")" -eq 0 ]
  then
    log_warn "LOG_LEVEL '${LOG_LEVEL}' value is not valid"
    log_warn "valid values are: ${valid_log_level}'"
    log_warn "set LOG_LEVEL to default (error)"

    LOG_LEVEL=error
  fi

  if [ ! -f /etc/carbon-relay-ng/storage-schemas.conf ] && [ -f /etc/carbon-relay-ng/storage-schemas.conf-DIST ]
  then
    cp -a /etc/carbon-relay-ng/storage-schemas.conf-DIST /etc/carbon-relay-ng/storage-schemas.conf
  fi

  [ "${GRAPHITE_SPOOLING}" = "true" ] && mkdir "/var/spool/${HOSTNAME}"

  sed -i \
    -e "s|%HOME%|${HOME}|" \
    -e "s|%LOG_LEVEL%|${LOG_LEVEL}|" \
    -e "s|%HOSTNAME%|${HOSTNAME}|" \
    -e "s|%GRAPHITE_HOST%|${GRAPHITE_HOST}|" \
    -e "s|%GRAPHITE_PORT%|${GRAPHITE_PORT}|" \
    -e "s|%GRAPHITE_SPOOLING%|${GRAPHITE_SPOOLING}|" \
    -e "s|%GRAPHITE_PICKLE%|${GRAPHITE_PICKLE}|" \
    -e "s|%METRIC_PREPEND%|${METRIC_PREPEND}|" \
    "${config_file}"
}


wait_for_backend() {

  local server=${1}
  local port=${2}
  local max_retry=${3:-30}
  local retry=0

  log_info "check if the port ${port} for '${server}' is available"

  until [[ ${max_retry} -lt ${retry} ]]
  do
    # -v              Verbose
    # -w secs         Timeout for connects and final net reads
    # -X proto        Proxy protocol: "4", "5" (SOCKS) or "connect"
    #
    status=$(nc -v -w1 -X connect "${server}" "${port}" 2>&1 > /dev/null)

    #log_debug "'${status}'"

    if [[ $(echo "${status}" | grep -c succeeded) -eq 1 ]]
    then
      break
    else
      retry=$((retry + 1))
      log_info "  wait for an open port (${retry}/${max_retry})"
      sleep 5s
    fi
  done

  if [[ ${retry} -eq ${max_retry} ]] || [[ ${retry} -gt ${max_retry} ]]
  then
    log_error "could not connect to '${server}'"
    exit 1
  fi
}

# ---------------------------------------------------------------------------------------

run() {

  configure

  wait_for_backend "${GRAPHITE_HOST}" "${GRAPHITE_PORT}"

  log_info "----------------------------------------------------"
  log_info " carbon-relay-ng ${VERSION} - build: ${BUILD_DATE}"
  log_info "----------------------------------------------------"

  exec /usr/bin/carbon-relay-ng "${config_file}"
}

run

# EOF
