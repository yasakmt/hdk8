# Use a base image with Java pre-installed, as Hadoop requires Java
FROM openjdk:8-jdk

# Set environment variables for Hadoop
ENV HADOOP_VERSION 3.3.6
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install SSH and other necessary packages
RUN apt-get update && apt-get install -y ssh pdsh rsync \
    && rm -rf /var/lib/apt/lists/*

# Create the necessary directory for SSH privilege separation
RUN mkdir /run/sshd

# Configure SSH (use your own key or generate one)
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Update sshd_config to fix any potential issues
RUN echo "Host *" > /root/.ssh/config \
    && echo "   StrictHostKeyChecking no" >> /root/.ssh/config \
    && chmod 400 /root/.ssh/config



# Download and unpack Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
    && tar -xzf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local \
    && mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && rm hadoop-$HADOOP_VERSION.tar.gz


# Custom Hadoop configuration steps here
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY start-hadoop.sh /start-hadoop.sh

# Expose necessary ports
EXPOSE 9870 8088

# Start SSH and keep the container running
RUN chmod +x /start-hadoop.sh
CMD ["/usr/sbin/sshd", "-D"]


