#!/bin/sh
set -e

FFMPEG_KIT_TAG="v5.1"
FFMPEG_KIT_CHECKOUT="origin/main"
#FFMPEG_KIT_CHECKOUT="origin/tags/$FFMPEG_KIT_TAG"

FFMPEG_KIT_REPO="https://github.com/arthenica/ffmpeg-kit"
WORK_DIR=".tmp/ffmpeg-kit"

if [[ ! -d $WORK_DIR ]]; then
  echo "Cloning ffmpeg-kit repository..."
  mkdir .tmp/ || true
  cd .tmp/
  git clone $FFMPEG_KIT_REPO
  cd ../
fi

echo "Checking out $FFMPEG_KIT_CHECKOUT..."
cd $WORK_DIR
git fetch --tags
git checkout $FFMPEG_KIT_CHECKOUT

echo "Install build dependencies..."
brew install autoconf automake libtool pkg-config curl git doxygen nasm bison wget gettext

echo "Building for iOS..."
./ios.sh --enable-ios-audiotoolbox --enable-ios-avfoundation --enable-ios-videotoolbox --enable-ios-zlib --enable-ios-bzip2 --no-bitcode --enable-gmp --enable-gnutls -x
echo "Building for tvOS..."
./tvos.sh --enable-tvos-audiotoolbox --enable-tvos-videotoolbox --enable-tvos-zlib --enable-tvos-bzip2 --no-bitcode --enable-gmp --enable-gnutls -x
echo "Building for macOS..."
./macos.sh --enable-macos-audiotoolbox --enable-macos-avfoundation --enable-macos-bzip2 --enable-macos-videotoolbox --enable-macos-zlib --enable-macos-coreimage --enable-macos-opencl --enable-macos-opengl --enable-gmp --enable-gnutls -x

echo "Bundling final XCFramework"
./apple.sh

cd ../../

echo "Updating package file..."
PACKAGE_STRING=""
sed -i '' -e "s/let release =.*/let release = \"$FFMPEG_KIT_TAG\"/" Package.swift

XCFRAMEWORK_DIR="$WORK_DIR/prebuilt/bundle-apple-xcframework"

rm -rf $XCFRAMEWORK_DIR/*.zip

for f in $(ls "$XCFRAMEWORK_DIR")
do
    echo "Adding $f to package list..."
    PACAKGE="$XCFRAMEWORK_DIR/$f"
    zip -r "$PACAKGE.zip" $PACAKGE
    PACKAGE_NAME=$(basename "$f" .xcframework)
    PACKAGE_SUM=$(sha256sum "$PACAKGE.zip" | awk '{ print $1 }')
    PACKAGE_STRING="$PACKAGE_STRING\"$PACKAGE_NAME\": \"$PACKAGE_SUM\", "
done

PACKAGE_STRING=$(basename "$PACKAGE_STRING" ", ")
sed -i '' -e "s/let frameworks =.*/let frameworks = [$PACKAGE_STRING]/" Package.swift
