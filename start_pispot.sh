#!/bin/bash
#Pi SSID Scanner 
# Part of PiSpot: https://github.com/heeed/hotpi 
# based on code by Lasse Christiansen http://lcdev.dk



getSSIDdetails(){
	echo "pispot: extracting login details">/dev/kmsg
	OLDIFS=$IFS
 	ssid=${ssid[@]}
        IFS=',' read req_ssid req_psk  <<<"$ssid"
}

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


wlanDHCP(){

	echo "pispot: swapping in $1 interfaces file">/dev/kmsg
	IP4_INT=wlan0
	IP4_CONF_TYPE=dhcp

	mv /etc/network/interfaces /etc/network/interfaces.bak
	echo "pispot: wpa-ssid $req_ssid" >/dev/kmsg
	echo "
		auto lo
    		iface lo inet loopback

    		#auto eth0
    		allow-hotplug eth0
    		iface eth0 inet dhcp


    		auto $IP4_INT
    		iface $IP4_INT inet $IP4_CONF_TYPE
    		wpa-ssid $req_ssid
    		wpa-psk  $req_psk

">>/etc/network/interfaces
}


getSSID "/boot/ssid.txt"


for ssid in "${ssids[@]}"
do
    getSSIDdetails $ssid
    echo "pispot; looking for $req_ssid">/dev/kmsg
    if iwlist wlan0 scan | grep $req_ssid > /dev/null
    then
        ifdown --force wlan0
        echo " ">/var/lib/dhcpd/dhcpd.leases
        rm /var/lib/dhcpd/dhcpd.leases~
        wlanDHCP $req_ssid
        ifup wlan0
        if dhclient -1 wlan0
        then
            echo "pispot: Connected to hotspot: $req_ssid" > /dev/kmsg
            break
         else
            echo "pispot: $req_ssid Hotspot not found" > /dev/kmsg
            wpa_cli terminate
            break
        fi
       else
            echo "pispot: no known wireless networks found">/dev/kmsg
    fi
done
exit 0
