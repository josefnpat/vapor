#!/bin/sh

LF=src/lib/lf
git clone --depth 1 https://github.com/NikolaiResokav/LoveFrames.git $LF
cd $LF
git checkout 9aaf07f66ff6ca74dbf709b65ea748246dfd0364 # 0.9.6.4 Alpha
cd -

LFGT=$LF/skins/Gray
# Switch back to Uneks repo when this merge is resolved
git clone --depth 1 https://github.com/josefnpat/loveframes-gray-theme.git $LFGT
cd $LFGT
git checkout 54ab5293d949cea3c852235297bee158059f4b1d
cd -

# Download binaries, and unpack

cd dev/build_data
VERSION=0.8.0

# windows 32 bit
wget -t 2 -c https://bitbucket.org/rude/love/downloads/love-$VERSION\-win-x86.zip
unzip love-$VERSION\-win-x86.zip

# windows 64 bit
wget -t 2 -c https://bitbucket.org/rude/love/downloads/love-$VERSION\-win-x64.zip
unzip love-$VERSION\-win-x64.zip

# os x universal
wget -t 2 -c https://bitbucket.org/rude/love/downloads/love-$VERSION\-macosx-ub.zip
unzip love-$VERSION\-macosx-ub.zip
