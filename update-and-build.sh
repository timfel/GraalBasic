#!/bin/sh
# usage: update-and-build.sh [hg-id]

./update-graal-revision.sh "$1"
GRAAL_DIR=`pwd`

echo
echo Push to GraalBasic repository
git push
HG_ID=`cat graal.revision`

echo 
echo Update and Push SOMns
cd ../SOMns/
./.graal-git-rev
git commit -m "Update graal to ${HG_ID}" .graal-git-rev
git push

echo 
echo Update and Push TruffleSOM
cd ../TruffleSOM
cp $GRAAL_DIR/../SOMns/.graal-git-rev .
git commit -m "Update graal to ${HG_ID}" .graal-git-rev
git push
