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

for f in /tmp/linux-image-*.deb; do
  case "$f" in *dbg*) continue;; esac
  dpkg -i "$f" || apt-get -f install -y
done

cat >> /etc/initramfs-tools/modules << 'MODULES'
qcom_smem
qcom_smd
msm
panel_samsung_s6e3fa3
edt_ft5x06
MODULES

update-initramfs -u
apt-get clean
rm -f /tmp/*.deb
