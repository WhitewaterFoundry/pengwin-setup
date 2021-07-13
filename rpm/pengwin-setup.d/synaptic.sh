#!/bin/bash

if (whiptail --title "SYNAPTIC" --yesno "Would you like to install the Synaptic package manager? This provides a graphical front-end for the APT package management system" 8 80) then
	echo "Installing Synaptic"
	sudo apt-get install -y -q synaptic lsb-release
else
	echo "Skipping Synaptic"
fi
