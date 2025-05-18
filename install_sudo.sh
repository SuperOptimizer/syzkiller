#assumes ubuntu 25.04

set -x
apt-get update -y
apt-get install -y git curl make gcc wget g++ flex bison libelf-dev libssl-dev pkg-config debootstrap software-properties-common qemu-system
sudo apt install -y build-essential gcc g++ llvm clang lld cmake ninja-build git gdb autoconf automake libtool pkg-config libncurses-dev libssl-dev make python3-dev

sudo apt install -y clang-20 lldb-20 lld-20 clangd-20 clang-tidy-20 clang-format-20 clang-tools-20 llvm-20-dev lld-20 lldb-20 llvm-20-tools libomp-20-dev libc++-20-dev libc++abi-20-dev libclang-common-20-dev libclang-20-dev libclang-cpp20-dev libunwind-20-dev libclang-rt-20-dev libpolly-20-dev

sudo usermod -a -G kvm $USER

GO_VERSION="1.24.3"
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
