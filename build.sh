#!/bin/bash
set -x
export PATH=/usr/local/go/bin:$PATH
SANITIZER="kasan"
KERNEL_DIR="linux"

usage() {
    echo "Usage: $0 [--sanitizer TYPE]"
    echo "Sanitizer types: kasan, kcsan, kmsan, lsan"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --sanitizer)
            SANITIZER="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

setup_kernel() {
    cd /syzkiller
    rm -rf linux
    rm -rf syzkaller

    git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    git clone --depth 1 https://github.com/google/syzkaller
    
    # Determine which config file to use and extra config lines based on SANITIZER
    CONFIG_FILE=""
    EXTRA_CONFIG=""
    case "$SANITIZER" in
        kasan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-smack-kasan.config"
            EXTRA_CONFIG=""
            ;;
        kcsan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-kcsan.config"
            EXTRA_CONFIG=""
            ;;
        kmsan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-kmsan.config"
            EXTRA_CONFIG=""
            ;;
        ubsan)
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
CONFIG_KASAN=n
"
            ;;
        *)
            echo "Error: Unknown sanitizer type: $SANITIZER"
            exit 1
            ;;
    esac
    cd /syzkiller/linux
    cp "$CONFIG_FILE" .config
    if [ -n "$EXTRA_CONFIG" ]; then
        echo "Appending additional configuration..."
        echo "$EXTRA_CONFIG" >> .config
    fi
    make olddefconfig LLVM=1
    make -j$(nproc) LLVM=1
}

build_syzkaller() {
    cd /syzkiller/syzkaller
    git pull
    make
}

setup_kernel
build_syzkaller
#cd /syzkiller/workdir
#echo "Manager started"