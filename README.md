PiSpot
=======
pi hotspot creation automatique
================================

extension of https://github.com/cymplecy/pispot/

Work towards the automatic creation of hotspots in a Pi collective :)

At the moment:

Run install_pispot.sh

The pi will reboot.

By default it will create a hotspot called pispot with the psk of pispotcode

Edit /boot/ssid.txt and enter your desired AP details. Each on a seperate line with the following format: <ssid>,<psk>

Edit /boot/hotspot.txt with the details of your required hotspot. Each on a seperate line with the following format: <hotspot name>,<desired gateway>,<psk>

Have a look in the dmesg output for any pispot messages

Current hardware that seems to work is:

Ralink Technology, Corp. RT5370 Wireless Adapter

0bda:8191 Realtek Semiconductor Corp. 8191SU


***Still work in progress***
