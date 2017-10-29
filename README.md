# not maintained anymore 

# arch install script
**Installs archlinux with a custom GNOME-stack.**

## 1. boot archlinux iso
* Set the keyboard layout

```localectl list-keymaps``` lists all available options.

For example, run ```loadkeys de-latin1``` to set a German keyboard layout.

* Verify the boot mode

If UEFI mode is enabled on an UEFI motherboard, Archiso will boot Arch Linux accordingly via systemd-boot. To verify this, list the efivars directory:

```shell
$ ls /sys/firmware/efi/efivars
```
If the directory does not exist, the system may be booted in BIOS or CSM mode.

## 2. get the scripts
```shell
$ wget https://github.com/luk43/AIS/archive/master.tar.gz && tar xvf master.tar.gz
$ cd AIS-master/

```
* change your locale settings in the "install.sh" script to your needs
* change software to your preference in "scripts/user_application.sh" (e.g you don't want GNOME)\*optional

## 3. install
 ```shell
 $ ./install.sh
 ```

## further notes
* there is only one disk used (sda)
* sda has to be completely wiped (function to wipe is included in the installation)
* make sure you have network connection through ethernet
* you will give the size of rootvol and swapvol and rest goes to homevol
* have fun! :D

#### disk layout
```
+--------------------------------------------------------------------------------------------+ +----------------+
| Logical volume1         swap | Logical volume2          xfs | Logical volume3          xfs | |     ext4/fat32 |
|/dev/mapper/archlinux-swapvol |/dev/mapper/archlinux-rootvol |/dev/mapper/archlinux-homevol | | Boot partition |
|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ | |                |
|                                                                                            | |                |
|                        LUKS encrypted partition                                            | |                |
|                          /dev/sda2                                                         | | /dev/sda1      |
+--------------------------------------------------------------------------------------------+ +----------------+
```
