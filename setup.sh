#!/bin/sh

LOC=src/lib/loveframes
git clone --depth 1 https://github.com/NikolaiResokav/LoveFrames.git $LOC
cd $LOC
git checkout a095495209baa385145a7eb8a730a9ae163ac6d1 # 0.9.6.1 Alpha
cd -

git clone --depth 1 https://github.com/UnekPL/loveframes-gray-theme.git $LOC/skins/gray
