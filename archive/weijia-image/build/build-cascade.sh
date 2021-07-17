#!/bin/bash

set -eu
WORKPATH="${HOME}/workspace"
cd ${WORKPATH}

if [ -d "cascade" ];then
  rm -rf cascade
fi

git clone --recursive https://github.com/${REPO}/cascade.git -b ${CASCADE_BRANCH}
cd cascade

# TODO: rely on models downloaded on host machine, not a good way.
cp /root/workspace/models/bcs-inference-model.tar.gz src/applications/demos/dairy_farm/
cp /root/workspace/models/cow-id-model.tar.gz src/applications/demos/dairy_farm/
cp /root/workspace/models/filter-model.tar.gz src/applications/demos/dairy_farm/

# case insensitive for string comparison
shopt -s nocasematch

colorful_print() {
    color_prefix="0;30"
    case $1 in
        "red")
            color_prefix="0;31"
            ;;
        "green")
            color_prefix="0;32"
            ;;
        "orange")
            color_prefix="0;33"
            ;;
        "blue")
            color_prefix="0;34"
            ;;
        "purple")
            color_prefix="0;35"
            ;;
        "cyan")
            color_prefix="0;36"
            ;;
        "lightgray")
            color_prefix="0;37"
            ;;
        "darkgray")
            color_prefix="1;30"
            ;;
        "lightred")
            color_prefix="1;31"
            ;;
        "lightgreen")
            color_prefix="1;32"
            ;;
        "yellow")
            color_prefix="1;33"
            ;;
        "lightblue")
            color_prefix="1;34"
            ;;
        "lightpurple")
            color_prefix="1;35"
            ;;
        "lightcyan")
            color_prefix="1;36"
            ;;
        "white")
            color_prefix="1;37"
            ;;
    esac;
    echo -e "\e[${color_prefix}m $2 $3 $4 $5 $6 $7 $8 $9 \e[0m"
}

if [[ $# -lt 1 ]]; then
    colorful_print orange "USAGE: $0 <Release|Debug|RelWithDebInfo|Benchmark|Clear> [USE_VERBS_API]"
    exit -1
fi

if [[ $1 == "Clear" ]]; then
    rm -rf build-*
    exit 0
fi

# install pybind11
python -m pip install "pybind11[global]"

build_type=$1
# install_prefix="/usr/local"
install_prefix="/root/opt-dev"

# install rpclib
bash scripts/prerequisites/install-rpclib.sh ${install_prefix}

# install httplib
bash scripts/prerequisites/install-httplib.sh ${install_prefix}

cmake_defs="-DCMAKE_BUILD_TYPE=${build_type} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_INSTALL_PREFIX=${install_prefix}"
build_path="build-${build_type}"

if [[ $2 == "USE_VERBS_API" ]]; then
    cmake_defs="${cmake_defs} -DUSE_VERBS_API=1"
fi

echo LIBRARY_PATH $LIBRARY_PATH
echo LD_LIBRARY_PATH $LD_LIBRARY_PATH
echo CMAKE_PREFIX_PATH $CMAKE_PREFIX_PATH

echo cmake --version
cmake --version
echo g++ --version
g++ --version

# begin building...
rm -rf ${build_path} 2>/dev/null
mkdir ${build_path}
cd ${build_path}
cmake ${cmake_defs} ..
make -j `nproc` 2>err.log

make install
echo REPO: ${REPO}
echo CASCADE_BRANCH: ${CASCADE_BRANCH}

cd src/applications/demos/dairy_farm
bash extract_model.sh
