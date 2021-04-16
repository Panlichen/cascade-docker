#!/bin/bash
set -eu

# From https://github.com/spdk/spdk README

# Source Code
git clone https://github.com/spdk/spdk
cd spdk
# The way dpdk is compiled and installed has changed dramatically in subsequent releases.
# https://github.com/spdk/spdk/releases/tag/v20.07-rc1
git checkout v20.04.1
git submodule update --init

# Prerequisites
./scripts/pkgdep.sh

# Build
./configure  --with-shared --with-rdma # to resolve "/usr/bin/ld: cannot find -ldpdk" 
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`

# Unit Tests
# ./test/unit/unittest.sh
# will see "All unit tests passed"

make install
cd dpdkbuild && make install && cd ..
# though Makefile under dpdk/ seems empty, it indeed does things.
cd dpdk && make install && cd ..

scripts/setup.sh

export LD_LIBRARY_PATH=/usr/local/lib