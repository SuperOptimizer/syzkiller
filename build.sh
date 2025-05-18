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
    if [ -d "$KERNEL_DIR" ]; then
        cd "$KERNEL_DIR"
        git pull
    else
        echo "Error: Linux kernel directory not found. Run install.sh first."
        exit 1
    fi

    # Determine which config file to use based on SANITIZER
    CONFIG_FILE=""
    case "$SANITIZER" in
        kasan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-kasan-badwrites.config"
            ;;
        kcsan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-kcsan.config"
            ;;
        kmsan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-kmsan.config"
            ;;
        lsan)
            CONFIG_FILE="/syzkiller/syzkaller/dashboard/config/linux/upstream-leak.config"
            ;;
        *)
            echo "Error: Unknown sanitizer type: $SANITIZER"
            exit 1
            ;;
    esac

    make mrproper LLVM=1
    cp "$CONFIG_FILE" .config
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