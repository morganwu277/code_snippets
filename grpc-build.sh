#!/bin/bash

# this file is a reference from https://github.com/grpc/grpc/blob/master/test/distrib/cpp/run_distrib_test_cmake.sh
# but has changes for my own

set -ex

cd "$(dirname "$0")/../../.."

# Install openssl (to use instead of boringssl)
apt-get update && apt-get install -y libssl-dev

# Install absl
mkdir -p "third_party/abseil-cpp/cmake/build"
cd "third_party/abseil-cpp/cmake/build"
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE -DCMAKE_INSTALL_PREFIX=/usr ../..
make -j4 install
cd -

# Install c-ares
# If the distribution provides a new-enough version of c-ares,
# this section can be replaced with:
# apt-get install -y libc-ares-dev
mkdir -p "third_party/cares/cares/cmake/build"
cd "third_party/cares/cares/cmake/build"
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ../..
make -j4 install
cd -

# Install protobuf
mkdir -p "third_party/protobuf/cmake/build"
cd "third_party/protobuf/cmake/build"
# why we need CMAKE_POSITION_INDEPENDENT_CODE?
# if don't, we could meet issue here https://tecnocode.co.uk/2014/10/01/dynamic-relocs-runtime-overflows-and-fpic/ 
# the solution is to add `-fPIC` build option, in cmake it's `-DCMAKE_POSITION_INDEPENDENT_CODE=ON`
# see comment here: https://github.com/protocolbuffers/protobuf/issues/1919#issuecomment-238940580
cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_POSITION_INDEPENDENT_CODE=ON ..
make -j4 install
cd -

# Install zlib
mkdir -p "third_party/zlib/cmake/build"
cd "third_party/zlib/cmake/build"
cmake -DCMAKE_BUILD_TYPE=Release ../..
make -j4 install
cd -

# Just before installing gRPC, wipe out contents of all the submodules to simulate
# a standalone build from an archive
# shellcheck disable=SC2016
git submodule foreach 'cd $toplevel; rm -rf $name'

# Install gRPC
mkdir -p "cmake/build"
cd "cmake/build"
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_INSTALL=ON \
  -DgRPC_BUILD_TESTS=OFF \
  -DgRPC_CARES_PROVIDER=package \
  -DgRPC_ABSL_PROVIDER=package \
  -DgRPC_PROTOBUF_PROVIDER=package \
  -DgRPC_SSL_PROVIDER=package \
  -DgRPC_ZLIB_PROVIDER=package \
  ../..
make -j4 install
cd -

# Build helloworld example using cmake
mkdir -p "examples/cpp/helloworld/cmake/build"
cd "examples/cpp/helloworld/cmake/build"
cmake ../..
make
cd -
