#!/usr/bin/env bash

set -euxo pipefail

loadkeys de-latin1

source config.conf

#starting installation inside chroot env
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc
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
echo 'root:'${PWD} | chpasswd
#create user
useradd -m -G wheel ${USER}
# pw change for users
echo ${USER}':'${PWD} | chpasswd

#installing Linux (was not installed)
pacman -S --noconfirm linux mkinitcpio dhcpcd

#installing UEFI bootloader
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
mkdir /boot/EFI
mount ${BOOTPART} /boot/EFI
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

exit
#finished installation in chroot env
