#!/bin/sh
# Love doesn't like symlinks! Oh noes!
SRC="src"

sh ./distgit.sh $SRC

# *.love
cd $SRC

TEMPFILE="._temp.love"
echo "Updating '$TEMPFILE' ..."
zip --filesync -r ../$TEMPFILE *
cd ..
love $TEMPFILE
