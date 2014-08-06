#!/bin/bash
# RPi SSID Scanner
# from code by Lasse Christiansen http://lcdev.dk

#ssid to search for 
ssids=( 'CYCY' 'ClassPi' )
 
createAdHocNetwork(){
	ifdown wlan0
	ifup wlan0
	/etc/init.d/isc-dhcp-server start
	hostapd -B /etc/hostapd/hostapd.conf
}
 

connected=false
for ssid in "${ssids[@]}"
do
    if iwlist wlan0 scan | grep $ssid > /dev/null
    then
        if dhclient -1 wlan0
        then
            echo "pispot: Connected to hotspot: " > /dev/kmsg
            connected=true
            break
        else
            echo "pispot: Hotspot not found" > /dev/kmsg
            wpa_cli terminate
            break
        fi
    
    fi
done
 
if ! $connected; then
    echo "pispot: creating hotspot" > /dev/kmsg
    if createAdHocNetwork; then
	echo "pispot: hotspot created" > /dev/kmsg
    else
	echo "pispot: hotspot failed" > /dev/kmsg
    fi
fi
 
exit 0

