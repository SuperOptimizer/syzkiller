#!/bin/bash
set -eux

SANITIZER="nosan"
REPO_URL="git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
KERNEL_DIR="linux"

usage() {
   echo "Usage: $0 [--sanitizer TYPE]"
   echo "Sanitizer types: kasan, kcsan, kmsan, nosan, ubsan"
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
       git clone --depth 1 "$REPO_URL" "$KERNEL_DIR"
       cd "$KERNEL_DIR"
   fi

   make mrproper
   cp "/syzkiller/${SANITIZER}.config" .config
   make olddefconfig
   make -j$(nproc)
}

setup_kernel
cd /syzkiller
cd workdir
#nohup syzmanager ./syzkaller/bin/syz-manager -config "manager_${SANITIZER}.cfg" &> out_manager.txt &
echo "Manager started"