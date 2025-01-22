#!/bin/bash
set -eux

MODE=""
HUB_ADDR=""
MANAGER_NAME=""
MANAGER_KEY=""
KERNEL_VERSION="6.1"
SANITIZER="kasan"
GO_VERSION="1.21.5"

usage() {
    echo "Usage:"
    echo "  Hub:     $0 --mode hub"
    echo "  Manager: $0 --mode manager --hub-addr IP:PORT --name NAME --key KEY [--sanitizer TYPE]"
    echo "  Sanitizer types: kasan, kcsan, kmsan, nosan, ubsan"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --hub-addr)
            HUB_ADDR="$2"
            shift 2
            ;;
        --name)
            MANAGER_NAME="$2"
            shift 2
            ;;
        --key)
            MANAGER_KEY="$2"
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

if [ "$MODE" = "manager" ] && { [ -z "$HUB_ADDR" ] || [ -z "$MANAGER_NAME" ] || [ -z "$MANAGER_KEY" ]; }; then
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

    mkdir -p /syzkiller/{kernel,image,workdir{,_kcsan,_kmsan,_nosan,_ubsan}}
    cd /syzkiller

    git clone https://github.com/google/syzkaller
    cd syzkaller
    make
}

setup_kernel() {
    cd /syzkiller/kernel

    apt-get install -y flex bison libelf-dev libssl-dev pkg-config

    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
    tar xf "linux-${KERNEL_VERSION}.tar.xz"
    cd "linux-${KERNEL_VERSION}"

    cp "/syzkiller/syzkaller/dashboard/config/linux/upstream-${SANITIZER}.config" .config

    if [ "$SANITIZER" = "kmsan" ]; then
        apt-get install -y clang-15 lld-15
        make olddefconfig CC=clang-15 LD=ld.lld-15
        make -j$(nproc) CC=clang-15 LD=ld.lld-15
    else
        make olddefconfig
        make -j$(nproc)
    fi
}

if [ "$MODE" = "hub" ]; then
    setup_common
    cd /syzkiller
    screen -dmS syzhub ./syzkaller/bin/syz-hub -config hub.cfg
    echo "Hub started in screen session 'syzhub'"
else
    setup_common
    setup_kernel
    cd /syzkiller
    ./create-image.sh

    # Select appropriate manager config
    CONFIG_FILE="manager_${SANITIZER}.cfg"

    screen -dmS syzmanager ./syzkaller/bin/syz-manager -config manager.cfg
    echo "Manager started in screen session 'syzmanager'"
fi