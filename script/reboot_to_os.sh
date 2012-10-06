#! /bin/bash
MENU_ENTRY_LIST=$(grep menuentry /boot/grub/grub.cfg)
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

/usr/sbin/grub-reboot $SELECTED_OS
/sbin/reboot