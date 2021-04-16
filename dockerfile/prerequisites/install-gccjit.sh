set -eu
WORKPATH=`mktemp -d`
cd ${WORKPATH}
INSTALL_PREFIX="/usr/local"
if [[ $# -gt 0 ]]; then
    INSTALL_PREFIX=$1
fi

# install bison and other
apt-get autoremove bison -y
wget http://ftp.gnu.org/gnu/bison/bison-3.3.2.tar.gz
tar -zxvf bison-3.3.2.tar.gz
cd bison-3.3.2
./configure
make -j
make install
apt-get install -y libgccjit-7-dev


cd ${WORKPATH}
# this is now a private one
git clone -b final https://github.com/LiPengze97/predicate_flex
mkdir build
cd build
cmake ..
make -j
make install


