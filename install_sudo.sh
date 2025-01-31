#!/bin/bash
# install_root.sh
set -eux

apt-get update
apt-get install -y git curl make gcc wget clang llvm g++ flex bison libelf-dev libssl-dev pkg-config

GO_VERSION="1.21.5"
wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"