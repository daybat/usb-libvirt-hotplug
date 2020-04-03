#!/bin/bash
#
# usb-libvirt-hotplug.sh
#
# This can be used to attach devices when they are plugged into a
# specific port on the host machine.
#
# See: https://github.com/daybat/usb-libvirt-hotplug
#
source config.sh
#set -e
t=1
shPID=0
trap "killall -9 ${SC}" EXIT

while [ $t -gt 0 ]
do
 ps=$(virsh dominfo ${DOMAIN})
 if [[ $ps == *"running"* ]];
 then
  shPID=$(pidof -x ${SC})
  if [ ${#shPID} == 0 ];
  then
   $cmdUSB&
   sleep 1
   shPID=$(pidof -x ${SC})
  fi
 else
  shPID=$(pidof -x ${SC})
  [ ${#shPID} != 0 ] && kill $shPID
  [ -f ${USBALLOW}.attach ] && rm ${USBALLOW}.attach
  [ -f ${USBALLOW}.attach.1 ] && rm ${USBALLOW}.attach.1
 fi
 sleep 5
done
