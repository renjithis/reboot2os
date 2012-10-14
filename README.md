reboot_to_os
============

Reboot to another OS from currently logged in Linux box

This is a shell script that detects grub2 entries and allows user to select which OS to boot to.
The list of detected OSes is presented using 'zenity' GUI.
It has an Installer which detects whether 'zenity' is installed or not and installs it if necessary.

Installer
=========

The steps involved in installer are :
Select available text editor. Supported ones are :
 gedit
 kate
 leafpad

If 'zenity' is not available, install it using either of the commands :
 apt-get update && apt-get install -q -y zenity
 yum install zenity
 pacman -U zenity

Prompt user to modify GRUB_DEFAULT /etc/default/grub to 'saved' if not already. This prompt will repeat until the user has made the change and saved the file.

Change the execution permission of /sbin/reboot and /sbin/grub-editenv to allow them to be executed by normal user using commands :
 chmod u+s /sbin/reboot
 chmod u+s /usr/bin/grub-editenv

Update grub menu and set default boot option to 0 using commands :
 update-grub2
 grub-set-default 0

Copy the script to /usr/bin and images to /usr/share/icons

Create desktop icon for RebootToOS
