#!/bin/sh

LOC=src/lib/loveframes
git clone --depth 1 https://github.com/NikolaiResokav/LoveFrames.git $LOC
cd $LOC
git checkout 6947e97cc56d1b1f0a6defe769562f965720bdba
cd -
patch -p1 $LOC/objects/columnlist.lua < dev/loveframes.patch