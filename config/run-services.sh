#!/bin/bash
set -x

# format the namenode if it's not already done
rm -rf /tmp/*
/opt/hadoop/bin/hdfs namenode -format

# start ssh daemon
service ssh start

# clear hadoop logs
rm -rf /opt/hadoop/logs/*

#start HBASE
rm -rf /opt/hbase/zookeeper/*
rm -rf /opt/hbase/logs/*
/opt/hbase/bin/start-hbase.sh

sleep 1
#start mongodb
rm -rf /opt/mongodb/data/
mkdir -p /opt/mongodb/data/
rm -rf /opt/mongodb/logs/*
/opt/mongodb/libexec/bin/mongod -f /opt/mongodb/mongodb.config

sleep 1

#start nutch rest api
/opt/nutch/bin/nutch nutchserver -port $NUTCHSERVER_PORT &

# tail log directory
tail -n 1000 -f /opt/hadoop/logs/*.log /opt/hbase/logs/*.log /opt/nutch/logs/*.log
