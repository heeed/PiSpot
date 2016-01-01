#!/bin/bash
#Pi SSID Scanner 
# Part of PiSpot: https://github.com/heeed/hotpi 
# based on code by Lasse Christiansen http://lcdev.dk


getSSIDdetails(){
	echo "pispot: extracting login details">/dev/kmsg
	OLDIFS=$IFS
 	ssid=${ssid[@]}
        IFS=',' read req_ssid req_psk comment  <<<"$ssid"
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

getHotspotSSID(){

      if [ ! -f $1 ]; then
                echo "pispot: SSID's not found...exiting">/dev/kmsg
                exit 1
        else
		while read line 
		do
			if [[ $line =~ $'\r' ]]; then
		       		line2=$(echo $line | sed $'s/\r//')
				line=$line2
                	fi
        
	        OLDIFS=$IFS
		IFS=',' read hotspot_SSID hotspot_IP hotspot_PSK <<< "$line"
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


allow-hotplug eth0
iface eth0 inet dhcp


auto $IP4_INT
iface $IP4_INT inet $IP4_CONF_TYPE
wpa-ssid $req_ssid
wpa-psk  $req_psk

">>/etc/network/interfaces
}

wlanStatic(){


IP4_INT=wlan0
IP4_CONF_TYPE=static
IP4_ADDRESS=$hotspot_IP
IP4_NETMASK=255.255.255.0

IP4_NETWORK=${IP4_ADDRESS%?}0
IP4_BROADCAST=${IP4_ADDRESS%?}255
IP4_GATEWAY=$hotspot_IP

mv /etc/network/interfaces /etc/network/interfaces.bak

echo "
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp
    
auto $IP4_INT
iface $IP4_INT inet $IP4_CONF_TYPE
address $IP4_ADDRESS
netmask $IP4_NETMASK
broadcast $IP4_BROADCAST
gateway $IP4_GATEWAY
#wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf">>/etc/network/interfaces
}

createAdHocNetwork(){
	
	getHotspotSSID "/boot/hotspot.txt"

	echo "pispot: creating hotspot">/dev/kmsg
	sed -i '/driver/c#driver=' /etc/hostapd/hostapd.conf
        sed -i '/ssid=/cssid='$hotspot_SSID'' /etc/hostapd/hostapd.conf
        sed -i '/wpa_passphrase=/cwpa_passphrase='$hotspot_PSK'' /etc/hostapd/hostapd.conf
	
        sed -i '/subnet /,$d' /etc/dhcp/dhcpd.conf
	echo 'subnet '${hotspot_IP%?}0 ' netmask 255.255.255.0 {
  range '${hotspot_IP%?}5' '${hotspot_IP%?}100'; 
}' >> /etc/dhcp/dhcpd.conf	

	rm /usr/sbin/hostapd
        usblist=`lsusb`
	killall hostapd
        
        if [[ $usblist == *0bda:8191* ]]||[[ $usblist == *0bda:8176* ]];then
	  echo "pispot: rtl8188CUS detected, using alternative hostapd">/dev/kmsg
          ln -s /usr/sbin/hostapd8 /usr/sbin/hostapd
        else
          echo "pispot: Repository hostapd to be used" > /dev/kmsg
          ln -s /usr/sbin/hostapd.other /usr/sbin/hostapd
        fi
	
	wlanStatic
	ifdown wlan0
	ifup wlan0
	ifdown eth0
	ifup eth0
echo -e "networks up and down\n"
echo -e "starting dhcpd \n"
	/etc/init.d/isc-dhcp-server start
echo -e "dhcp started\n"
echo -e "hostapd coming up\n"
	/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
echo -e "hostapd up\n"
}


getSSID "/boot/ssid.txt"

echo " ">/var/lib/dhcp/dhcpd.leases
rm /var/lib/dhcp/dhcpd.leases~

needHotspot=1
for ssid in "${ssids[@]}"
do
    getSSIDdetails $ssid
    echo "pispot; looking for $req_ssid">/dev/kmsg
    if iwlist wlan0 scan | grep $req_ssid > /dev/null
    then
        ifdown --force wlan0
        wlanDHCP $req_ssid > /dev/null
        ifup wlan0
        if dhclient -1 wlan0 > /dev/null
        then
            echo "pispot: Connected to hotspot: $req_ssid" > /dev/kmsg
            needHotspot=0
            break
         else
            echo "pispot: $req_ssid Hotspot not found" > /dev/kmsg
            wpa_cli terminate
            break
        fi
    fi
done

if [[ `cat /etc/*-release | grep jessie` ]]
then 
	systemctl disable avahi-daemon.service
fi

if [[ "$needHotspot" -eq 1 ]]
then
   echo "pispot: no known wireless networks found,,,starting a hotspot">/dev/kmsg
   if createAdHocNetwork; then
        echo "pispot: hotspot created" > /dev/kmsg
	/etc/init.d/isc-dhcp-server start
   else
        echo "pispot: hotspot failed" > /dev/kmsg
   fi
fi

exit 0

