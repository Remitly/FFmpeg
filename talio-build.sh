#!/bin/bash

# set the base path to your Android NDK (or export NDK to environment)
if [[ "x$NDK_BASE" == "x" ]]; then
    NDK_BASE=/opt/android-ndk
    echo "No NDK_BASE set, using $NDK_BASE"
fi

# Android now has 64-bit and 32-bit versions of the NDK for GNU/Linux.  We
# assume that the build platform uses the appropriate version, otherwise the
# user building this will have to manually set NDK_PROCESSOR or NDK_TOOLCHAIN.
if [ $(uname -m) = "x86_64" ]; then
    NDK_PROCESSOR=x86_64
else
    NDK_PROCESSOR=x86
fi

# Android NDK setup
NDK_PLATFORM_LEVEL=16
NDK_ABI=arm
NDK_COMPILER_VERSION=4.6
NDK_SYSROOT=$NDK_BASE/platforms/android-$NDK_PLATFORM_LEVEL/arch-$NDK_ABI
NDK_UNAME=`uname -s | tr '[A-Z]' '[a-z]'`
if [ $NDK_ABI = "x86" ]; then
    HOST=i686-linux-android
    NDK_TOOLCHAIN=$NDK_ABI-$NDK_COMPILER_VERSION
else
    HOST=$NDK_ABI-linux-androideabi
    NDK_TOOLCHAIN=$HOST-$NDK_COMPILER_VERSION
fi
NDK_TOOLCHAIN_BASE=$NDK_BASE/toolchains/$NDK_TOOLCHAIN/prebuilt/$NDK_UNAME-$NDK_PROCESSOR

CC="$NDK_TOOLCHAIN_BASE/bin/$HOST-gcc --sysroot=$NDK_SYSROOT"
LD=$NDK_TOOLCHAIN_BASE/bin/$HOST-ld
STRIP=$NDK_TOOLCHAIN_BASE/bin/$HOST-strip

# Configure ffmpeg for Talio
./configure \
$DEBUG_FLAG \
--arch=arm \
--cpu=cortex-a8 \
--target-os=linux \
--enable-runtime-cpudetect \
--prefix=$prefix \
--enable-pic \
--disable-shared \
--enable-static \
--cross-prefix=$NDK_TOOLCHAIN_BASE/bin/$NDK_ABI-linux-androideabi- \
--sysroot="$NDK_SYSROOT" \
--extra-cflags="-I../x264 -mfloat-abi=softfp -mfpu=neon -fPIE" \
--extra-ldflags="-L../x264 -fPIE -pie" \
\
--enable-gpl \
\
--disable-doc \
--enable-yasm \
\
--disable-decoders \
--enable-decoder=rawvideo \
--enable-decoder=mpeg4 \
--enable-decoder=h264 \
\
--disable-encoders \
--enable-encoder=mjpeg \
--enable-encoder=mpeg4 \
--enable-encoder=libx264 \
\
--disable-muxers \
--enable-muxer=image2 \
--enable-muxer=rawvideo \
--enable-muxer=mp4 \
\
--disable-demuxers \
--enable-demuxer=image2 \
--enable-demuxer=rawvideo \
--enable-demuxer=h264 \
--enable-demuxer=mov \
\
--disable-filters \
--enable-filter=transpose \
--enable-filter=vflip \
--enable-filter=hflip \
\
--disable-protocols \
--enable-protocol=file \
\
--disable-indevs \
--enable-indev=lavfi \
\
--disable-outdevs \
--disable-bsfs \
--disable-parsers \
\
--enable-hwaccels \
\
--enable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--disable-network \
\
--enable-libx264 \
--enable-zlib \
--enable-muxer=md5

# build ffmpeg
make -j4

