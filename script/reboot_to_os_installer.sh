#! /bin/bash
#
#	This script comes with no warranty. Use at own risk
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; version 3 of the License.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program or from the site that you downloaded it
#	from; if not, write to the Free Software Foundation, Inc., 59 Temple
#	Place, Suite 330, Boston, MA  02111-1307   USA
#
#	GPL : http://www.gnu.org/copyleft/gpl.html
#
#	Script author : Renjith I S
#	Webpage : http://www.renjithis.in
#
#	You are free to modify this script and to make it better.
#	If you have done so and if you think you have made the script
#	better, please mail me a copy of it or make a pull-request in GitHub.
#	The comments provided in the script is for debugging and further development.
#	I would also appreciate any corrections and suggestions,
#	but i cant promise you that i would be able to implement it because of my
#	lack of knowledge in scripting.
#	Feel free to contact me for any information.
#

SUCCESS=0
if [ $(which gksu) ]; then
  SUDO="gksu"
elif [ $(which kdesudo) ]; then
  SUDO="kdesudo"
elif [ $(which kdesu) ]; then
  SUDO="kdesu"
else
  SUDO="sudo"
fi

if [ $(which gedit) ]; then
  TEXT_EDITOR="gedit"
elif [ $(which kate) ]; then
  TEXT_EDITOR="kate"
elif [ $(which leafpad) ]; then
  TEXT_EDITOR="leafpad"
fi

# tty -s; if [ $? -ne 0 ]; then xterm -e "$0"; exit; fi
if [ ! "$(which zenity)" ]; then
  echo
  if [ "$(which software-properties-kde)" ]; then
    sudo software-properties-kde --enable-component universe
  fi
  INSTALL_COMMAND=""
  if [ $(which apt-get) ]; then
    INSTALL_COMMAND="$SUDO apt-get update && $SUDO apt-get install -q -y zenity"
  elif [ $(which yum) ]; then
    INSTALL_COMMAND="$SUDO yum install zenity"
  elif [ $(which pacman) ]; then
    INSTALL_COMMAND="$SUDO pacman -U zenity"
  fi
  xterm -title 'Install zenity' -e "$INSTALL_COMMAND"
fi

if [ ! "$(which zenity)" ]; then
  xterm -title 'Unable to install zenity' -e "echo \"Please install zenity manually and run the script again.\" && read -sn 1-p \"Press any key to exit\""
  SUCCESS=-1
  exit 1
fi

if [ ! $TEXT_EDITOR ]; then
  echo "Text Editor not found"
  TEXT_EDITOR=$(zenity --entry --text="Enter a GUI Text Editor")
fi

(
  echo 10
  sleep 1
  LOOP_COUNT=0
  while true ; do
    GRUB_DEFAULT_VALUE=$(awk -F"=" '/^GRUB_DEFAULT/ { print $2 }' /etc/default/grub)
    echo "Current GRUB_DEFAULT = $GRUB_DEFAULT_VALUE"
    if [ $GRUB_DEFAULT_VALUE != "saved" ]; then
      zenity --question --text "Please modify the value GRUB_DEFAULT to \nGRUB_DEFAULT=saved \nin the file /etc/default/grub. \nThe file will be opened after pressing Yes. \nPress No to stop the installation."
      CONTINUE=$?
      echo $CONTINUE
      if [ $LOOP_COUNT -gt 10 ]; then
	#Fail the installation
	CONTINUE=1
      fi
      if [ $CONTINUE -ne 0 ]; then
	SUCCESS=-1
	zenity --error --text="Install was unsuccessful."
	echo "Install was unsuccessful."
	exit 1
      fi
      echo 20
      $SUDO $TEXT_EDITOR /etc/default/grub
      echo 30
    else
      break
    fi
    LOOP_COUNT=$(expr $LOOP_COUNT + 1)
  done
  echo 50
  zenity --question --text "Attribues of /sbin/reboot AND /usr/bin/grub-editenv will be modified so that normal users would be allowed to execute them. Do you want to continue?.\nPress No to stop the installation."
  CONTINUE=$?
  echo $CONTINUE
  if [ $CONTINUE -eq 1 ]; then
    SUCCESS=-1
    zenity --error --text="Install was unsuccessful."
    exit 1
  fi
  echo 70
  TMP_SCRIPT=$(tempfile -p attr_ -s .sh)
#   zenity --info --text=$TMP_SCRIPT

  cat <<EOF > $TMP_SCRIPT 
chmod u+s /sbin/reboot
chmod u+s /usr/bin/grub-editenv
update-grub2
echo 80
grub-set-default 0
cp reboot_to_os.sh /usr/bin/
mkdir -p /usr/share/icons/reboot_to_os
cp images/reboot_to_os*.png /usr/share/icons/reboot_to_os/
if [ $? -ne 0 ]; then
  ICON_LIST=$(ls reboot_to_os*.png)
  zenity --warning --text="Unable to copy icons : $ICON_LIST"
fi
chmod -R a+r /usr/share/icons/reboot_to_os
echo 90
sleep 1
chmod +x /usr/bin/reboot_to_os.sh
EOF

  chmod +x $TMP_SCRIPT
  zenity --info --text="Enter password to allow attribute setting and to allow copying"
  $SUDO $TMP_SCRIPT
  rm -f $TMP_SCRIPT

#   ln -s /usr/bin/reboot_to_os.sh $HOME/Desktop/RebootToOS
  if [ -L $HOME/Desktop/RebootToOS ]; then
    rm -f $HOME/Desktop/RebootToOS
  fi
  if [ -f $HOME/Desktop/RebootToOS.desktop ]; then
    rm -f $HOME/Desktop/RebootToOS.desktop
  fi

  if [ -f /usr/share/icons/reboot_to_os/reboot_to_os4.png ]; then
    ICON=/usr/share/icons/reboot_to_os/reboot_to_os4.png
  else
    zenity --info --text="Unable to set icon for Desktop shortcut.\nTrying to find icon containing 'reboot' in its name from /usr/share/icons/."
    ICON=$(find /usr/share/icons/ -iname *reboot*.png -size +4k | tail -n 1)
  fi

  cat <<EOF > $HOME/Desktop/RebootToOS.desktop 
[Desktop Entry]
Name=RebootToOS
Exec=reboot_to_os.sh 
Type=Application
StartupNotify=true
Path=
Icon=$ICON
EOF
  chmod +x $HOME/Desktop/RebootToOS.desktop 
  zenity --info --text "File /usr/bin/reboot_to_os.sh has been created and link made to Desktop. \nTo uninstall, delete /usr/bin/reboot_to_os.sh and remove the link."
  echo 100
) | zenity --progress --auto-close --title="Installing RebootToOS"

if [ $SUCCESS -ne 0 ]; then
  zenity --error --text="Install was unsuccessful."
  if [ $? -ne 0]; then
    xterm -title "echo \"Install was unsuccessful.\" && read -sn 1-p \"Press any key to exit\""
  fi
fi
exit 0
