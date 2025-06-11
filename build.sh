#!/bin/bash
set -x
export PATH=/usr/local/go/bin:$PATH

cd /syzkiller
rm -rf linux
rm -rf syzkaller

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git clone --depth 1 https://github.com/google/syzkaller

CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-kasan-badwrites.config"

EXTRA_CONFIG="

CONFIG_UBSAN=y
CONFIG_UBSAN_ALIGNMENT=y
CONFIG_UBSAN_BOOL=y
CONFIG_UBSAN_BOUNDS=y
CONFIG_UBSAN_DIV_ZERO=y
CONFIG_UBSAN_ENUM=y
CONFIG_UBSAN_LOCAL_BOUNDS=y
CONFIG_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN_SHIFT=y
CONFIG_UBSAN_SIGNED_WRAP=y
CONFIG_UBSAN_TRAP=y
CONFIG_UBSAN_UNREACHABLE=y
CONFIG_LTO_CLANG_THIN=y

"


cd /syzkiller/linux
cp "$CONFIG_FILE" .config
echo "$EXTRA_CONFIG" >> .config
make olddefconfig LLVM=1
make -j$(nproc) LLVM=1

cd /syzkiller/syzkaller
git pull
make
