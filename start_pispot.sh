#!/bin/bash
# RPi SSID Scanner
# from code by Lasse Christiansen http://lcdev.dk

#ssid to search for 
#ssids=( 'CYCY' 'ClassPi' )

getSSID() {

 if [ ! -f $1 ]; then
  echo "pispot: SSID's not found...exiting">/dev/kmsg
  exit 1 
  else
  i=0
    while read line # Read a line
    do
        ssids[i]=$line # Put it into the array
        i=$(($i + 1))
    done < $1
 fi
}

wlanStatic(){


IP4_INT=wlan0
IP4_CONF_TYPE=static
IP4_ADDRESS=192.168.2.1
IP4_NETMASK=255.255.255.0

IP4_NETWORK=${IP4_ADDRESS%?}0
IP4_BROADCAST=${IP4_ADDRESS%?}255
IP4_GATEWAY=${IP4_ADDRESS}

mv /etc/network/interfaces /etc/network/interfaces.bak

echo "

    auto lo
    iface lo inet loopback

    #auto eth0
    allow-hotplug eth0
    iface eth0 inet dhcp
    


    auto $IP4_INT
    iface $IP4_INT inet $IP4_CONF_TYPE
    address $IP4_ADDRESS
    netmask $IP4_NETMASK
    broadcast $IP4_BROADCAST
    gateway $IP4_GATEWAY
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf">>/etc/network/interfaces
}

wlanDHCP(){
#needs encoded psk entered below after the wpa-ssid $1. see https://wiki.debian.org/WiFi/HowToUse#WPA-PSK_and_WPA2-PSK

echo "pispot: swapping in $1 interfaces file">/dev/kmsg
IP4_INT=wlan0
IP4_CONF_TYPE=dhcp

mv /etc/network/interfaces /etc/network/interfaces.bak
echo "wpa-ssid $1"
echo "

    auto lo
    iface lo inet loopback

    #auto eth0
    allow-hotplug eth0
    iface eth0 inet dhcp


    auto $IP4_INT
    iface $IP4_INT inet $IP4_CONF_TYPE
    wpa-ssid $1
    wpa-psk  

">>/etc/network/interfaces
}
 
createAdHocNetwork(){
	echo "in create adhoc"
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

getSSID "/boot/ssid.txt"


for ssid in "${ssids[@]}"
do
    echo "pispot; looking for $ssid">/dev/kmsg
    if iwlist wlan0 scan | grep $ssid > /dev/null
    then
        ifdown --force wlan0
        echo " ">/var/lib/dhcpd/dhcpd.leases
        rm /var/lib/dhcpd/dhcpd.leases~
        wlanDHCP $ssid
	ifup wlan0
	if dhclient -1 wlan0
        then
            echo "pispot: Connected to hotspot $ssid: " > /dev/kmsg
            connected=true
            break
         else
            echo "pispot: $ssid Hotspot not found" > /dev/kmsg
            wpa_cli terminate
            break
	fi
    fi
done
 
if ! $connected; then
    echo "pispot: creating hotspot" > /dev/kmsg
    wlanStatic
    echo "pispot: about to create Ad hoc network" >/dev/kmsg
    if createAdHocNetwork; then
	echo "pispot: hotspot created" > /dev/kmsg
    else
	echo "pispot: hotspot failed" > /dev/kmsg
    fi
fi
 
exit 0

