#!/bin/bash
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "Polling endpoint for status"
      echo " "
      echo "./main.sh [options]"
      echo " "
      echo "options:"
      echo "-h, --help           Show brief help"
      echo "--url=URL            url to poll"
      echo "--interval=INTERVAL  Interval between each call, in seconds"
      echo "--timeout=TIMEOUT    Timeout before stop polling, in seconds"
      exit 0
      ;;
    --url*)
      url=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --interval*)
      interval=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done

function poll_status {
  while true;
  do
    status=$(curl $url -s | jq  -r '.status');
    echo "$(date +%H:%M:%S): status is $status";
    if [ "$status" == "FAILED" ]; then
      echo "Job failed!"
      exit 1;
    fi
    if [ "$status" == "RUNNABLE" ]; then
      echo "Job in queue!"
    fi
    if [ "$status" == "RUNNING" ]; then
      echo "Job started"
    fi
    if [ "$status" == "SUCCEEDED" ]; then
      echo "Job done"
      exit 0;
    fi
    sleep $interval;
  done
}

printf "\nPolling '${url%\?*}' every $interval seconds, until status is 'complete'\n"
poll_status
