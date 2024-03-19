#!/bin/bash
export HDFS_NAMENODE_USER="hadoop"
export HDFS_DATANODE_USER="hadoop"
export HDFS_SECONDARYNAMENODE_USER="hadoop"
export YARN_RESOURCEMANAGER_USER="hadoop"
export YARN_NODEMANAGER_USER="hadoop"
# Start HDFS daemons
#su hadoop -c "$HADOOP_HOME/bin/hdfs namenode"
su hadoop -c $HADOOP_HOME/sbin/start-dfs.sh
# Start YARN daemons
su hadoop -c $HADOOP_HOME/sbin/start-yarn.sh

# Keep the container running
tail -f /dev/null
