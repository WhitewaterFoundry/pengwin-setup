#!/bin/bash

if (whiptail --title "GUI Libraries" --yesno "Would you like to install a base set of libraries for GUI applications?" 8 75) then
	echo "Installing GUILIB"
	echo "$ apt-get install -t testing xclip gnome-themes-standard gtk2-engines-murrine dbus dbus-x11 -y"
	sudo apt-get install -t testing xclip gnome-themes-standard gtk2-engines-murrine dbus dbus-x11 -y
	echo "Configuring dbus if you already had it installed. If not, you might see some errors, and that is okay."
	#stretch
	sudo touch /etc/dbus-1/session.conf
	sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /etc/dbus-1/session.conf
	sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /etc/dbus-1/session.conf
	sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /etc/dbus-1/session.conf
	#sid
	sudo touch /usr/share/dbus-1/session.conf
	sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /usr/share/dbus-1/session.conf
	sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /usr/share/dbus-1/session.conf
	sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /usr/share/dbus-1/session.conf
else
	echo "Skipping GUILIB"
fi
