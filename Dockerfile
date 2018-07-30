FROM phusion/baseimage:0.9.18
MAINTAINER Jeremy Barneron <jeremy.barneron@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y gdebi-core

ENV COTURN_VER 4.4.5.3
RUN cd /tmp/ && curl -sL http://turnserver.open-sys.org/downloads/v${COTURN_VER}/turnserver-${COTURN_VER}-debian-wheezy-ubuntu-mint-x86-64bits.tar.gz | tar -xzv

RUN groupadd turnserver
RUN useradd -g turnserver turnserver
RUN gdebi -n /tmp/coturn*.deb

RUN mkdir /etc/service/turnserver
COPY turnserver.sh /etc/service/turnserver/run

# Set NEO user for turn server
RUN turnadmin --add-admin -u admin -p admin -r webrtc.neo.ovh

# Create certificate for turnserver administration
RUN mkdir /certificates
COPY certificate_conf.cnf /certificates/conf.cnf
RUN openssl req -x509 -config /certificates/conf.cnf -subj "/" -newkey rsa:2048 -keyout /certificates/turn_server_pkey.pem -out /certificates/turn_server_cert.pem -days 3001 -nodes

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
