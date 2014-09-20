#!/bin/bash

#pispot removal script
###########################
#
#Uninstalls the pispot system
#
###########################


sudo mv /etc/network/interfaces.bak /etc/network/interfaces
sudo rm /usr/share/pispot/start_pispot.sh
sudo sed -i '/start_pispot.sh/d' /etc/rc.local
sudo apt-get purge hostapd isc-dhcp-server
