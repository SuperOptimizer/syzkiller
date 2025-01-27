#!/bin/bash
set -eux

SANITIZER="nosan"
KERNEL_VERSION="6.13"

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
    KERNEL_TAR="linux-${KERNEL_VERSION}.tar.xz"
    KERNEL_DIR="linux-${KERNEL_VERSION}"

    # Download kernel only if tar doesn't exist
    if [ ! -f "$KERNEL_TAR" ]; then
        wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/$KERNEL_TAR"
    fi

    # Remove existing kernel directory if it exists
    if [ -d "$KERNEL_DIR" ]; then
        rm -rf "$KERNEL_DIR"
    fi

    # Extract fresh copy
    tar xf "$KERNEL_TAR"
    cd "$KERNEL_DIR"
    cp "/syzkiller/${SANITIZER}.config" .config

    make olddefconfig
    make -j$(nproc)

}

setup_kernel
cd /syzkiller
cd workdir
#nohup syzmanager ./syzkaller/bin/syz-manager -config "manager_${SANITIZER}.cfg" &> out_manager.txt &
echo "Manager started"