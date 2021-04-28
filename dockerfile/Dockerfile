FROM poanpan/mlnx_ofed_linux-5.3-1.0.0.1-ubuntu18.04
MAINTAINER myles.l.pan@gmail.com

WORKDIR /root

COPY install-and-build.sh /root/install-and-build.sh
COPY prerequisites/ /root/prerequisites
COPY build/ /root/build
COPY config/ /root/config
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV DERECHO_CONF_FILE=/root/derecho.cfg
ARG CASCADE_BRANCH=master
RUN ["chmod", "+x", "/root/install-and-build.sh"]
RUN ["chmod", "+x", "/root/config/config-cascade.sh"]

RUN ["bash", "/root/install-and-build.sh"]