#!/bin/sh

GIT=`git log --pretty=format:'%h' -n 1 $1`
GIT_COUNT=`git log --pretty=format:'' $1 | wc -l`

echo "git,git_count = '${GIT}','${GIT_COUNT}'" > $1/git.lua

echo $GIT