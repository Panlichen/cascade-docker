#!/bin/bash
set -eu
export TMPDIR=/var/tmp
INSTALL_PREFIX="/usr/local"
if [[ $# -gt 0 ]]; then
    INSTALL_PREFIX=$1
fi

echo "Using INSTALL_PREFIX=${INSTALL_PREFIX}"

WORKPATH=${HOME}
cd ${WORKPATH}
apt-get update
apt-get install -y ninja-build ccache libopenblas-dev libopencv-dev libatlas-base-dev libatlas3-base
apt install -y gfortran

git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet -b v1.7.x && cd mxnet
# 似乎不能再写回到原来文件，会变成空文件，写到一个新位置就好
cat make/config.mk | sed "s/USE_CPP_PACKAGE = 0/USE_CPP_PACKAGE = 1/g" > config.mk
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
install -d ${INSTALL_PREFIX}/include/mxnet-cpp
install cpp-package/include/mxnet-cpp/* ${INSTALL_PREFIX}/include/mxnet-cpp

install -d ${INSTALL_PREFIX}/include/mxnet/ir
install include/mxnet/ir/* ${INSTALL_PREFIX}/include/mxnet/ir
install -d ${INSTALL_PREFIX}/include/mxnet/node
install include/mxnet/node/* ${INSTALL_PREFIX}/include/mxnet/node
install -d ${INSTALL_PREFIX}/include/mxnet/runtime
install include/mxnet/runtime/* ${INSTALL_PREFIX}/include/mxnet/runtime

install -d ${INSTALL_PREFIX}/include/dlpack
install include/dlpack/* ${INSTALL_PREFIX}/include/dlpack

install -d ${INSTALL_PREFIX}/include/dmlc
install include/dmlc/* ${INSTALL_PREFIX}/include/dmlc

install -d ${INSTALL_PREFIX}/include/mkldnn
install include/mkldnn/* ${INSTALL_PREFIX}/include/mkldnn

install -d ${INSTALL_PREFIX}/include/mshadow/cuda
install include/mshadow/cuda/* ${INSTALL_PREFIX}/include/mshadow/cuda
install -d ${INSTALL_PREFIX}/include/mshadow/extension
install include/mshadow/extension/* ${INSTALL_PREFIX}/include/mshadow/extension
install -d ${INSTALL_PREFIX}/include/mshadow/packet
install include/mshadow/packet/* ${INSTALL_PREFIX}/include/mshadow/packet

install -d ${INSTALL_PREFIX}/include/nnvm
install include/nnvm/* ${INSTALL_PREFIX}/include/nnvm

install -d ${INSTALL_PREFIX}/lib
install lib/* ${INSTALL_PREFIX}/lib

install -d ${INSTALL_PREFIX}/include/mxnet
install include/mxnet/* ${INSTALL_PREFIX}/include/mxnet
install -d ${INSTALL_PREFIX}/include/mshadow
install include/mshadow/* ${INSTALL_PREFIX}/include/mshadow
# make install