#!/bin/bash

#pispot removal script
###########################
#
#Uninstalls the pispot system
#
###########################


cp /usr/share/pispot/backup/interfaces /etc/network/interfaces
cp /usr/share/pispot/backup/ifplugd /etc/default/ifplugd
cp /usr/share/pispot/backup/dhcpd.conf /etc/dhcp/dhcp.conf
cp /usr/share/pispot/backup/dhclient.conf /etc/dhcp/dhclient.conf

rm -rf /etc/hostapd
sed -i '/start_pispot.sh/d' /etc/rc.local

apt-get purge -y hostapd isc-dhcp-server

if [[ `cat /etc/*-release | grep jessie` ]]
then
        systemctl enable avahi-daemon.service
fi

rm -rf /usr/share/pispot

reboot
