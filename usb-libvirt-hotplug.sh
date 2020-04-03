#!/bin/bash

#
# usb-libvirt-hotplug.sh
#
# This can be used to attach devices when they are plugged into a
# specific port on the host machine.
#
# See: https://github.com/daybat/usb-libvirt-hotplug
#
source ./config.sh
#DOMAIN="win7-64-modules"
#USBALLOW="/etc/libvirt/${DOMAIN}.usb"
USBDEVICES=${USBALLOW}.attach

# Abort script execution on errors
set -e

PROG="$(basename "$0")"

if [ ! -t 1 ]; then
  # stdout is not a tty. Send all output to syslog.
  coproc logger --tag "${PROG}"
  exec >&${COPROC[1]} 2>&1
fi

t=1
z="0"
x="0x"
tmpfile=${USBDEVICES}.1

while [ $t -gt 0 ]
do
 ps=$(virsh dominfo ${DOMAIN})
 if [[ $ps == *"running"* ]];
 then

  ( [ -e "$USBDEVICES" ] || touch "$USBDEVICES" ) && [ ! -w "$USBDEVICES" ] && echo cannot write to $USBDEVICES && exit 1
  ( [ -e "$tmpfile" ] || touch "$tmpfile" ) && [ ! -w "$tmpfile" ] && echo cannot write to $tmpfile && exit 1
  lsusb=$(lsusb)
  while IFS= read -r line || [[ "$line" ]]; do
   VendorID="$(echo ${line} | cut -d':' -f1)"
   DeviceID="$(echo ${line} | cut -d':' -f2)"
   busnum="$(echo ${line} | cut -d':' -f3)"
   devnum="$(echo ${line} | cut -d':' -f4)"
   [ ${#busnum} == 2 ] && busnum1="${z}${busnum}"
   [ ${#busnum} == 1 ] && busnum1="${z}${z}${busnum}"

   [ ${#devnum} == 2 ] && devnum1="${z}${devnum}"
   [ ${#devnum} == 1 ] && devnum1="${z}${z}${devnum}"

   if [[ $lsusb != *"Bus ${busnum1} Device ${devnum1}:"* ]];
   then
#   echo "detach: <hostdev mode='subsystem' type='usb' managed='yes'><source startupPolicy='optional'><vendor id='${VendorID}' /><product id='${DeviceID}' /><address type='usb' bus='${busnum}' device='${devnum}' /></source></hostdev>"
    /usr/bin/virsh detach-device "${DOMAIN}" /dev/stdin<<END
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source startupPolicy='optional'>
    <vendor id='${VendorID}' />
    <product id='${DeviceID}' />
    <address bus='${busnum}' device='${devnum}' />
  </source>
</hostdev>
END
   else
    echo "${VendorID}":"${DeviceID}":"${busnum}":"${devnum}" >> "$tmpfile"
   fi
  done < $USBDEVICES

  mv $tmpfile $USBDEVICES

   while IFS= read -r line || [[ "$line" ]]; do
#   echo "line: ${line}"
   VendorID="$(echo ${line} | cut -d':' -f1)"
   DeviceID="$(echo ${line} | cut -d':' -f2)"
   VendorID="${x}${VendorID}"
   DeviceID="${x}${DeviceID}"
   while IFS= read -r usb || [[ "$usb" ]]; do
#   echo "usb: ${usb}"
    busnum="$(echo ${usb} | cut -d' ' -f2)"
    devnum="$(echo ${usb} | cut -d' ' -f4)"
    devnum="$(echo ${devnum} | cut -d':' -f1)"
    busnum=$((10#$busnum))
    devnum=$((10#$devnum))
    if !(grep -Fxq "${VendorID}":"${DeviceID}":"${busnum}":"${devnum}" "$USBDEVICES");
     then
      if [ ${busnum} != 0 -a ${devnum} != 0 ];
      then
#       echo "attach: <hostdev mode='subsystem' type='usb' managed='yes'><source startupPolicy='optional'><vendor id='${VendorID}' /><product id='${DeviceID}' /><address type='usb' bus='${busnum}' device='${devnum}' /></source></hostdev>"
       virsh attach-device "${DOMAIN}" /dev/stdin<<END
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <vendor id='${VendorID}' />
    <product id='${DeviceID}' />
    <address bus='${busnum}' device='${devnum}' />
  </source>
</hostdev>
END
        grep -Fxq -- "${VendorID}":"${DeviceID}":"${busnum}":"${devnum}" "$USBDEVICES" || echo "${VendorID}":"${DeviceID}":"${busnum}":"${devnum}" >> "$USBDEVICES"
     fi
    fi
   done <<<$(lsusb|grep $line)
  done <$USBALLOW
 fi
 sleep 1
# x=$(( $x - 1 ))
done
