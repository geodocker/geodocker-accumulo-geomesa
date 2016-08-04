#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/hdfs-lib.sh
source /sbin/accumulo-lib.sh

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
USER=${USER:-root}
HDFS_ROOT=${HDFS_ROOT:-}
ACCUMULO_USER=${ACCUMULO_USER:-root}

enable_iterators()
  ROOT=${HADOOP_MASTER_ADDRESS:$(xmllint --xpath "//property[name='fs.defaultFS']/value/text()"  /etc/hadoop/conf/core-site.xml)}
  HDFS_LIB_DIR=hdfs://$ROOT/accumulo-classpath/geomesa
  runuser -p -u $USER -- hdfs dfs -mkdir -p $HDFS_LIB_DIR
  runuser -p -u $USER -- hdfs dfs -copyFromLocal /opt/geomesa/accumulo/* $HDFS_LIB_DIR
  accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} <<-EOF
    createnamespace geomesa
    config -s general.vfs.context.classpath.geomesa=${HDFS_LIB_DIR}/[^.].*.jar
    config -ns geomesa -s table.classpath.context=geomesa
EOF
}

if [[ $ROLE = "master" ]]; then
  runuser -p -u $USER -- wait_until_accumulo_is_available && sleep 5 && enable_iterators &
fi

/sbin/entrypoint.sh "$@"
