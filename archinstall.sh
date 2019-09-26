#/bin/bash
HDD="/dev/vda"
ROOTPART="/dev/vda1"
HOST="archbox"


# this script creats a fresh arch linux install
# bootable via MBR/Grub
# no disk encryption

### PARTITIONING ###
#for MBR/GRUB - legacy bios
parted --script $HDD \
	mklabel msdos \
	mkpart primary ext4 1MiB 100% \
  set 1 boot on

#for GPT/GRUB - UEFI
#parted --script /dev/sda \
#	mklabel gpt \
#	mkpart P1 fat32 1MiB 512MiB  \
#	mkpart P2 linux-swap 512MiB 1500MiB \
#	mkpart primary ext4 1500MiB 7000MiB


# formating the partitions
mkfs.ext4 $ROOTPART

# mount the partitions
mount $ROOTPART /mnt

# TODO: automatically set austria server to the default server
# https://wiki.archlinux.org/index.php/Mirrors#Sorting_mirrors

### INSTALLING BASE SYSTEM ###
pacstrap /mnt base base-devel

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab



# chroot into the installed system
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
arch-chroot /mnt hwclock --systohc
echo $HOST > /mnt/etc/hostname
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
# bootloader
