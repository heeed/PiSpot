PiSpot
=======
pi hotspot creation automatique
================================

extension of https://github.com/cymplecy/pispot/

Work towards the automatic creation of hotspots in a Pi collective :)

Installation:

Run install_pispot.sh

The pi will reboot.

What Next?

Upon boot the Pi will attempt to connect to any ssid's defined in /boot/ssid.txt. If it cannot connect it will then automatically create a hotspot.

By default the hotspot is called pispot with the psk of pispotcode


Edit /boot/ssid.txt and enter your desired AP details. Each on a seperate line with the following format: ssid,psk,comment

Edit /boot/hotspot.txt with the details of your required hotspot. Each on a seperate line with the following format: hotspot name,desired gateway,psk

Issues:

Have a look in the dmesg output for any pispot messages


Current hardware that seems to work is:

Ralink Technology, Corp. RT5370 Wireless Adapter

0bda:8191 Realtek Semiconductor Corp. 8191SU

Official Raspberry Pi wifi dongle


***Still work in progress***
