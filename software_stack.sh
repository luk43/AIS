#!/bin/bash
#-------------
#CREATE USER |
#-------------
read -p "New username: " USERNAME
useradd -m -G wheel -s /bin/bash "$USERNAME"
passwd "$USERNAME"
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

#----------
#Graphics |
#----------
read -p "intel, nvidia or amd graphic chip? : " GRAPHICS
if [[ "$GRAPHICS" = "intel" ]]
  then
  pacman -S --noconfirm xf86-video-intel mesa-libgl libva-intel-driver libva
elif [[ "$GRAPHICS" = "nvidia" ]]
  then
  pacman -S --noconfirm xf86-video-nouveau mesa-libgl
elif [[ "$GRAPHICS" = "amd" ]]
  then
  pacman -S --noconfirm xf86-video-ati mesa-libgl mesa-vdpau
fi

#--------------
#COMMON STUFF |
#--------------
pacman -S --noconfirm vim bash-completion openssh rsync wget bind-tools xf86-input-synaptics networkmanager libmtp mtpfs ntfs-3g dosfstools xfsprogs git

#---------------------
#DESKTOP ENVIRONMENT |
#---------------------
pacman -S --noconfirm gnome devhelp gedit evolution gnome-builder cheese file-roller gnome-clocks gnome-documents gnome-maps gnome-music gnome-photos gnome-tweak-tool gnome-weather nautilus-sendto seahorse network-manager-applet gvfs-mtp gvfs-google gnome-calendar gnome-characters

#--------------
#APPLICATIONS |
#--------------
pacman -S --noconfirm firefox libreoffice-fresh transmission-gtk vinagre

#-------
#MEDIA |
#-------
pacman -S --noconfirm gstreamer gstreamermm gstreamer-vaapi x264 x265

#--------
#CONFIG |
#--------
NETWORK_DEVICE=$(ip a | grep 'state UP' | awk -F': ' '{print $2}')
systemctl disable dhcpcd@"$NETWORK_DEVICE"
systemctl enable NetworkManager.service
systemctl enable gdm.service

#--------
#YAOURT |
#--------
su "$USERNAME" <<EOF
cd ~
mkdir build
cd build
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
tar zxvf package-query.tar.gz
cd package-query
makepkg -si --noconfirm
cd ..
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
tar zxvf yaourt.tar.gz
cd yaourt
makepkg -si --noconfirm
cd ~
rm -r build
EOF
rm "$PWD"/software_stack.sh
