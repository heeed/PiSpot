#!/bin/bash
# RPi SSID Scanner
# from code by Lasse Christiansen http://lcdev.dk

#ssid to search for 
ssids=( 'CYCY' 'ClassPi' )
 
createAdHocNetwork(){
	
	rm /usr/sbin/hostapd
        usblist=`lsusb`
	killall hostapd
        if [[ $usblist == *0bda:8191* ]]||[[ $usblist == *0bda:8176* ]];then
	echo "pispot: rtl8188CUS detected, using alternative hostapd">/dev/kmsg
        ln -s /usr/sbin/hostapd8 /usr/sbin/hostapd
        sed -i '/driver/c#driver=' /etc/hostapd/hostapd.conf
        else
        echo "pispot: Repository hostapd to be used" > /dev/kmsg
        ln -s /usr/sbin/hostapd.other /usr/sbin/hostapd
        sed -i '/driver/c#driver=' /etc/hostapd/hostapd.conf
        fi
	
	
	ifdown wlan0
	ifup wlan0
	ifdown eth0
	ifup eth0
	/etc/init.d/isc-dhcp-server start
	/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
	#/etc/init.d/networking restart
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

