PiSpot
=======
pi hotspot creation automatique
================================

extension of https://github.com/cymplecy/pispot/

Work towards the automatic creation of hotspots in a Pi collective :)

At the moment:

Run install_pispot.sh

Create /boot/ssid.txt with a list of ssids to search for. Each one on a seperate line.

At the moment put the PSK key into the wlanDHCP() function. Have a look at https://wiki.debian.org/WiFi/HowToUse#WPA-PSK_and_WPA2-PSK for info

Reboot the Pi

Look for an access point called MY_AP Password is: test1234

Have a look in the dmesg output for any pispot messages

Current hardware that seems to work is:

Ralink Technology, Corp. RT5370 Wireless Adapter

0bda:8191 Realtek Semiconductor Corp. 8191SU


***Still work in progress***
