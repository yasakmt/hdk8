# Use a base image with Java pre-installed, as Hadoop requires Java
FROM openjdk:8-jdk

# Set environment variables for Hadoop
ENV JAVA_HOME /usr/local/openjdk-8
RUN echo "JAVA_HOME=/usr/local/openjdk-8" >> /etc/environment

ENV PDSH_RCMD_TYPE ssh
ENV HADOOP_VERSION 3.3.6
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PDSH_RCMD_TYPE


# Install SSH and other necessary packages
RUN apt-get update && apt-get install -y ssh pdsh rsync vim net-tools iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Create the necessary directory for SSH privilege separation
RUN mkdir /run/sshd
RUN echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config


# Configure SSH (use your own key or generate one)
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Update sshd_config to fix any potential issues
RUN echo "Host *" > /root/.ssh/config \
    && echo "   StrictHostKeyChecking no" >> /root/.ssh/config \
    && chmod 400 /root/.ssh/config

RUN addgroup hadoop && adduser --ingroup hadoop --disabled-password --gecos "" hadoop

USER hadoop

# Generate SSH keys for hadoop user
RUN ssh-keygen -q -t rsa -N '' -f /home/hadoop/.ssh/id_rsa && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chmod 0600 /home/hadoop/.ssh/authorized_keys

# Disable strict host key checking for localhost in the SSH configuration
RUN echo "Host localhost\n\tStrictHostKeyChecking no\n" >> /home/hadoop/.ssh/config && \
    echo "Host 127.0.0.1\n\tStrictHostKeyChecking no\n" >> /home/hadoop/.ssh/config && \
    echo "Host 0.0.0.0\n\tStrictHostKeyChecking no\n" >> /home/hadoop/.ssh/config && \
    chmod 0600 /home/hadoop/.ssh/config
ENV JAVA_HOME /usr/local/openjdk-8
RUN  touch ~/.ssh/environment && echo "JAVA_HOME=/usr/local/openjdk-8" >> ~/.ssh/environment && \
     echo "PDSH_RCMD_TYPE=ssh" >> ~/.ssh/environment && chmod 600 ~/.ssh/environment



USER root
COPY custom-hadoopuser-cmds.sh /home/hadoop/
RUN chmod +x /home/hadoop/custom-hadoopuser-cmds.sh
# Download and unpack Hadoop
#RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
#    && tar -xzf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local \
#    && mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME \
#    && rm hadoop-$HADOOP_VERSION.tar.gz
COPY  hadoop-$HADOOP_VERSION.tar.gz .
RUN tar -xzf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local \
    && mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && rm hadoop-$HADOOP_VERSION.tar.gz

# Custom Hadoop configuration steps here
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY start-hadoop.sh /home/hadoop/start-hadoop.sh
RUN chmod +x /home/hadoop/start-hadoop.sh
RUN chown hadoop:hadoop /home/hadoop/start-hadoop.sh


# Expose necessary ports
EXPOSE 9870 8088

# Start SSH and keep the container running

CMD ["/usr/sbin/sshd", "-D"]


