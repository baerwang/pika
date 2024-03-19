#!/bin/bash

OS=$1
BUILD_TYPE=$2

function install_deps() {
  echo "install deps before ..."
  if [[ $OS == *"centos"* ]]; then
    yum install -y wget git autoconf centos-release-scl gcc
    yum install -y devtoolset-10-gcc devtoolset-10-gcc-c++ devtoolset-10-make devtoolset-10-bin-util
    yum install -y llvm-toolset-7 llvm-toolset-7-clang tcl which
  elif [[ $OS == *"ubuntu"* ]]; then
    apt-get install -y autoconf libprotobuf-dev protobuf-compiler
    apt-get install -y clang-tidy-12
  else
    brew update
    brew install --overwrite python@3.12 autoconf protobuf llvm wget git
    brew install gcc@10 automake cmake make binutils
  fi
  echo "install deps after success ..."
}

function configure_cmake() {
  echo "configure cmake before ..."
  if [[ $OS == *"centos"* ]]; then
    wget https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4-linux-x86_64.sh
    bash ./cmake-3.26.4-linux-x86_64.sh --skip-license --prefix=/usr
  elif [[ $OS == *"ubuntu"* ]]; then
    cmake -B build -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DUSE_PIKA_TOOLS=ON -DCMAKE_CXX_FLAGS="-s" -DCMAKE_EXE_LINKER_FLAGS="-s"
  else
    export CC=/usr/local/opt/gcc@10/bin/gcc-10
    cmake -B build -DCMAKE_C_COMPILER=/usr/local/opt/gcc@10/bin/gcc-10 -DUSE_PIKA_TOOLS=ON -DCMAKE_BUILD_TYPE=$BUILD_TYPE
  fi
  echo "configure cmake after ..."
}

function build() {
  echo "build before ..."
  cmake --build build --config $BUILD_TYPE
  echo "build after success ..."
}

function run() {
  install_deps
  configure_cmake
  build
}

run
