#!/bin/bash
# PXE server conf. script...
exec > >(tee /home/$USER/log.txt)






clear
echo -e "
PXE server setup script
For BIOS and UEFI, Debian 11 installation image
Before starting, change the network adapter settings to a static address
You need to set the address:

192.168.0.2
255.255.255.0
192.168.0.0

and you need to determine on which port you want to listen

Installing the necessary components
and running the script

The script will also allow you to set the IP address
later in the program

Press any key to continue ...
or CTRL-C to cancel "
read -n 1 -s -r -p  ""

clear
echo -e "
------------------------
Installing req. in a moment...
------------------------
"
printf "
----Requirment----	----Extra----
syslinux-common		lynx
syslinux-efi		network-manager
isc-dhcp-server		rsync
tftpd-hpa		
pxelinux
lighttpd
nfs-kernel-server


"

for i in `seq 1 9`;
        do
                echo -ne "   $i..." \\r
        	sleep 1
        done    




sudo apt-get update
packages=$(printf "

syslinux-common
syslinux-efi
isc-dhcp-server
tftpd-hpa
pxelinux
network-manager
rsync
lighttpd
nfs-kernel-server")


sudo apt-get -y install $packages

echo -e "
------------------------
DHCP script running now.
------------------------
"
bash ./script/dhcp.sh
echo -e "
------------------------
Now running TFTP
------------------------
"
bash ./script/tftp.sh
echo -e "
------------------------
copying necassary files
------------------------
"
bash ./script/copy.sh

echo -e "
------------------------
Downloading ISO
------------------------
"
bash ./script/debian_install.sh


echo -e "
------------------------
Live ISO Downloaded
------------------------
"

echo ""
echo ""
echo "Download Live Debian ISO" 
echo "and add it to the PXE server? [y/N] "


while read -r -p " " debiso
do
if [[ "$debiso" =~ ^([yY][eE][sS]|[yY]|[tT])$ ]]
then
	bash ./script/debian_live.sh
	
	echo "Download another image?  [y/N]"
	continue

else

	echo "Thank You"
fi
break
done

echo -e "
------------------------
Network Settings
------------------------
"
echo -e "

Remember your network settings
Address must be set:

192.268.0.2
255.255.255.0
192.168.0.0

and you need to determine on which port you want to listen " "


de=$(echo $DESKTOP_SESSION)


if [[ "$de" != "" ]]
then
	bash ./script/nmcli.sh
else
	bash ./script/interfaces.sh
fi


echo ""
echo "------------------------------------------"
echo ""
echo "Press [Enter] to quit..."
echo ""
echo "------------------------------------------"
read -p ""
sudo systemctl restart isc-dhcp-server.service 



printf "

log saved to /home/$USER/log.txt

To Edit The Menu Use:
/srv/tftp/uefi_menu_edit
and
/srv/tftp/bios_menu_edit
"
sudo systemctl restart lighttpd.service 
sleep 3
sudo systemctl restart tftpd-hpa.service 
