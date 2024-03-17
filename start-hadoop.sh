#!/bin/bash
# Start HDFS daemons
$HADOOP_HOME/sbin/start-dfs.sh
# Start YARN daemons
$HADOOP_HOME/sbin/start-yarn.sh

# Keep the container running
tail -f /dev/null
