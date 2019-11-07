#!/usr/bin/env bash

set -euxo pipefail

loadkeys de-latin1

readonly HDD="/dev/sda"
readonly ROOTPART="/dev/sda1"
readonly BOOTPART="/dev/sda2"
readonly HOST="archbox"


# this script creats a fresh arch linux install
# bootable via MBR/Grub
# no disk encryption

### PARTITIONING ###
#for MBR/GRUB - legacy bios
#parted --script ${HDD} \
#	mklabel msdos \
#	mkpart primary xfs 1MiB 100% \
#  set 1 boot on

#for GPT/GRUB - UEFI
parted --script ${HDD} \
	mklabel gpt \
	mkpart P1 fat32 1MiB 512MiB  \
	mkpart primary xfs 512MiB 100%


# formating the partitions
mkfs.xfs ${ROOTPART}

# mount the partitions
mount ${ROOTPART} /mnt

# TODO: automatically set austria server to the default server
# https://wiki.archlinux.org/index.php/Mirrors#Sorting_mirrors

### INSTALLING BASE SYSTEM ###
pacstrap /mnt base base-devel

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab



# chroot into the installed system
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
arch-chroot /mnt hwclock --systohc
echo ${HOST} > /mnt/etc/hostname
cat >> /mnt/etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOST.localdomain $HOST
EOF

# TODO:
# https://wiki.archlinux.org/index.php/Installation_guide#Localization
cat >> /mnt/etc/locale.gen <<EOF
en_US.UTF-8 UTF-8
EOF

arch-chroot locale-gen

cat >> /mnt/etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF

cat >> /mnt/etc/vconsole.conf <<EOF
KEYMAP=de-latin1
EOF

# User management
# root pw
arch-chroot echo 'root:1234' | chpasswd
#create user
useradd -m -G wheel jakobu5
# pw change for users
arch-chroot echo 'jakobu5:1234' | chpasswd

#networking
arch-chroot systemctl enable dhcpcd


# bootloader
#arch-chroot pacman -S grub efibootmgr dosfstools os-prober mtools
#arch-chroot mkdir /boot/EFI
#arch-chroot mount /dev/${ROOTPART1} /boot/EFI
#arch-chroot grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
#arch-chroot grub-mkconfig -o /boot/grub/grub.cfg
