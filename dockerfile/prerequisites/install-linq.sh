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
git clone https://github.com/k06a/boolinq.git

cd boolinq
install -d ${INSTALL_PREFIX}/include/boolinq/
install include/boolinq/* ${INSTALL_PREFIX}/include/boolinq/