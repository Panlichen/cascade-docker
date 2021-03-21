FROM ubuntu:18.04
MAINTAINER myles.l.pan@gmail.com

RUN apt-get clean
RUN apt update -y
RUN apt install -y git

COPY scripts/ /root/scripts
RUN ["chmod", "+x", "/root/scripts/run-build.sh"]

RUN ["/root/scripts/run-build.sh"]