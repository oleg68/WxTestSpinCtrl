#!/bin/bash

# $1 - Go source Dir. If not set then relative to the script dir

set -e

DIR=$(readlink -f $(dirname $0))

if [[ -n "$1" ]]; then
	SRC_DIR=$1
else
	SRC_DIR=$(readlink -f $(dirname $0)/../..)
fi

PARALLEL_PRMS="-j$(nproc)"

mkdir -p build/linux
pushd build/linux

rm -rf *
export LANG=C

CMAKE_VERSION_PRMS="-DVERSION=1.0.0"
GO_PRMS="-DCMAKE_BUILD_TYPE=Release $CMAKE_VERSION_PRMS"

# a workaround of the new dpkg-shlibdeps that prevents cpack from making the DEB package
if ! dpkg-shlibdeps --help 1>/dev/null; then
  echo "set(IGNORE_MISSING_INFO_FLAG --ignore-missing-info)" >CPackSpkgShlibdeps.cmake
  GO_PRMS="$GO_PRMS -DCPACK_PROPERTIES_FILE=$(readlink -f CPackSpkgShlibdeps.cmake)"
fi

echo "cmake -G \"Unix Makefiles\" $GO_PRMS . $SRC_DIR"
cmake -G "Unix Makefiles" $GO_PRMS . $SRC_DIR
make -k $PARALLEL_PRMS VERBOSE=1 package

# generate source rpm
cpack -G RPM --config ./CPackSourceConfig.cmake

popd
