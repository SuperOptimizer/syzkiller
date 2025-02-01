set -x
apt-get update
apt-get install -y git curl make gcc wget g++ flex bison libelf-dev libssl-dev pkg-config debootstrap software-properties-common qemu-system

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 20 all
ln -s /usr/bin/llvm-objcopy-20 /usr/local/bin/llvm-objcopy
ln -s /usr/bin/llvm-nm-20 /usr/local/bin/llvm-nm
ln -s /usr/bin/llvm-ar-20 /usr/local/bin/llvm-ar
ln -s /usr/bin/clang-20 /usr/local/bin/clang

sudo apt update -y
sudo apt install -y clang-20 lldb-20 lld-20 clangd-20 clang-tidy-20 clang-format-20 clang-tools-20 llvm-20-dev lld-20 lldb-20 llvm-20-tools libomp-20-dev libc++-20-dev libc++abi-20-dev libclang-common-20-dev libclang-20-dev libclang-cpp20-dev libunwind-20-dev libclang-rt-20-dev libpolly-20-dev


GO_VERSION="1.21.5"
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
