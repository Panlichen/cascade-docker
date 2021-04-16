#!/bin/bash
set -eu
export TMPDIR=/var/tmp
INSTALL_PREFIX="/usr/local"
if [[ $# -gt 0 ]]; then
    INSTALL_PREFIX=$1
fi

echo "Using INSTALL_PREFIX=${INSTALL_PREFIX}"

WORKPATH=`mktemp -d`
cd ${WORKPATH}

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
python3 -m pip install meson
python3 -m pip install ninja

wget https://github.com/libfuse/libfuse/releases/download/fuse-3.10.0/fuse-3.10.0.tar.xz
tar xJvf fuse-3.10.0.tar.xz
cd fuse-3.10.0

mkdir build; cd build
meson ..
ninja
ninja install
