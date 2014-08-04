#!/bin/bash

GREEN='\e[00;32m'
DEFT='\e[00m'
RED='\e[00;31m'
YELLOW='\e[00;33m'

function checkfileExists {
#echo $1
if [ ! -f ./$1 ]; then
    #echo "File not found!"
	return 1
else
        #echo "fILE FOUND"
	return 0
fi
}

function checkInternet {
wget -q --tries=3 --timeout=5 http://google.com > /dev/null
if [[ ! $? -eq 1 ]]; then
	return 0
fi
}

#check current user privileges
#  (( `id -u` )) && echo -e "${RED}This script MUST be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1


clear

#check for hostapd

function installPackage {
echo -e "${DEFT}First, lets see if the "$1" packages are installed...\n"

dpkg -l $1 | grep ^ii > /dev/null 2>&1
INSTALLED=$?

if [ $INSTALLED == '0' ]; then
        echo -e "${GREEN}$1 is installed...moving on\n"
    else
        echo -e "${RED}"$1" is not installed...will install now\n"
	    
	if checkfileExists $1*;then
		echo -e "${DEFT}Installing locally"
		dpkg -i $1*
	else
		echo -e "${DEFT}No local copy found...trying for install from the repo's"

		if checkInternet; then
        		echo -e "${RED}Internet not reachable"
		       exit 1
		else
			echo "Installing from repos"
			apt-get install $1
		fi
fi
fi

}
installPackage hostapd
installPackage isc-dhcp-server
#configuration options code to follow


