from fernandoacorreia/ubuntu-14.04-oracle-java-1.7
MAINTAINER breedish <breedish@gmail.com>

WORKDIR /root/
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository -y multiverse && \
  add-apt-repository -y restricted && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && apt-get upgrade -y
RUN apt-get install -y openssh-server vim telnet curl

# Download Hadoop
RUN wget -q 'https://archive.apache.org/dist/hadoop/core/hadoop-2.5.2/hadoop-2.5.2.tar.gz'
RUN wget -q 'http://ftp.byfly.by/pub/apache.org/hbase/hbase-0.98.12/hbase-0.98.12-hadoop2-bin.tar.gz'
RUN wget -q 'https://dl.dropboxusercontent.com/u/5782994/nutch-dist.tar'
RUN wget -q 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1404-3.0.3.tgz'

# Deploy and setup Hadoop
RUN tar xvfz /root/hadoop-2.5.2.tar.gz -C /opt && \
  ln -s /opt/hadoop-2.5.2 /opt/hadoop && \
  chown -R root:root /opt/hadoop-2.5.2 && \
  mkdir /opt/hadoop-2.5.2/logs && \
  chown -R root:root /opt/hadoop-2.5.2/logs

# Deploy and setup Hbase
RUN tar xvfz /root/hbase-0.98.12-hadoop2-bin.tar.gz -C /opt && \
  chown -R root:root /opt/hbase-0.98.12-hadoop2 && \
  ln -s /opt/hbase-0.98.12-hadoop2 /opt/hbase && \
  chown -R root:root /opt/hbase-0.98.12-hadoop2 && \
  mkdir /opt/hbase-0.98.12-hadoop2/logs && \
  chown -R root:root /opt/hbase-0.98.12-hadoop2/logs && \
  mkdir /opt/hbase-0.98.12-hadoop2/data && \
  mkdir /opt/hbase-0.98.12-hadoop2/zookeeper
 
# Deploy and setup Nutch
RUN mkdir -p /opt/nutch && tar xvf nutch-dist.tar -C /opt/nutch && \
  mkdir -p /opt/nutch/logs 

#Deploy and setup MongoDB
RUN mkdir -p /opt/mongodb/data && mkdir -p /opt/mongodb/logs && \
  tar xvfz /root/mongodb-linux-x86_64-ubuntu1404-3.0.3.tgz -C /opt && \
  ln -s /opt/mongodb-linux-x86_64-ubuntu1404-3.0.3 /opt/mongodb/libexec


# Setup root environment
ADD config/bashrc /home/root/.bashrc

# Add Hadoop, HBase and nutch configs
ADD config/core-site.xml /tmp/hadoop-etc/core-site.xml
ADD config/mapred-site.xml /tmp/hadoop-etc/mapred-site.xml
ADD config/hdfs-site.xml /tmp/hadoop-etc/hdfs-site.xml
ADD config/yarn-site.xml /tmp/hadoop-etc/yarn-site.xml
ADD config/hbase-site.xml /tmp/hbase-etc/hbase-site.xml
ADD config/nutch-site.xml /tmp/nutch-etc/nutch-site.xml
ADD config/mongo.config /tmp/mongodb-etc/mongodb.config
RUN cp /tmp/hadoop-etc/* /opt/hadoop/etc/hadoop/
RUN cp /tmp/hbase-etc/* /opt/hbase/conf/
RUN cp /tmp/nutch-etc/* /opt/nutch/conf/
RUN cp /tmp/hbase-etc/* /opt/nutch/conf/
RUN cp /tmp/mongodb-etc/* /opt/mongodb/

ENV NUTCH_ROOT /opt/nutch
ENV NUTCH_HOME /opt/nutch
ENV HADOOP_HOME /opt/hadoop
ENV NUTCHSERVER_PORT 8081

# Expose ports
# NUTCH REST
EXPOSE 8081

# MongoDB
EXPOSE 27017 28017

# Expose SSHD
EXPOSE 22

#HBASE
EXPOSE 6000 60010 60020 60030

#YARN Web UI
EXPOSE 8088 

# Create start script
ADD config/run-services.sh /root/run-services.sh
RUN chmod +x /root/run-services.sh

CMD ["/root/run-services.sh"]