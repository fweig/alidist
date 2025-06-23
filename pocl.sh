package: PoCL
version: "v7.0"
tag: "release_7_0"
source: https://github.com/pocl/pocl
requires:
  - Clang
build_requires:
  - "GCC-Toolchain:(?!osx)"
  - CMake
  - Clang
  - ninja
env:
  LLVM_ROOT: "$CLANG_ROOT" # needed by LLVMAlt
---
#!/bin/bash -e

cmake "$SOURCEDIR" \
    -G Ninja \
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_LLVM_CONFIG="$CLANG_ROOT/bin/llvm-config" \
    -DENABLE_CONFORMANCE=0 \
    -DLLVM_ALL_TARGETS=X86 \
    -DSTATIC_LLVM=ON

cmake --build . -- ${JOBS:+-j$JOBS} install

mkdir -p etc/modulefiles
cat > "etc/modulefiles/$PKGNAME" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0                                                          \\
            ${GCC_TOOLCHAIN_REVISION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
set POCL_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv POCL_ROOT \$POCL_ROOT
prepend-path LD_LIBRARY_PATH \$POCL_ROOT/lib64
EoF
mkdir -p "$INSTALLROOT/etc/modulefiles"
rsync -a --delete etc/modulefiles/ "$INSTALLROOT/etc/modulefiles"
