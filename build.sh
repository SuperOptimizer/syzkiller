#!/bin/bash
# build.sh
set -eux

export PATH=/usr/local/go/bin:$PATH

SANITIZER="nosan"
KERNEL_DIR="linux"

usage() {
    echo "Usage: $0 [--sanitizer TYPE]"
    echo "Sanitizer types: kasan, kcsan, kmsan, nosan, ubsan"
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

    if [ -d "$KERNEL_DIR" ]; then
        cd "$KERNEL_DIR"
        git pull
    else
        echo "Error: Linux kernel directory not found. Run install.sh first."
        exit 1
    fi

    make mrproper
    cp "/syzkiller/${SANITIZER}.config" .config
    make olddefconfig
    make -j$(nproc)
}

build_syzkaller() {
    cd /syzkiller/syzkaller
    git pull
    make
}

setup_kernel
build_syzkaller
cd /syzkiller/workdir
echo "Manager started"