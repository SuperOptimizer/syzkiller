#!/bin/bash
# install_user.sh
set -eux

export PATH=/usr/local/go/bin:$PATH
cd /syzkiller

git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git clone --depth 1 https://github.com/google/syzkaller