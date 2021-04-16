FROM poanpan/mlnx_ofed_linux-5.3-1.0.0.1-ubuntu18.04
MAINTAINER myles.l.pan@gmail.com

WORKDIR /root

COPY install-and-build.sh /root/install-and-build.sh
COPY prerequisites/ /root/prerequisites
COPY build/ /root/build
ARG CASCADE_BRANCH=master
RUN ["chmod", "+x", "/root/install-and-build.sh"]

RUN ["bash", "/root/install-and-build.sh"]