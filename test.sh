function checkfileExists {
echo $1
if [ ! -f $1*.deb ]; then
    echo "File not found: "$1*
        return 1
else
        echo "fILE FOUND" $1*
        return 0
fi
}

checkfileExists req_files/hostapd
checkfileExists req_files/isc-dhcp
