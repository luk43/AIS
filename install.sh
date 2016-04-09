#!/bin/bash
#-------------------------------------------------------
#LOCALE OPTIONS WHICH WILL BE SET MANUALLY BY THE USER |
#-------------------------------------------------------

#TIMEZONE; you can find yours with 'tzselect'
ZONE="Europe"
SUBZONE="Zurich"

#KEYMAP; 'localectl list-keymaps' lists all available options
KEYMAP="de_CH-latin1"

#DON'T CHANGE ANYTHING BELOW THE LINE
#-------------------------------------------------------------------------------

#------------------
#MAIN INFORMATION |
#------------------
echo -e "Before you get started here are a few notes.\n* WLAN is not yet supported during the installation.\n* Make sure that the hard drive is clean / wiped.\nhave fun!"
read -p "root (/) volume size (e.g 20G): " ROOT
read -p "Swap volume size (e.g 4G) [empty = auto]: " RAM
read -p "mbr (BIOS) or gpt (UEFI)?: " PART_TABLE
read -p "Hostname: " HOSTNAME
if [[ -z "$RAM" ]]; then
  RAM=$(free -h|awk '/^Mem:/{print $2}')
fi

#----------------
#BOOT PARTITION |
#----------------
if [[ "$PART_TABLE" = "gpt" ]]; then
	parted /dev/sda <<EOF
	mklabel gpt
	mkpart ESP 1MiB 513MiB
	set 1 boot on
	mkpart primary 513MiB 100%
EOF
	mkfs.vfat -F32 /dev/sda1
elif [[ "$PART_TABLE" = "mbr" ]]; then
	parted /dev/sda <<EOF
	mklabel msdos
	mkpart primary 1MiB 513MiB
	set 1 boot on
	mkpart primary 513MiB 100%
EOF
	mkfs.ext2 /dev/sda1
else
	echo "False Partition table (only mbr or gpt)"
	exit 1
fi

#----------------------------------------
#ENCRYPTION AND LOGICAL VOLUME CREATION |
#----------------------------------------
echo -e "First type \"YES\" and then enter the chosen password for /dev/sda2 twice and once to unlock."
cryptsetup -v --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat /dev/sda2
cryptsetup open --type luks /dev/sda2 lvm
pvcreate /dev/mapper/lvm
vgcreate archlinux /dev/mapper/lvm

lvcreate -L "$RAM" archlinux -n swapvol
lvcreate -L "$ROOT" archlinux -n rootvol
lvcreate -l +100%FREE archlinux -n homevol

#--------------------------------------
#PARTITION CREATION AND MOUNT TO /MNT |
#--------------------------------------
mkfs.ext4 /dev/mapper/archlinux-rootvol
mkfs.ext4 /dev/mapper/archlinux-homevol
mkswap /dev/mapper/archlinux-swapvol

mount /dev/archlinux/rootvol /mnt
mkdir /mnt/home
mount /dev/archlinux/homevol /mnt/home
swapon /dev/archlinux/swapvol

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

#--------------
#INSTALLATION |
#--------------
echo -e "\n"
read -p "Do you want to make changes to the pacman mirrorlist? [y/n]: " MIRRORLIST
if [[ "$MIRRORLIST" = "y" ]]; then
	vim /etc/pacman.d/mirrorlist
fi
pacstrap /mnt base base-devel
genfstab -p /mnt >> /mnt/etc/fstab

#---------------------
#AFTER INSTALL TASKS |
#---------------------
sed -i "5s/.*/PART_TABLE="$PART_TABLE"/" scripts/chroot.sh
sed -i "10s/.*/HOSTNAME="$HOSTNAME"/" scripts/chroot.sh
sed -i "16s/.*/LOCALTIME="$ZONE"\/"$SUBZONE"/" scripts/chroot.sh
sed -i "38s/.*/KEYMAP="$KEYMAP"/" scripts/chroot.sh
cp "$PWD"/scripts/chroot.sh /mnt
cp "$PWD"/scripts/user_application.sh /mnt/root
echo -e "\nType \"./chroot.sh\" to continue the installation."
arch-chroot /mnt /bin/bash
