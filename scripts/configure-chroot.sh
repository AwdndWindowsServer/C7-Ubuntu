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
  systemd systemd-timesyncd initramfs-tools \
  network-manager openssh-server \
  bash-completion vim tmux locales locales-all \
  file usbutils sudo \
  python3 iptables rfkill alsa-ucm-conf \
  u-boot-tools zstd

shopt -s nullglob
for f in /tmp/linux-image-*.deb; do
  case "$f" in *dbg*) continue;; esac
  dpkg -i "$f" || apt-get -f install -y
done

update-initramfs -u
apt-get clean
rm -f /tmp/*.deb
