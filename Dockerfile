FROM rjrivero/baseimage-ssh

# Openssl already included in phusion/baseimage
# RUN apt-get -q update && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y \
#        openssl && \
#    apt-get clean && rm -rf /tmp/* /var/cache/apt/*

# CA files path
ENV CA_PATH /opt/ca
VOLUME      /opt/ca

# Add CA files
ADD files	/root
ADD my_init.d	/etc/my_init.d

# Expose SSH port
EXPOSE 22

# Change to scripts directory
WORKDIR /root/scripts
