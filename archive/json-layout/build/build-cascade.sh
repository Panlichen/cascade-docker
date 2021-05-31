#!/bin/bash

set -eu
WORKPATH="${HOME}"
INSTALL_PREFIX="/usr/local"
if [[ $# -gt 0 ]]; then
    INSTALL_PREFIX=$1
fi

echo "Using INSTALL_PREFIX=${INSTALL_PREFIX}"
cd ${WORKPATH}

if [ -d "cascade" ];then
  rm -rf cascade
fi

git clone --recursive https://github.com/Panlichen/cascade.git -b ${CASCADE_BRANCH}
cd cascade
./build.sh Release USE_VERBS_API
# mkdir build && cd build
# cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ..
# make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
cd build-Release
make install
echo CASCADE_BRANCH: ${CASCADE_BRANCH}