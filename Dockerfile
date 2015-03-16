FROM      ubuntu:14.04

# Update ubuntu and download dependencies
RUN apt-get -y update

# Install Build Tools
RUN apt-get -y -f install python3-setuptools
RUN easy_install3 pip
RUN apt-get -y -f install vim make git lxc golang unzip curl
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install Consul
ADD https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip /tmp/consul.zip
RUN cd /usr/local/sbin && \
    unzip /tmp/consul.zip
EXPOSE 8400 8500 8600/udp
CMD /usr/local/sbin/consul agent -bootstrap -server -data-dir=/tmp/consul -client=0.0.0.0
