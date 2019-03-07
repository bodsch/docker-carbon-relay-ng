#!/bin/bash

HOST=127.0.0.1
PORT=2003

wait_for_service() {

  echo -e "\nwait for the carbon-c-relay service"

  RETRY=35
  # wait for the running certificate service
  #
  until [[ ${RETRY} -le 0 ]]
  do
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/2003" 2> /dev/null
    result=${?}
    if [ ${result} -eq 0 ]
    then
      break
    else
      sleep 10s
      RETRY=$(( RETRY - 1))
    fi
  done

  if [[ $RETRY -le 0 ]]
  then
    echo "Could not connect to the carbon-c-relay service"
    exit 1
  fi
}

#
# Get the current hostname
#
host=$(hostname --short)

#
# The current time - we want all metrics to be reported at the
# same time.
#
time=$(date +%s)


###
##
## A simple function to send data to a remote host:port address.
##
###
send() {

  echo "  - '${1}'"

  #
  # If we have nc then send the data, otherwise alert the user.
  #
  if ( command -v nc >/dev/null 2>/dev/null )
  then
    echo "${1}" | nc -w1 "${HOST}" "${PORT}"
    result=${?}

    if [ ${result} -eq 0 ]
    then
      echo "     successful"
    else
      echo "     failed"
    fi
  else
    echo "nc (netcat) is not present.  Aborting"
  fi
}



send_request() {

  echo -e "\nsend some metrics to graphite .."
  ##
  ## Fork-count
  ##
  if [ -e /proc/stat ]; then
    forked=$(awk '/processes/ {print $2}' /proc/stat)
    send "$host.process.forked $forked $time"
  fi

  ##
  ## Process-count
  ##
  if ( command -v ps >/dev/null 2>/dev/null )
  then
    pcount=$(ps -Al | wc -l)
    send "$host.process.count  $pcount $time"
  fi

  echo -e "\ntest webinterface .."

  curl \
    --head \
    http://localhost:8081

  echo ""
}


inspect() {

  echo ""
  echo "inspect needed containers"
  for d in $(docker ps | tail -n +2 | awk  '{print($1)}')
  do
    # docker inspect --format "{{lower .Name}}" ${d}
    c=$(docker inspect --format '{{with .State}} {{$.Name}} has pid {{.Pid}} {{end}}' "${d}")
    s=$(docker inspect --format '{{json .State.Health }}' "${d}" | jq --raw-output .Status)

    printf "%-40s - %s\n"  "${c}" "${s}"
  done
}

inspect
wait_for_service
send_request

exit 0

