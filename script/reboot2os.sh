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

# new method sed -n '/menuentry/s/.*\(["'\''].*["'\'']\).*/\1/p' /boot/grub/grub.cfg 
OS_LIST=$(grep menuentry /boot/grub/grub.cfg | awk 'BEGIN{FS="\""}{print $2}')
OS_RADIO_LIST=""
OLD_IFS=$IFS
OS_LIST_SAPCE_REMOVED=""
OS_ARRAY[0]=""
IFS="
"
OS_NUMBER=0
for OS in $OS_LIST
do
#   echo $OS
  OS_SPACE_REMOVED=$(echo $OS | sed -e "s/ /_/g")
  OS_LIST_SAPCE_REMOVED="$OS_LIST_SAPCE_REMOVED $OS_SPACE_REMOVED"
  OS_ARRAY[$OS_NUMBER]=$OS
  OS_NUMBER=$(expr $OS_NUMBER + 1)
done
IFS=$OLD_IFS;
OS_NUMBER=0
for OS_SPACE_REMOVED in $OS_LIST_SAPCE_REMOVED
do
#   echo $OS_SPACE_REMOVED $OS_NUMBER
  if [ $OS_NUMBER -eq 0 ]; then
    OS_RADIO_LIST="$OS_RADIO_LIST TRUE $OS_SPACE_REMOVED"
  else
    OS_RADIO_LIST="$OS_RADIO_LIST FALSE $OS_SPACE_REMOVED"
  fi
  OS_NUMBER=$(expr $OS_NUMBER + 1)
done
# echo $OS_RADIO_LIST
SELECTED_OS_SPACE_REMOVED=$(zenity --list --radiolist --column="" --column="Menu Entry" $OS_RADIO_LIST)
CONTINUE=$?
# echo $SELECTED_OS_SPACE_REMOVED
if [ $CONTINUE -ne 0 ]; then
  echo cancelled
  exit
fi

SELECTED_OS=""
SELECTED_OS_NUMBER=0
for OS_SPACE_REMOVED in $OS_LIST_SAPCE_REMOVED
do
  if [ $OS_SPACE_REMOVED = $SELECTED_OS_SPACE_REMOVED ]; then
    SELECTED_OS=${OS_ARRAY[$SELECTED_OS_NUMBER]}
#     echo Found at $SELECTED_OS_NUMBER
  fi
  SELECTED_OS_NUMBER=$(expr $SELECTED_OS_NUMBER + 1)
done

echo selected $SELECTED_OS

/usr/sbin/grub-reboot "$SELECTED_OS"
/sbin/reboot
