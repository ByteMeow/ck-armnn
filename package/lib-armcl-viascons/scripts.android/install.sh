#!/bin/bash

#
# See CK LICENSE for licensing details.
# See CK COPYRIGHT for copyright details.
#
# Developer(s):
# - Leo Gordon, 2019
#

# for example,
#   INSTALL_DIR     = "lib-armcl-viascons-linux-64"
#   PACKAGE_SUB_DIR = "src"

ARMCL_SOURCE_DIR=$INSTALL_DIR/$PACKAGE_SUB_DIR

############################################################
echo ""
echo "Building ArmCL package in ${INSTALL_DIR} using scons in ${CK_HOST_CPU_NUMBER_OF_PROCESSORS:-UndefinedNumberOf} threads:"
echo "PACKAGE_VERSION='${PACKAGE_VERSION}'"
echo "Backends: USE_NEON='${USE_NEON}' and USE_OPENCL='${USE_OPENCL}'"
echo ""

if [ "$USE_NEON" == "ON" ] || [ "$USE_NEON" == "on" ] || [ "$USE_NEON" == "YES" ] || [ "$USE_NEON" == "yes" ] || [ "$USE_NEON" == "1" ]
then
    ARMCL_SCONS_INTERNAL_NEON="neon=1"
else
    ARMCL_SCONS_INTERNAL_NEON=""
fi

if [ "$USE_OPENCL" == "ON" ] || [ "$USE_OPENCL" == "on" ] || [ "$USE_OPENCL" == "YES" ] || [ "$USE_OPENCL" == "yes" ] || [ "$USE_OPENCL" == "1" ]
then
    ARMCL_SCONS_INTERNAL_OPENCL="opencl=1 embed_kernels=1"
else
    ARMCL_SCONS_INTERNAL_OPENCL=""
fi

if [ "$CK_ANDROID_NDK_ROOT_DIR" != "" ]
then
    $CK_ANDROID_NDK_ROOT_DIR/build/tools/make_standalone_toolchain.py --api 24 --arch arm64 --install-dir ${INSTALL_DIR}/standalone_toolchains/arm64
fi

cd ${ARMCL_SOURCE_DIR}

if [ "$CK_COMPILER_TOOLCHAIN_NAME" == "clang" ]
then 
    CC="clang"
    CXX="clang++"
else
    CC="${CK_CC}"
    CXX="${CK_CXX}"
fi

scons -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS:-1} \
    arch=arm64-v8a \
    extra_cxx_flags="-fPIC" \
    build="cross_compile" \
    os="android" \
    toolchain_prefix="${INSTALL_DIR}/standalone_toolchains/arm64/bin/aarch64-linux-android-" \
    benchmark_tests=0 \
    validation_tests=0 \
    examples=0 \
    ${ARMCL_SCONS_INTERNAL_NEON} ${ARMCL_SCONS_INTERNAL_OPENCL} \
    install_dir=$INSTALL_DIR/install