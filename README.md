# usb-libvirt-hotplug
Initially this script was a clone of this project: https://github.com/olavmrk/usb-libvirt-hotplug
But in my case I could not attache USB device over UDEV rules.
My script does not need any modification to UDEV rules, it uses the <b>lsusb</b> command instead.
  <h1>How it works</h1>
The main daemon checks once in every five seconds if the host machine is running. If yes it starts the main script to serve the USB connections. The main script checks every second the USB devices and if it finds the matching device from the listing file it connects this device to host machine. If the device is unplugged the main script removes the device from the host machine. On the turning off the host machine the all connected USB devices are removed automatically.
You can edit the listing file anytime even when your host machine is running. All the information will be updated uptime.
<h1>How it install (Ubuntu and family members)</h1>
<ul>
  <li>
    copy the files to any folder on the server
  </li>
  <li>
    open the configuration file <b>config.sh</b> and edit the needed information:
    <pre>
DOMAIN="<b>win7-64-modules</b>" <i>you host domain name</i>
SC=<b>usb-libvirt-hotplug.sh</b> <i>the main script name - you can keep the original name</i>
DIR=<b>/SAMBA/4T/eldar/AQEMU/usb-devices</b> <i>the absolute path to the folder where are the all the scripts located</i>
USBALLOW=<b>/etc/libvirt/${DOMAIN}.usb</b> <i>the location of the file with the list of the all the USB devices you want to be connected to your host machine - the listing file</i>
cmdUSB=${DIR}/${SC} <i>the path and the script name to launch when your host machine is running</i>
    </pre>
  </li>
  <li>
    the content of the file with the list of USB devices to be connected to you host machine (i.e. the file <b>/etc/libvirt/${DOMAIN}.usb</b>) consists of the values of <b>DeviceID</b>:<b>VendorID</b>:
    <pre>
<b>2013:0001</b>
2013:0002
0416:9391
1908:2070
    </pre>
    You can get the needed values of <b>DeviceID</b>:<b>VendorID</b> of your USB device from <b>lsusb</b> command:
    <pre>
root@mice:/home/eldar/build# lsusb
Bus 002 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 005: ID <b>2013:0001</b> PCTV Systems 
Bus 001 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    </pre>
  </li>
  <li>open file <b>usb-libvirt-hotplug.service</b> for editing:
  <pre>
[Unit]
Description=usb-libvirt-hotplug bg listener

[Service]
User=root
Group=root
Type=idle

WorkingDirectory=/SAMBA/4T/eldar/AQEMU/usb-devices/ <i>the absolute path to the folder where are the all the scripts located</i>
ExecStart=/SAMBA/4T/eldar/AQEMU/usb-devices/usb-libvirt-hotplug.run.sh <i>the location of the file with the list of the all the USB devices you want to be connected to your host machine</i>

[Install]
WantedBy=multi-user.target
  </pre>
  </li>
    <li>start up the script on server booting
      <pre>
cp usb-libvirt-hotplug.service /lib/systemd/system/
systemctl enable usb-libvirt-hotplug.service
systemctl daemon-reload
service usb-libvirt-hotplug start
      </pre>
    </li>
    <ul>
