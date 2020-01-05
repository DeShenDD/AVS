#/bin/bash

set -x
set -e

RootDir=$(dirname $(readlink -f "$0"))
ProjectDir=$RootDir"/project"
echo $ProjectDir

mkdir -p $ProjectDir"/sound"
mkdir -p $ProjectDir"/thirdLib"
mkdir -p $ProjectDir"/lib"
mkdir -p $ProjectDir"/bin"
mkdir -p $ProjectDir"/build"

sudo apt-get install -y git gcc cmake openssl clang-format libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev  gstreamer1.0-libav pulseaudio doxygen libsqlite3-dev repo libasound2-dev

cd $ProjectDir"/sound"
soundLib="pa_stable_v190600_20161030.tgz"
if [ -f "$soundLib" ]
then
echo $soundLib" exist"
tar -zxvf $soundLib
else
echo $soundLib" not exist"
wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz
tar -zxvf $soundLib
fi

cd $ProjectDir"/sound/portaudio" || exit 1
./configure --with-jack && make -j2 > /dev/null >&1


cd $RootDir"/src" || exit 1
srcZip="avs-device-sdk-master.zip"
if [ -f "$srcZip" ]
then
cd $RootDir"/src/avs-device-sdk-master" || unzip $srcZip
else
cd $RootDir"/src/avs-device-sdk-master" || \
echo "Please download code source file first."
fi

cd $ProjectDir/build || exit 1
cmake $RootDir/src/avs-device-sdk-master -DGSTREAMER_MEDIA_PLAYER=ON -DPORTAUDIO=ON -DPORTAUDIO_LIB_PATH=$ProjectDir/sound/portaudio/lib/.libs/libportaudio.a -DPORTAUDIO_INCLUDE_DIR=$ProjectDir/sound/portaudio/include  -DCMAKE_BUILD_TYPE=DEBUG

make -j2
 
libFile=$(find $ProjectDir/build -name "*.so")
#echo $libFile
if [ "$libFile"!="" ]
then
cp $libFile $ProjectDir/lib
else
echo "Can't find any so files."
fi

exeFile=$(find $ProjectDir/build -name "SampleApp")
echo $exeFile
cp  $exeFile $ProjectDir/bin/SampleApp
