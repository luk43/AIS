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

#----------------
#GRAPHIC DRIVER |
#----------------
read -p "\"intel\", \"nvidia\" or \"amd\" graphic chip? : " GRAPHICS
if [[ "$GRAPHICS" = "intel" ]]; then
	pacman -S --noconfirm xf86-video-intel mesa-libgl libva-intel-driver
elif [[ "$GRAPHICS" = "nvidia" ]]; then
	pacman -S --noconfirm xf86-video-nouveau mesa-libgl
elif [[ "$GRAPHICS" = "amd" ]]; then
	pacman -S --noconfirm xf86-video-ati mesa-libgl
fi

#-----------------------------
#UPDATE PACMAN PACKAGE CACHE |
#-----------------------------
pacman -Syy

#------------
#BASE STUFF |
#------------
pacman -S --noconfirm bash-completion bind-tools cups dosfstools foomatic-db-gutenprint foomatic-db-gutenprint-ppds ghostscript git gsfonts gutenprint libinput libmtp mtpfs networkmanager nmap ntfs-3g openssh rsync ttf-liberation vim wget xf86-input-libinput

#---------------------
#DESKTOP ENVIRONMENT |
#---------------------
pacman -S --noconfirm cheese evolution file-roller gedit gnome gnome-calendar gnome-characters gnome-clocks gnome-documents gnome-getting-started-docs gnome-initial-setup gnome-maps gnome-music gnome-photos gnome-software gnome-tweak-tool gnome-weather nautilus-sendto network-manager-applet seahorse telepathy

#--------------
#APPLICATIONS |
#--------------
pacman -S --noconfirm firefox libreoffice-fresh transmission-gtk vinagre

#-------
#MEDIA |
#-------
pacman -S --noconfirm gstreamer gstreamer-vaapi gstreamermm libva x264 x265

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
echo -e "\nthe installation is complete\nreboot your machine with \"reboot\" and enjoy!"
