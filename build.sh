#!/bin/sh
set -e

FFMPEG_KIT_TAG="min.v5.1.2.5"
FFMPEG_KIT_CHECKOUT="origin/develop"
#FFMPEG_KIT_CHECKOUT="origin/tags/$FFMPEG_KIT_TAG"

FFMPEG_KIT_REPO="https://github.com/tylerjonesio/ffmpeg-kit"
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
git fetch
git fetch --tags
git checkout $FFMPEG_KIT_CHECKOUT

echo "Install build dependencies..."
brew install autoconf automake libtool pkg-config curl git doxygen nasm bison wget gettext gh

echo "Building for iOS..."
#./ios.sh --enable-ios-audiotoolbox --enable-ios-avfoundation --enable-ios-videotoolbox --enable-ios-zlib --enable-ios-bzip2 --no-bitcode --enable-gmp --enable-gnutls -x
#echo "Building for tvOS..."
#./tvos.sh --enable-tvos-audiotoolbox --enable-tvos-videotoolbox --enable-tvos-zlib --enable-tvos-bzip2 --no-bitcode --enable-gmp --enable-gnutls -x
#echo "Building for macOS..."
#./macos.sh --enable-macos-audiotoolbox --enable-macos-avfoundation --enable-macos-bzip2 --enable-macos-videotoolbox --enable-macos-zlib --enable-macos-coreimage --enable-macos-opencl --enable-macos-opengl --enable-gmp --enable-gnutls -x
#echo "Building for watchOS..."
##./watchos.sh --enable-watchos-zlib --enable-watchos-bzip2 --no-bitcode --enable-gmp --enable-gnutls -x
#
#echo "Bundling final XCFramework"
#./apple.sh --disable-watchos --disable-watchsimulator

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
    ditto -c -k --sequesterRsrc --keepParent $PACAKGE "$PACAKGE.zip"
    PACKAGE_NAME=$(basename "$f" .xcframework)
    PACKAGE_SUM=$(sha256sum "$PACAKGE.zip" | awk '{ print $1 }')
    PACKAGE_STRING="$PACKAGE_STRING\"$PACKAGE_NAME\": \"$PACKAGE_SUM\", "
done

PACKAGE_STRING=$(basename "$PACKAGE_STRING" ", ")
sed -i '' -e "s/let frameworks =.*/let frameworks = [$PACKAGE_STRING]/" Package.swift

echo "Copying License..."
cp -f .tmp/ffmpeg-kit/LICENSE ./

echo "Committing Changes..."
git add -u
git commit -m "Creating release for $FFMPEG_KIT_TAG"

echo "Creating Tag..."
git tag $FFMPEG_KIT_TAG
git push origin --tags

echo "Creating Release..."
gh release create -p -d $FFMPEG_KIT_TAG -t "FFmpegKit SPM $FFMPEG_KIT_TAG" --generate-notes --verify-tag

echo "Uploading Binaries..."
for f in $(ls "$XCFRAMEWORK_DIR")
do
    if [[ $f == *.zip ]]; then
        gh release upload $FFMPEG_KIT_TAG "$XCFRAMEWORK_DIR/$f"
    fi
done

gh release edit $FFMPEG_KIT_TAG --draft=false

echo "All done!"
