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