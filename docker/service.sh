#!/usr/bin/env bash

## Usage:
# service.sh [<DEBUG_LEVEL> [<JUPYTER_PORT>]]
#
# Arguments:
#   <DEBUG_LEVEL>  : [default: 0]
#   <JUPYTER_PORT>  : [default: 8888]
##

[ -f .bashrc ] && . .bashrc
this=$(dirname "${BASH_SOURCE[0]}")
DEBUG="${1:-0}"
JUPYTER_PORT="${2:-8888}"

stop_service()
{
  echo "stopping jobs"
  for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null

  if [ "$DEBUG" != 0 ]; then
    for log in gadgetron.log jupyterhub.log; do
      if [ -f "$log" ]; then
        echo "----------- Last 70 lines of $log"
        tail -n 70 "$log"
      fi
    done
  fi

  exit 0
}

# start gadgetron
pushd $SIRF_PATH/../..
GCONFIG=./INSTALL/share/gadgetron/config/gadgetron.xml
[ -f "$GCONFIG" ] || cp "$GCONFIG".example "$GCONFIG"
[ -f ./INSTALL/bin/gadgetron ] \
  && ./INSTALL/bin/gadgetron >& gadgetron.log&
popd

# copy & create SIRF-Exercises
which unzip || sudo apt-get install -yqq unzip
for home in $(ls -d /home/*); do
  pushd $home
  [ -d SIRF-Exercises ] || cp -a $SIRF_PATH/../../../SIRF-Exercises .
  for i in SIRF-Exercises/scripts/download_*.sh; do ./$i $PWD; done
  #[ -e devel ] || ln -s /devel .
  popd
done

# start jupyter
which jupyterhub || conda activate hub
#jupyterhub --generate-config
#cat "c.JupyterHub.bind_port = $JUPYTER_PORT" >> jupyterhub_confing.py
jupyterhub --port $JUPYTER_PORT >& jupyterhub.log&

trap "stop_service" SIGTERM
trap "stop_service" SIGINT
wait
