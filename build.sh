#!/bin/bash

SRC="src"
NAME="vapor"
VERSION=0.8.0

GIT=`sh ./distgit.sh $SRC`

# cleanup!
./clean.sh 2> /dev/null

# *.love
cd $SRC
zip -r ../${NAME}_${GIT}.love *
cd ..

# Temp Space
mkdir tmp

# Windows 32 bit
cat dev/build_data/love-$VERSION\-win-x86/love.exe ${NAME}_${GIT}.love > tmp/${NAME}_${GIT}.exe
cp dev/build_data/love-$VERSION\-win-x86/*.dll tmp/
cd tmp
zip -r ../${NAME}_win-x86[$GIT].zip *
cd ..
rm tmp/* -rf #tmp cleanup

# Windows 64 bit
cat dev/build_data/love-$VERSION\-win-x64/love.exe ${NAME}_${GIT}.love > tmp/${NAME}_${GIT}.exe
cp dev/build_data/love-$VERSION\-win-x64/*.dll tmp/
cd tmp
zip -r ../${NAME}_win-x64[$GIT].zip *
cd ..
rm tmp/* -rf #tmp cleanup

# OS X
cp dev/build_data/love.app tmp/${NAME}_${GIT}.app -Rv
cp ${NAME}_${GIT}.love tmp/${NAME}_${GIT}.app/Contents/Resources/
patch tmp/${NAME}_${GIT}.app/Contents/Info.plist -i dev/build_data/osx.patch
cd tmp
zip -r ../${NAME}_macosx[$GIT].zip ${NAME}_${GIT}.app
cd ..
rm tmp/* -rf #tmp cleanup

# Cleanup
rm tmp -rf
