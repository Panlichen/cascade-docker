#!/bin/bash

set -eu
WORKPATH="/root"

cd ${WORKPATH}

git clone https://github.com/Panlichen/build-derecho.git

cd build-derecho
./install-and-build-cornell-no-sudo.sh