#!/bin/bash
# install.sh
set -eux

# Install dependencies
apt-get update
apt-get install -y git curl make gcc wget clang llvm g++ flex bison libelf-dev libssl-dev pkg-config

# Install Go
GO_VERSION="1.21.5"
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
export PATH=/usr/local/go/bin:$PATH

# Clone repos
cd /syzkiller
KERNEL_REPO="git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
git clone --depth 1 "$KERNEL_REPO" linux
git clone --depth 1 https://github.com/google/syzkaller