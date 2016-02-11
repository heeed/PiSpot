#!/bin/bash

#pispot installation script
###########################
#
#Installs the pispot system
#
###########################


#user configuration options

GREEN='\e[00;32m'
DEFT='\e[00m'
RED='\e[00;31m'
YELLOW='\e[00;33m'

#check current user privileges
(( `id -u` )) && echo -e "${RED}This script MUST be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1
clear

#check for hostapd
apt-get update
apt-get install isc-dhcp-server isc-dhcp-common hostapd libnl-dev

#installed, so now for configuration

#intstall the start script, backup exisiting config files and copy uninstall script
mkdir -p /usr/share/pispot/backup
cp start_pispot.sh /usr/share/pispot
chmod +x /usr/share/pispot/start_pispot.sh
chown -R root:root /usr/share/pispot
cp /etc/network/interfaces /usr/share/pispot/backup
cp /etc/default/ifplugd /usr/share/pispot/backup
cp /etc/dhcp/dhcpd.conf /usr/share/pispot/backup
cp /etc/dhcp/dhclient.conf /usr/share/pispot/backup
cp ./uninstall_pispot.sh /usr/share/pispot

#set up files in boot.
#ssid.txt for ssid info, hotspot.txt for hotspot info
touch /boot/ssid.txt
touch /boot/hotspot.txt
echo "testssid,testcode">>/boot/ssid.txt
echo "pispot,192.168.2.1,pispotcode">/boot/hotspot.txt

#set up hostapd and configuration
#first copy hostapd v2 and then copy hostapd v 0.8

cp ./req_files/hostapd2/hostapd /usr/sbin/hostapd.other
cp ./req_files/new-hostapd/hostapd8 /usr/sbin/hostapd8

mkdir -p /etc/hostapd
#cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
cp ./hostapd.conf /etc/hostapd/
chown root:root /etc/hostapd/hostapd.conf

#setup dhcp server

cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
#cp ./isc-dhcp-server /etc/default/isc-dhcp-server
sudo sed -i '/#DHCPD_CONF/c\DHCPD_CONF=/etc/dhcp/dhcpd.conf' /etc/default/isc-dhcp-server
sudo sed -i '/INTERFACES=""/c\INTERFACES="wlan0"' /etc/default/isc-dhcp-server

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
cp ./dhcpd.conf /etc/dhcp/dhcpd.conf
chown root:root /etc/dhcp/dhcpd.conf
cp /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
cp ./dhclient.conf /etc/dhcp/dhclient.conf
chown root:root /etc/dhcp/dhclient.conf

#kill any autostart..these will be started as and when required by the script

update-rc.d -f hostapd remove
update-rc.d -f isc-dhcp-server remove

#setup ifplugd

rm /etc/default/ifplugd
cp ifplugd /etc/default/ifplugd

#sort out autostart of pispot
echo "Setting up autostart of pispot"
sed -i '$i/usr/share/pispot/start_pispot.sh' /etc/rc.local

#reboot the pi
reboot
