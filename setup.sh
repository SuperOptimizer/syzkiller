#!/bin/bash
set -eux

MODE="manager"
SANITIZER="nosan"
GO_VERSION="1.21.5"
KERNEL_VERSION="6.13"

usage() {
    echo "Usage:"
    echo "  Hub:     $0 --mode hub"
    echo "  Manager: $0 --mode manager [--sanitizer TYPE]"
    echo "  Sanitizer types: kasan, kcsan, kmsan, nosan, ubsan"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --sanitizer)
            SANITIZER="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [ "$MODE" != "hub" ] && [ "$MODE" != "manager" ]; then
    usage
fi

setup_common() {
    apt-get update
    apt-get install -y git curl make gcc wget

    wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    rm -rf /usr/local/go
    tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"

    export PATH=/usr/local/go/bin:$PATH

    apt-get install -y clang lld

    apt-get install -y flex bison libelf-dev libssl-dev pkg-config

    cd /syzkiller

    git clone https://github.com/google/syzkaller
    cd syzkaller
    make
}

setup_kernel() {
    cd /syzkiller

    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
    tar xf "linux-${KERNEL_VERSION}.tar.xz"
    cd "linux-${KERNEL_VERSION}"

    cp "/syzkiller/${SANITIZER}.config" .config

    if [ "$SANITIZER" = "kmsan" ]; then
        make olddefconfig CC=clang LD=ld.lld
        make -j$(nproc) CC=clang LD=ld.lld
    else
        make olddefconfig
        make -j$(nproc)
    fi
}

if [ "$MODE" = "hub" ]; then
    setup_common
    cd /syzkiller
    #screen -dmS syzhub ./syzkaller/bin/syz-hub -config hub.cfg
    #echo "Hub started in screen session 'syzhub'"
else
    setup_common
    setup_kernel
    cd /syzkiller
    ./create-image.sh
    #screen -dmS syzmanager ./syzkaller/bin/syz-manager -config "manager_${SANITIZER}.cfg"
    #echo "Manager started in screen session 'syzmanager'"
fi