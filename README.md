# arch install script
**Installs archlinux with a custom GNOME-stack.**

## get started
1. wipe your disk (sda)
2. boot archlinux iso
3. get the scripts: ```wget https://github.com/luk43/AIS/archive/master.tar.gz && tar xvf master.tar.gz```
4. change your locale settings in the "install.sh" script to your needs.
5. change software to your preference in "scripts/user_application.sh" (e.g you don't want GNOME) \*optional
6. start with ```./install.sh```

## disk layout
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

## further notes
* there is only one disk used (sda)
* make sure you have network connection through ethernet
* you will give the size of rootvol and swapvol. rest goes to homevol.
* have fun! :D
