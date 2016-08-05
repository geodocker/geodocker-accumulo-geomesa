#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/accumulo-lib.sh

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
USER=${USER:-root}
THIS_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
ACCUMULO_USER=${ACCUMULO_USER:-root}

if [ $ROLE = "register" ]; then
  wait_until_hdfs_is_available
  with_backoff accumulo_is_available
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e \
    "createnamespace geomesa"
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e \
    "config -s general.vfs.context.classpath.geomesa=file:///opt/geomesa/accumulo/[^.].*.jar"
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} -e \
    "config -ns geomesa -s table.classpath.context=geomesa"
  echo "Accumulo namespace configured: geomesa"
elif [ $ROLE = "master" ]; then
  (setsid /sbin/geomesa-entrypoint.sh register &> /tmp/geomesa-register.log &)
  /sbin/entrypoint.sh "$@"
else
  /sbin/entrypoint.sh "$@"
fi
