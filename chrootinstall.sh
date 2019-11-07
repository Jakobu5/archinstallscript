#!/usr/bin/env bash

set -euxo pipefail

loadkeys de-latin1

readonly HDD="/dev/sda"
readonly ROOTPART="/dev/sda2"
readonly BOOTPART="/dev/sda1"
readonly HOST="archbox"

#starting installation inside chroot env
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
/mnt hwclock --systohc
echo ${HOST} > /etc/hostname
cat >> /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOST.localdomain $HOST
EOF

#localisation
cat >> /etc/locale.gen <<EOF
en_US.UTF-8 UTF-8
EOF

locale-gen

cat >> /etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF

cat >> /etc/vconsole.conf <<EOF
KEYMAP=de-latin1
EOF

# User management
# root pw
echo 'root:1234' | chpasswd
#create user
useradd -m -G wheel jakobu5
# pw change for users
echo 'jakobu5:1234' | chpasswd

#networking
systemctl enable dhcpcd


#installing UEFI bootloader
pacman -S grub efibootmgr dosfstools os-prober mtools
mkdir /boot/EFI
mount ${ROOTPART1} /boot/EFI
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg


#finished installation in chroot env
