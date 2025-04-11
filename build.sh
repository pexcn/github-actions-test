#!/bin/bash
# shellcheck disable=SC1090,SC2086,SC2164,SC2103,SC2155

prepare_env() {
  mkdir -p build
  mkdir -p download

  # updatable part
  #CLANG_URL=https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r530567.tar.gz
  CLANG_URL=https://github.com/ZyCromerZ/Clang/releases/download/21.0.0git-20250411-release/Clang-21.0.0git-20250411.tar.gz
  AK3_VERSION=db90e19aae369c9c10b956a08003cee3958d50a0

  # set local shell variables
  source config/$DEVICE_CODENAME/$BUILD_CONFIG/conf
  CUR_DIR=$(dirname "$(readlink -f "$0")")
  MAKE_FLAGS=(
    O=out
    ARCH=arm64
    SUBARCH=arm64
    CLANG_TRIPLE=aarch64-linux-gnu-
    CROSS_COMPILE=aarch64-linux-android-
    CROSS_COMPILE_ARM32=arm-linux-androideabi-
    CROSS_COMPILE_COMPAT=arm-linux-androideabi-
    CC="ccache clang"
    LD=ld.lld
    AS=llvm-as
    AR=llvm-ar
    NM=llvm-nm
    OBJCOPY=llvm-objcopy
    OBJDUMP=llvm-objdump
    READELF=llvm-readelf
    OBJSIZE=llvm-size
    STRIP=llvm-strip
    LLVM=1
    LLVM_IAS=1
    LLVM_AR=llvm-ar
    LLVM_NM=llvm-nm
  )

  # setup clang
  local clang_pack="$(basename $CLANG_URL)"
  [ -f download/$clang_pack ] || wget -q $CLANG_URL -P download
  mkdir build/clang && tar -C build/clang/ -zxf download/$clang_pack

  # set environment variables
  export PATH=$CUR_DIR/build/clang/bin:$PATH
  export ARCH=arm64
  export SUBARCH=arm64
  export KBUILD_BUILD_USER=${GITHUB_REPOSITORY_OWNER:-pexcn}
  export KBUILD_BUILD_HOST=buildbot
  export KBUILD_COMPILER_STRING="$(clang --version | head -1 | sed 's/ (https.*//')"
  export KBUILD_LINKER_STRING="$(ld.lld --version | head -1 | sed 's/ (compatible.*//')"
}

get_sources() {
  [ -d build/kernel/.git ] || git clone $KERNEL_SOURCE --recurse-submodules build/kernel
  cd build/kernel
  git diff --quiet HEAD || {
    git reset --hard HEAD
    git pull origin "$(git for-each-ref --format '%(refname:lstrip=2)' refs/heads | head -1)"
    git submodule update --init --recursive
  }

  # checkout version
  git checkout $KERNEL_COMMIT || exit 1

  # remove `-dirty` of version
  sed -i 's/ -dirty//g' scripts/setlocalversion

  cd -
}

patch_kernel() {
  [ -d config/$DEVICE_CODENAME/$BUILD_CONFIG/patches ] || return 0

  cd build/kernel
  for patch in "$CUR_DIR"/config/"$DEVICE_CODENAME"/"$BUILD_CONFIG"/patches/*.patch; do
    echo "Applying $(basename $patch)."
    git apply $patch || exit 2
  done
  cd -
}

add_kernelsu() {
  [ "$DONT_PATCH_KERNELSU" != true ] || return 0

  cd build/kernel

  # integrate kernelsu-next
  curl -sSL "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s v1.0.6

  # prepare .config
  make "${MAKE_FLAGS[@]}" $KERNEL_CONFIG

  # update .config
  scripts/config --file out/.config \
    --enable CONFIG_KSU \
    --disable CONFIG_KSU_WITH_KPROBES

  # re-generate kernel config
  make "${MAKE_FLAGS[@]}" savedefconfig
  cp -f out/defconfig arch/arm64/configs/${KERNEL_CONFIG%% *}

  cd -
}

optimize_config() {
  [ "$DISABLE_OPTIMIZE" != true ] || return 0

  cd build/kernel

  # prepare .config
  make "${MAKE_FLAGS[@]}" $KERNEL_CONFIG

  ## build `Image*-dtb`
  #scripts/config --file out/.config \
  #  --enable CONFIG_BUILD_ARM64_APPENDED_DTB_IMAGE \
  #  --enable CONFIG_BUILD_ARM64_DT_OVERLAY

  scripts/config --file out/.config \
    --enable CONFIG_BUILD_ARM64_DT_OVERLAY

  # re-generate kernel config
  make "${MAKE_FLAGS[@]}" savedefconfig
  cp -f out/defconfig arch/arm64/configs/${KERNEL_CONFIG%% *}

  cd -
}

build_kernel() {
  cd build/kernel

  # select kernel config
  make "${MAKE_FLAGS[@]}" $KERNEL_CONFIG
  # compile kernel
  make "${MAKE_FLAGS[@]}" -j$(($(nproc) + 1)) || exit 3

  #find out/arch/arm64/boot/dts -name '*.dtb' -exec cat {} + >out/arch/arm64/boot/dtb

  cd -
}

package_kernel() {
  git clone https://github.com/osm0sis/AnyKernel3.git -b master --single-branch build/anykernel3
  cd build/anykernel3
  git checkout $AK3_VERSION

  # update properties
  sed -i "s/ExampleKernel/\u${BUILD_CONFIG} Kernel for ${GITHUB_WORKFLOW}/; s/by osm0sis @ xda-developers/by ${GITHUB_REPOSITORY_OWNER:-pexcn} @ GitHub/" anykernel.sh
  [ "$DISABLE_DEVICE_CHECK" != true ] || sed -i 's/do.devicecheck=1/do.devicecheck=0/g' anykernel.sh
  sed -i '/device.name[1-4]/d' anykernel.sh
  sed -i 's/device.name5=/device.name1='"$DEVICE_CODENAME"'/g' anykernel.sh
  sed -i 's|BLOCK=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;|BLOCK=auto;|g' anykernel.sh
  sed -i 's/IS_SLOT_DEVICE=0;/IS_SLOT_DEVICE=auto;/g' anykernel.sh

  # clean folder
  rm -rf .git .github modules patch ramdisk LICENSE README.md
  find . -name "placeholder" -delete

  # packaging
  if ! cp $CUR_DIR/build/kernel/out/arch/arm64/boot/Image*-dtb .; then
    cp $CUR_DIR/build/kernel/out/arch/arm64/boot/Image .
    cp $CUR_DIR/build/kernel/out/arch/arm64/boot/dtb .
  fi
  [ ! -f $CUR_DIR/build/kernel/out/arch/arm64/boot/dtbo.img ] || cp $CUR_DIR/build/kernel/out/arch/arm64/boot/dtbo.img .
  zip -r $CUR_DIR/build/$DEVICE_CODENAME-$BUILD_CONFIG-kernel.zip ./*

  cd -
}

prepare_env
get_sources
patch_kernel
add_kernelsu
optimize_config
build_kernel
package_kernel
