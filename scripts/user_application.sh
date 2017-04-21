#!/bin/bash
#-------------------------------------------------------------------------------
#PURPOSE OF THIS SCRIPT IS TO CREATE A USER AND INSTALL ALL REQUIRED SOFTWARE. |
#-------------------------------------------------------------------------------

#-------------
#CREATE USER |
#-------------
read -p "new username: " USERNAME
useradd -m -G wheel -s /bin/bash "$USERNAME"
passwd "$USERNAME"
while [ "$?" = "10" ]; do
	echo -e "try again: "
	passwd "$USERNAME"
done
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

#-----------------------------
#UPDATE PACMAN PACKAGE CACHE |
#-----------------------------
pacman -Syy

#----------------
#GRAPHIC DRIVER |
#----------------
read -p "\"intel\" or \"nvidia\" or graphic chip? : " GRAPHICS
if [[ "$GRAPHICS" = "intel" ]]; then
	pacman -S --noconfirm gstreamer-vaapi libva libva-intel-driver mesa
elif [[ "$GRAPHICS" = "nvidia" ]]; then
	pacman -S --noconfirm gst-plugins-bad mesa-vdpau nvidia

#------------
#BASE STUFF |
#------------
pacman -S --noconfirm bash-completion bind-tools cups dosfstools foomatic-db foomatic-db-engine foomatic-db-nonfree-ppds foomatic-db-gutenprint-ppds ghostscript git gsfonts gutenprint libinput libmtp mtpfs networkmanager ntfs-3g openssh rsync vim wget xf86-input-libinput

#---------------------
#DESKTOP ENVIRONMENT |
#---------------------
pacman -S --noconfirm evolution file-roller gedit gnome gnome-calendar gnome-characters gnome-clocks gnome-documents gnome-getting-started-docs gnome-initial-setup gnome-maps gnome-music gnome-photos gnome-software gnome-tweak-tool gnome-weather nautilus-sendto network-manager-applet polkit-gnome seahorse telepathy

#--------------
#APPLICATIONS |
#--------------
pacman -S --noconfirm transmission-gtk vinagre

#-------
#MEDIA |
#-------
pacman -S --noconfirm gstreamer gst-libav gst-plugins-base x264 x265

#----------
#SERVICES |
#----------
NETWORK_DEVICE=$(ip a | grep 'state UP' | awk -F': ' '{print $2}')
systemctl disable dhcpcd@"$NETWORK_DEVICE"
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable org.cups.cupsd.service

#--------
#YAOURT |
#--------
su "$USERNAME" <<EOF
cd ~
mkdir build
cd build
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si --noconfirm
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si --noconfirm
cd ~
rm -rf ~/build
EOF

#---------------------
#AFTER INSTALL TASKS |
#---------------------
echo -e "\ninfo: if UEFI boot is enabled, it is recommended to install \"systemd-boot-pacman-hook\"\nfor more infos: https://wiki.archlinux.org/index.php/Systemd-boot#Automatically"
echo -e "\ninfo: if NVIDIA card is installed, please install \"nouveau-fw\"\nfor more infos: https://wiki.archlinux.org/index.php/Nvidia"
echo -e "\nthe installation is complete\nreboot your machine with \"reboot\" and enjoy!"
rm /root/user_application.sh
