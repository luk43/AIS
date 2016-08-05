#!/bin/bash
#------------------------------------------------------
#PART_TABLE VARIABLE WILL PASTED HERE FROM install.sh |
#------------------------------------------------------


#----------------------------------------------------
#SET HOSTNAME, IT WILL PASTED HERE  FROM install.sh |
#----------------------------------------------------

echo "$HOSTNAME" > /etc/hostname

#-----------------------------------------------------
#SET LOCALTIME, IT WILL PASTED HERE  FROM install.sh |
#-----------------------------------------------------

ln -sf /usr/share/zoneinfo/"$LOCALTIME" /etc/localtime

#--------------------
#SET HWCLOCK TO UTC |
#--------------------
hwclock --systohc --utc

#------------
#SET LOCALE |
#------------
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

#---------------------
#SET LOCALE VARIABLE |
#---------------------
echo LANG=en_US.UTF-8 > /etc/locale.conf

#----------------------------------------------------
#SET VCONSOLE, IT WILL PASTED HERE  FROM install.sh |
#----------------------------------------------------

echo -e "KEYMAP="$KEYMAP"\nFONT=lat9w-16" > /etc/vconsole.conf

#--------------------
#SET NETWORK DEVICE |
#--------------------
NETWORK_DEVICE=$(ip a | grep 'state UP' | awk -F': ' '{print $2}')
systemctl enable dhcpcd@"$NETWORK_DEVICE"

#----------------
#SET MKINITCPIO |
#----------------
sed -i 's/HOOKS="base udev autodetect modconf block filesystems keyboard fsck"/HOOKS="base udev autodetect modconf block keymap encrypt lvm2 filesystems keyboard fsck"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

#-------------------
#SET ROOT PASSWORD |
#-------------------
echo -e "create root password: "
passwd

while [ "$?" = "10" ]; do
	echo -e "try again: "
	passwd
done

#--------------------
#INSTALL BOOTLOADER |
#--------------------
if [[ "$PART_TABLE" = "mbr" ]]; then
	pacman -S grub --noconfirm
	grub-install --target=i386-pc --recheck /dev/sda
	sed -i 's/GRUB_CMDLINE_LINUX\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=\/dev\/sda2:archlinux root=\/dev\/mapper\/archlinux-rootvol\"/' /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$PART_TABLE" = "gpt" ]]; then
	pacman -S syslinux efibootmgr --noconfirm
	mkdir -p /boot/EFI/syslinux
	cp -r /usr/lib/syslinux/efi64/* /boot/EFI/syslinux
	efibootmgr -c -d /dev/sda -p 1 -l /EFI/syslinux/syslinux.efi -L "Arch Linux"
	sed -i 's/    APPEND root=\/dev\/sda3 rw/    APPEND root=\/dev\/mapper\/archlinux-rootvol cryptdevice=\/dev\/sda2:archlinux rw/' /boot/syslinux/syslinux.cfg
fi

#-------------------
#AFTER SETUP TASKS |
#-------------------
echo -e "\nexit from the chroot environment by running exit or pressing Ctrl+D"
echo -e "\npartitions will be unmounted automatically by systemd on shutdown\nYou may however unmount manually as a safety measure with \"umount -R /mnt\" after exiting the chroot environment"
echo -e "\nafter reboot you can login as root and start with the installation of your software with \"./user_application.sh\""
rm chroot.sh
