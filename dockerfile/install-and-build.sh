# sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
apt-get clean

# add gcc-8 packages
apt-get -y update
apt-get install software-properties-common -y
add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get -y update
apt-get -y install gcc-8 g++-8
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-8
update-alternatives --config gcc

# install other tools and dependencies
apt-get -y install autoconf vim net-tools libssl-dev libreadline-dev libsnappy-dev libc-ares-dev \
libboost-dev libboost-system-dev \
libtool m4 automake wget curl make unzip iputils-ping git --fix-missing

chmod +x prerequisites/install-cmake-3.18.sh
prerequisites/install-cmake-3.18.sh
chmod +x prerequisites/install-spdlog.sh
prerequisites/install-spdlog.sh
chmod +x prerequisites/install-libfabric.sh
prerequisites/install-libfabric.sh
chmod +x prerequisites/install-mutils.sh
prerequisites/install-mutils.sh
chmod +x prerequisites/install-mutils-containers.sh
prerequisites/install-mutils-containers.sh
chmod +x prerequisites/install-mutils-tasks.sh
prerequisites/install-mutils-tasks.sh
chmod +x prerequisites/install-json.sh
prerequisites/install-json.sh
chmod +x prerequisites/install-openssl-1.1.1.sh
prerequisites/install-openssl-1.1.1.sh
chmod +x prerequisites/install-gccjit.sh
prerequisites/install-gccjit.sh
chmod +x prerequisites/install-linq.sh
prerequisites/install-linq.sh
chmod +x prerequisites/install-fuse.sh
prerequisites/install-fuse.sh
chmod +x prerequisites/install-mxnet.sh
prerequisites/install-mxnet.sh

chmod +x build/build-derecho.sh
build/build-derecho.sh
chmod +x build/build-cascade.sh
build/build-cascade.sh

sysctl -w vm.overcommit_memory=1