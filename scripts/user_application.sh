#!/bin/bash
#-------------------------------------------------------------------------------
#PURPOSE OF THIS SCRIPT IS TO CREATE A USER AND INSTALL ALL REQUIRED SOFTWARE. |
#-------------------------------------------------------------------------------

#-------------
#CREATE USER |
#-------------
read -p "New username: " USERNAME
useradd -m -G wheel -s /bin/bash "$USERNAME"
passwd "$USERNAME"
while [ "$?" = "10" ]; do
	echo -e "Try again: "
	passwd "$USERNAME"
done
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

#----------------
#GRAPHIC DRIVER |
#----------------
read -p "\"intel\", \"nvidia\" or \"amd\" graphic chip? : " GRAPHICS
if [[ "$GRAPHICS" = "intel" ]]; then
	pacman -S --noconfirm xf86-video-intel mesa-libgl libva-intel-driver libva
elif [[ "$GRAPHICS" = "nvidia" ]]; then
	pacman -S --noconfirm xf86-video-nouveau mesa-libgl
elif [[ "$GRAPHICS" = "amd" ]]; then
	pacman -S --noconfirm xf86-video-ati
#TIMEZONE; you can find yours with 'tzselect'
ZONE="Europe"mesa-libgl mesa-vdpau
fi

#------------
#BASE STUFF |
#------------
pacman -S --noconfirm vim bash-completion openssh rsync wget bind-tools xf86-input-synaptics networkmanager libmtp mtpfs ntfs-3g dosfstools git cups ghostscript gsfonts ttf-liberation

#---------------------
#DESKTOP ENVIRONMENT |
#---------------------
pacman -S --noconfirm gnome devhelp gedit evolution gnome-builder cheese file-roller gnome-clocks gnome-documents gnome-maps gnome-music gnome-photos gnome-tweak-tool gnome-weather nautilus-sendto seahorse network-manager-applet gvfs-mtp gvfs-google gnome-calendar gnome-characters gnome-initial-setup gnome-getting-started-docs system-config-printer telepathy gnome-software

#--------------
#APPLICATIONS |
#--------------
pacman -S --noconfirm firefox libreoffice-fresh transmission-gtk vinagre

#-------
#MEDIA |
#-------
pacman -S --noconfirm gstreamer gstreamermm gstreamer-vaapi x264 x265

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
rm /root/user_application.sh
echo -e "\nthe installation is complete.\nreboot your machine with \"reboot\" and enjoy!"
