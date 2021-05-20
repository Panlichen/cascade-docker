#!/bin/bash

set -eu
WORKPATH="${HOME}"
INSTALL_PREFIX="/usr/local"
if [[ $# -gt 0 ]]; then
    INSTALL_PREFIX=$1
fi

LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

echo "Using INSTALL_PREFIX=${INSTALL_PREFIX}"
cd ${WORKPATH}

if [ -d "derecho" ];then
  rm -rf derecho
fi

git clone --recursive https://github.com/Panlichen/derecho.git -b layout-conf
cd derecho

./build.sh Release USE_VERBS_API
# mkdir build && cd build
# cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ..
# make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
cd build-Release
make install