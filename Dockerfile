# Another flat Docker build file to create image of debian 10 linux system for an Apache Reverse Proxy.
# Use this file to test or create your own docker images for free.
# You can do that on your home server or on a vps instance.
# 
# Dockerfile v1.0 - MIT License

# ---------------------------------------------------------------------------------------------------------
# This file requires you to possess root permissions otherwise, you’ll receive a “permission denied” error. 
# Be sure to login to the root account or just prepend sudo to your commands
# ---------------------------------------------------------------------------------------------------------

FROM debian:10-slim
#RUN echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list

RUN echo "----> building reverse proxy docker image..... done."

LABEL maintainer="info@wuerfelfeste.de"

RUN echo 'deb http://httpredir.debian.org/debian buster main non-free contrib' > /etc/apt/sources.list
RUN echo 'deb-src http://httpredir.debian.org/debian buster main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb http://security.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list
RUN echo 'deb-src http://security.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list


# Create the reverse proxy directories
RUN mkdir -p /srv/rproxy/html/assets
RUN mkdir /srv/rproxy/html/secure
RUN mkdir /srv/rproxy/log

# Create user with install home and unlimited expiring password
RUN useradd -d /srv/rproxy -K PASS_MAX_DAYS=-1 rproxy

# Setup permissions for install home
RUN chown -R rproxy. /srv/rproxy/

# Set environmental variables (use ARG for nonpersistent vars after building)
ARG RPROXY_HOME=/srv/rproxy/
ARG RPROXY_LOG=/srv/rproxy/log
#ARG RPROXYPORT=10443
ARG RPROXYPORT=21080

## for apt to be noninteractive
ARG DEBIAN_FRONTEND "noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN true

# Installs locales
RUN apt update -y 
RUN apt upgrade -y
RUN apt install -y locales 

## preesed tzdata, update package index, upgrade packages and install needed software
RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    apt-get install -y procps

# Installs the latest packages version for debian
RUN apt -y install tree curl vim-nox rsync net-tools apt-file
RUN apt-file update

# Install apache2 services, packages and do cleanup
#RUN apt install -y apache2 php php-fpm
RUN apt install -y apache2
RUN apt -y install iputils-ping procps

# Set apache environmental variables (use ARG for nonpersistent vars after building)
ENV APACHE_RUN_USER rproxy
ENV APACHE_RUN_GROUP rproxy
#ENV APACHE_SERVER_NAME vtt.wuerfelfeste.de
ENV APACHE_SERVER_NAME rproxy.etabliocity.local
#ENV APACHE_SERVER_NAME localhost
ENV APACHE_SERVER_ADMIN webmaster@vtt.wuerfelfeste.de
ENV APACHE_SSL_CERTS vtt.wuerfelfeste.de.cer 
ENV APACHE_SSL_PRIVATE vtt.wuerfelfeste.de.key
ENV APACHE_SSL_PORT 10443
ENV APACHE_LOG_LEVEL debug
ENV APACHE_SSL_LOG_LEVEL debug
ENV APACHE_SSL_VERIFY_CLIENT optional
ENV APACHE_HTTP_PROTOCOLS http/1.1
ENV APPLICATION_URL https://${APACHE_SERVER_NAME}:${APACHE_SSL_PORT}
#ENV CLIENT_VERIFY_LANDING_3PAGE /error.php

# Copy Apache configuration file
COPY configs/httpd/000-default.conf /etc/apache2/sites-available/rproxy.etabliocity.local.conf
COPY configs/httpd/default-ssl.conf /etc/apache2/sites-available/rproxy-ssl.etabliocity.local.conf
COPY configs/httpd/ssl-params.conf /etc/apache2/conf-available/
#COPY configs/httpd/dir.conf /etc/apache2/mods-enabled/
#COPY configs/httpd/ports.conf /etc/apache2/


# Copy Server (pub and key) tls-auth.dontesta.it
# Copy CA (Certification Authority) Public Key
#COPY configs/certs/vtt.wuerfelfeste.de.cer /etc/ssl/certs/
#COPY configs/certs/rproxy.wuerfelfeste.cer /etc/ssl/certs/
#COPY configs/certs/vtt.wuerfelfeste.key /etc/ssl/private/

# Copy php samples script and other
#COPY configs/www/*.php /srv/rproxy/html/
#COPY configs/www/assets /srv/rproxy/html/assets
#COPY configs/www/secure /srv/rproxy/html/secure
#COPY images/favicon.ico /srv/rproxy/html/favicon.ico

# Copy scripts and entrypoint
#COPY scripts/entrypoint /entrypoint


# enable apache modules
RUN a2enmod ssl 
RUN a2enmod headers 
RUN a2enmod rewrite 
RUN a2enmod http2 
RUN a2enmod proxy 
RUN a2enmod proxy_http 
RUN a2enmod remoteip 
RUN a2enmod proxy_wstunnel
RUN a2enmod mpm_event 

# disable apache modules
RUN a2dismod mpm_prefork 
RUN a2dismod mpm_worker 
RUN a2dismod status 
RUN a2dismod -f autoindex 
RUN a2dismod -f negotiation
RUN a2dismod -f alias

# Setting Host
RUN echo "ServerName rproxy.etabliocity.local" >> /etc/apache2/apache2.conf

# restart apache
RUN service apache2 restart

# Adding hostnames and IPs of container network to /etc/hosts
#RUN echo '172.23.3.1 rproxy.etabliocity.local rproxy' >> /etc/hosts
#RUN echo '172.23.3.2 vtt.etabliocity.local fvtt' >> /etc/hosts

EXPOSE "${RPROXYPORT}"


