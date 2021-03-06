FROM phusion/baseimage:latest
MAINTAINER gregro
ENV DEBIAN_FRONTEND noninteractive

#Disable the SSH server
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Set correct environment variables.
ENV HOME /root

# Use docker's init system.
CMD ["/sbin/my_init"]

#Change uid & gid
RUN usermod -u 99 nobody && \
    usermod -g 100 nobody

RUN apt-get update && apt-get install -qy mono-complete sudo unzip wget nano cron

#Download and extract
RUN mkdir /webgrab && \
    wget -O /tmp/webgrab.tar.gz http://www.webgrabplus.com/sites/default/files/download/SW/V2.1.0/WebGrabPlus_V2.1_install.tar.gz && \
    wget -O /tmp/siteini.zip http://webgrabplus.com/sites/default/files/download/ini/SiteIniPack_current.zip && \
    tar --strip-components=1 -xvf /tmp/webgrab.tar.gz -C /webgrab && \
    rm -rf /webgrab/siteini.pack && \
    unzip -o -d /webgrab /tmp/siteini.zip && \
    rm -f /tmp/webgrab.tar.gz /tmp/siteini.zip && \
    cd /webgrab && \
    ./install.sh && \
    rm -f /webgrab/WebGrab++.config.xml /webgrab/WebGrab++.config.example.xml

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

#Add scripts & config
ADD ./scripts/startup.sh ./scripts/mycron ./scripts/WebGrab++.config.xml /webgrab/scripts/
RUN chmod -R +x /webgrab/ && \
    crontab /webgrab/scripts/mycron && \
    mkdir -p /etc/my_init.d && \
    cp /webgrab/scripts/startup.sh /etc/my_init.d/ 

VOLUME /config \
       /data
