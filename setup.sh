#!/bin/sh

LF=src/lib/lf
git clone https://github.com/NikolaiResokav/LoveFrames.git $LF
cd $LF
git checkout 9aaf07f66ff6ca74dbf709b65ea748246dfd0364 # 0.9.6.4 Alpha
rm -rf .git
cd -

LFGT=$LF/skins/Gray
git clone https://github.com/unek/loveframes-gray-theme.git $LFGT
cd $LFGT
git checkout 578b5948d0ad2ea8da1d317362d40681b73bacb8
ls -lah $LF/
rm -rf .git
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
