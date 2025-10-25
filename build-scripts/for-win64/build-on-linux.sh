#!/bin/bash

# $1 - Version
# $2 - Build version
# $3 - Go source Dir. If not set then relative to the script dir

set -e

if [[ -n "$1" ]]; then
	SRC_DIR=$1
else
	SRC_DIR=$(readlink -f $(dirname $0)/../..)
fi

PARALLEL_PRMS="-j$(nproc)"

mkdir -p build/win64
pushd build/win64

rm -rf *
export LANG=C

WX_CONFIG=$MINGW_DIR/bin/wx-config; export WX_CONFIG

CMAKE_VERSION_PRMS="-DVERSION=1.0.0"

CMAKE_WIN_PRMS="-DASIO_SDK_DIR=/usr/local/asio-sdk \
  -DCV2PDB_EXE=/usr/local/share/wine/cv2pdb/cv2pdb.exe \
  -DINSTALL_DEPEND=ON \
  -DMSYS=1 -DSTATIC=1 \
  -DRTAUDIO_USE_ASIO=ON \
  -DVC_PATH=/usr/local/share/wine/msvc/VC/Tools/MSVC/14.29.30133/bin/Hostx86/x86"

cmake $CMAKE_MINGW_PRMS $CMAKE_WIN_PRMS $CMAKE_VERSION_PRMS . $SRC_DIR
make $PARALLEL_PRMS VERBOSE=1 package

popd
