#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/hdfs-lib.sh
source /sbin/accumulo-lib.sh

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
USER=${USER:-root}
ACCUMULO_USER=${ACCUMULO_USER:-root}

enable_iterators(){
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} <<-EOF
    createnamespace geomesa
    config -s general.vfs.context.classpath.geomesa=file:///opt/geomesa/accumulo/geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar
    config -ns geomesa -s table.classpath.context=geomesa
EOF
}

if [[ $ROLE = "master" ]]; then
  runuser -p -u $USER -- wait_until_accumulo_is_available && sleep 5 && enable_iterators &
fi

/sbin/entrypoint.sh "$@"

