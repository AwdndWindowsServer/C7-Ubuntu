#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

cat > /etc/hosts << 'HOSTS'
127.0.0.1 localhost
127.0.1.1 samsung-c7lte
HOSTS

echo "samsung-c7lte" > /etc/hostname
echo "root:toor" | chpasswd

cat > /etc/apt/sources.list << APTSRC
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${DISTRO} main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${DISTRO}-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${DISTRO}-security main restricted universe multiverse
APTSRC

apt-get update -y
apt-get install -y \
  apt-transport-https ca-certificates \
  initramfs-tools kmod systemd \
  zstd file

shopt -s nullglob
for f in /tmp/linux-image-*.deb; do
  case "$f" in *dbg*) continue;; esac
  dpkg -i "$f" || apt-get -f install -y
done

# 确保内核已安装，否则 update-initramfs 无内核可用
if ! ls /boot/vmlinuz-* >/dev/null 2>&1; then
  echo "ERROR: no kernel installed in chroot" >&2
  ls /boot >&2
  exit 1
fi

# 显式指定内核版本（qemu chroot 中 uname 是 host 的，不能依赖 -u 默认值）
KVER="${KVER:-$(ls /boot/vmlinuz-* | sed 's/.*vmlinuz-//' | head -1)}"
update-initramfs -u -k "$KVER"
if ! ls /boot/initrd.img-* >/dev/null 2>&1; then
  echo "ERROR: update-initramfs did not produce initrd.img" >&2
  exit 1
fi
ls -lh /boot/initrd.img-* 2>/dev/null
apt-get clean
rm -f /tmp/*.deb
