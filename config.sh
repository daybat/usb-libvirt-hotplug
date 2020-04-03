#
# usb-libvirt-hotplug.sh
#
# This can be used to attach devices when they are plugged into a
# specific port on the host machine.
#
# See: https://github.com/daybat/usb-libvirt-hotplug
#
DOMAIN="win7-64-modules"
SC=usb-libvirt-hotplug.sh
DIR=/SAMBA/4T/eldar/AQEMU/usb-devices
USBALLOW=/etc/libvirt/${DOMAIN}.usb
cmdUSB=${DIR}/${SC}
