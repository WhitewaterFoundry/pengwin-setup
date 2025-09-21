#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "SYNAPTIC" --yesno "Would you like to install the Synaptic package manager? This provides a graphical front-end for the APT package management system" 8 80) then
	echo "Installing Synaptic"
	install_packages synaptic lsb-release
else
	echo "Skipping Synaptic"
fi
