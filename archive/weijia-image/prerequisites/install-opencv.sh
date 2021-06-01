#!/bin/bash
# install python opencv
apt-get -y install python3-opencv
# Download and unpack sources
wget -O opencv.zip https://github.com/opencv/opencv/archive/master.zip
unzip opencv.zip
# Create build directory
mkdir -p build && cd build
# Configure
cmake -D CMAKE_INSTALL_PREFIX=/root/opt-dev ../opencv-master
# Build
make -j `nproc`
make install
