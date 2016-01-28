#!/bin/sh

REV=`cat graal.revision`

echo ""
echo %% Make sure git submodules are up-to-date
echo ""
git submodule update --init --recursive

if [ ! -d "graal-compiler" ]; then
  echo ""
  echo %% Clone Graal Compiler
  echo ""
  hg clone http://lafo.ssw.uni-linz.ac.at/hg/graal-compiler/
fi

if [ -d "truffle" ]; then
  cd truffle
  ../mx/mx clean
  cd ..
fi

if [ -d "jvmci" ]; then
  cd jvmci
  ../mx/mx clean
  cd ..
fi

cd graal-compiler
hg pull
hg update -r $REV
../mx/mx sforceimports

echo ""
echo %% Build Graal Compiler
echo ""
../mx/mx --vm server clean
../mx/mx --vm server build

