#!/bin/bash 

#pispot autostart script. s/l to /etc/rcd.3


ifdown wlan0
ifup wlan0
/etc/init.d/isc-dhcp-server start
/etc/init.d/hostapd restart

