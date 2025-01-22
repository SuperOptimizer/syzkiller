#!/bin/bash
# Create minimal Debian image for syzkaller
set -eux

PREINSTALL_PKGS="openssh-server,curl,tar,gcc,libc6-dev,time,strace,sudo,less,psmisc,selinux-utils,policycoreutils,checkpolicy,selinux-policy-default,firmware-atheros,make,sysbench,git,vim,tmux,usbutils,tcpdump"
RELEASE=bookworm
SEEK=2047

# Create debian directory
DIR="$RELEASE"
sudo rm -rf "$DIR"
sudo mkdir -p "$DIR"
sudo chmod 0755 "$DIR"

# Run debootstrap
sudo debootstrap --arch=amd64 --include="$PREINSTALL_PKGS" \
    --components=main,contrib,non-free,non-free-firmware \
    "$RELEASE" "$DIR"

# Configure system
sudo sed -i '/^root/ { s/:x:/::/ }' "$DIR/etc/passwd"
echo 'T0:23:respawn:/sbin/getty -L ttyS0 115200 vt100' | sudo tee -a "$DIR/etc/inittab"

# Configure networking
echo -e "auto eth0\niface eth0 inet dhcp" | sudo tee -a "$DIR/etc/network/interfaces"

# Configure mounts
cat << EOF | sudo tee -a "$DIR/etc/fstab"
/dev/root / ext4 defaults 0 0
debugfs /sys/kernel/debug debugfs defaults 0 0
securityfs /sys/kernel/security securityfs defaults 0 0
configfs /sys/kernel/config/ configfs defaults 0 0
binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc defaults 0 0
EOF

# Basic system config
echo -en "127.0.0.1\tlocalhost\n" | sudo tee "$DIR/etc/hosts"
echo "nameserver 8.8.8.8" | sudo tee -a "$DIR/etc/resolv.conf"
echo "syzkaller" | sudo tee "$DIR/etc/hostname"

# Setup SSH
ssh-keygen -f "$RELEASE.id_rsa" -t rsa -N ''
sudo mkdir -p "$DIR/root/.ssh/"
cat "$RELEASE.id_rsa.pub" | sudo tee "$DIR/root/.ssh/authorized_keys"

# Add udev rules
echo 'ATTR{name}=="vim2m", SYMLINK+="vim2m"' | sudo tee -a "$DIR/etc/udev/rules.d/50-udev-default.rules"

# Create and format image
dd if=/dev/zero of="$RELEASE.img" bs=1M seek="$SEEK" count=1
sudo mkfs.ext4 -F "$RELEASE.img"

# Mount and copy
sudo mkdir -p "/mnt/$DIR"
sudo mount -o loop "$RELEASE.img" "/mnt/$DIR"
sudo cp -a "$DIR/." "/mnt/$DIR/."
sudo umount "/mnt/$DIR"
sudo rm -rf "/mnt/$DIR" "$DIR"