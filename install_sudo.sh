#!/bin/bash
# install_root.sh
set -eux

apt-get update
apt-get install -y git curl make gcc wget g++ flex bison libelf-dev libssl-dev pkg-config

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 20 all
sudo ln -s /usr/bin/llvm-objcopy-20 /usr/local/bin/llvm-objcopy
sudo ln -s /usr/bin/llvm-nm-20 /usr/local/bin/llvm-nm
sudo ln -s /usr/bin/llvm-ar-20 /usr/local/bin/llvm-ar
sudo ln -s /usr/bin/clang-20 /usr/local/bin/clang

GO_VERSION="1.23.5"
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"