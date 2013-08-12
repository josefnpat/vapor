#!/bin/sh

LF=src/lib/loveframes
git clone --depth 1 https://github.com/NikolaiResokav/LoveFrames.git $LF
cd $LF
git checkout a095495209baa385145a7eb8a730a9ae163ac6d1 # 0.9.6.1 Alpha
cd -

LFGT=$LF/skins/gray
git clone --depth 1 https://github.com/UnekPL/loveframes-gray-theme.git $LFGT
cd $LFGT
git checkout 9430d22020b9d0cb71f82c098e676eb5596e8b17
cd -

