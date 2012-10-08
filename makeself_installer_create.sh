#! /bin/bash
BIN_PATH="bin/RebootToOS_installer.run"
BUILD_PATH="script"
INSTALL_EXECUTABLE="./reboot_to_os_installer.sh"
GREET_MESSAGE="Reboot to other OS with GRUB-Installer"
makeself.sh $BUILD_PATH $BIN_PATH "$GREET_MESSAGE" $INSTALL_EXECUTABLE
