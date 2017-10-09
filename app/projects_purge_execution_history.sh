#!/bin/bash

##### Functions
function usage {
    echo -e "\nusage: $0 [--age <d,m,y>]"
    echo -e ""
    echo -e "  General parameters:"
    echo -e "    --age            specify purge after date. Default 7d."
    echo -e "    --max            maximum number to purge per run. Default is 100."
    echo -e "    --timeout        maximum amount of time allowed to purge the value specified for --max. Default 28800 (seconds)."
    echo -e "    --debug          debug mode."
    echo -e "    -?               help."
    exit 0
}

##### Posistional params
while [ $# -gt 0 ]; do
    case $1 in
      --age )          shift && export AGE="$1" ;;
      --max )          shift && export MAX="$1" ;;
      --timeout )      shift && export RD_HTTP_TIMEOUT="$1" ;;
      --debug )        DEBUG=debug ;;
      -? | --help )    usage && exit 0 ;;
      * )              echo -e "\nError: Unknown option: $1\n" >&2 && exit 1 ;;
    esac
    shift
done

##### Main
if [[ ! -z $DEBUG ]]; then set -x; fi
if [[ -z $AGE ]]; then export AGE="7d"; fi
if [[ -z $MAX ]]; then export MAX="100"; fi
if [[ -z $RD_HTTP_TIMEOUT ]]; then export RD_HTTP_TIMEOUT="28800"; fi

export PROJECTS=$(/rundeck-cli/bin/rd projects list --outformat %name) # find all projecs in Rundeck

for i in ${PROJECTS}; do
  echo "Cleaning up job execution history for project: $i"
  while /rundeck-cli/bin/rd executions query --older ${AGE} --max ${MAX} -p $i | grep -q "more results"; do
    /rundeck-cli/bin/rd executions deletebulk --confirm --older ${AGE} --max ${MAX} -p $i
  done
done