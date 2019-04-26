#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "HOMEBREW" --yesno "Would you like to download and install the Homebrew package manager? Transitioning macOS users may find this more familiar, and others may use this to install both software not provided by APT, or newer versions of software not yet in APT repositories." 12 85) then
	echo "Installing Homebrew"
	whiptail --title "HOMEBREW" --msgbox "Please note, with Homebrew you can install many of the same packages at the same time as those offered by APT, or even offered by pengwin-setup. This is possible as Homebrew installs packages locally to:\n/home/linuxbrew\nTo allow forcing use of packages installed by a specific source, you may add an alias to them in:\n/etc/profile.d/99-alias-overrides.sh" 14 85
	sudo bash -c ''

	# Check we have correct dependencies installed for brew
	echo "Installing Homebrew dependencies"
	sudo apt-get install -y -q build-essential curl file git

	whiptail --title "HOMEBREW" --msgbox "Please press enter when asked to continue by the Homebrew installer." 7 85
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

	echo "Adding Homebrew to system path"
	sudo bash -c 'echo "eval \$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" > /etc/profile.d/brew.sh'
	bash /etc/profile.d/brew.sh

	whiptail --title "HOMEBREW" --msgbox "Please note, Homebrew does record and share analytics information (more information here: https://docs.brew.sh/Analytics.html). To opt-out, type:\n\`brew analytics off\`" 9 85
else
	echo "Skipping HOMEBREW"
fi
