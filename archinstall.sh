#!/usr/bin/env bash

set -euxo pipefail

loadkeys de-latin1

source config.conf


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
mkfs.xfs -f ${ROOTPART}
mkfs.fat -F32 ${BOOTPART}

# mount the partitions
mount ${ROOTPART} /mnt

# TODO: automatically set austria server to the default server
# https://wiki.archlinux.org/index.php/Mirrors#Sorting_mirrors

### INSTALLING BASE SYSTEM ###
pacstrap /mnt base base-devel

#generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

cp chrootinstall.sh /mnt
cp finishinstall.sh /mnt
cp config.conf /mnt

chmod +x /mnt/chrootinstall.sh
chmod +x /mnt/finishinstall.sh

arch-chroot /mnt /chrootinstall.sh

umount -a
