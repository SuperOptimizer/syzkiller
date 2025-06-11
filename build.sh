#!/bin/bash
set -x

CONFIG_FILE="kasan.config"
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

"

# Parse command line arguments
COMPILER="gcc"
while [[ $# -gt 0 ]]; do
    case $1 in
        --compiler)
            COMPILER="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate compiler argument
if [[ "$COMPILER" != "gcc" && "$COMPILER" != "clang" ]]; then
    echo "Error: --compiler must be either 'gcc' or 'clang'"
    exit 1
fi

# Set LLVM flag based on compiler choice
LLVM_FLAG=""
if [[ "$COMPILER" == "clang" ]]; then
    LLVM_FLAG="LLVM=1"
fi

export PATH=/usr/local/go/bin:$PATH
cd /syzkiller
rm -rf linux
git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

cd /syzkiller/linux
cp "$CONFIG_FILE" .config
echo "$EXTRA_CONFIG" >> .config
make olddefconfig $LLVM_FLAG
make -j$(nproc) $LLVM_FLAG


rm -rf syzkaller
git clone --depth 1 https://github.com/google/syzkaller
cd /syzkiller/syzkaller
git pull
make all kconf
