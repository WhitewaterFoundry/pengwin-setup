#!/bin/bash

if (whiptail --title "Windows 10 Theme" --yesno "Would you like to install a Windows 10 theme? (including lxappearance, a GUI application to set the theme)" 8 70) then
	echo "Installing Windows 10 theme"
	# Source files locations
	W10LIGHT_URL="https://github.com/B00merang-Project/Windows-10/archive/master.zip"
	W10DARK_URL="https://github.com/B00merang-Project/Windows-10-Dark/archive/master.zip"
	INSTALLDIR="/usr/share/themes"
	LIGHTDIR="windows-10-light"
	DARKDIR="windows-10-dark"

	echo "$ sudo apt-get install unzip -y"
	sudo apt-get install unzip -y

	# Download themes to temporary folder (sub folders for light & dark) then unzip
	echo "Downloading themes to temporary folder"
	createtmp

	wget ${W10LIGHT_URL} -O master-light.zip -q --show-progress
	echo "Unzipping master-light.zip..."
	unzip -qq master-light.zip

	wget ${W10DARK_URL} -O master-dark.zip -q --show-progress
	echo "Unzipping master-dark.zip..."
	unzip -qq master-dark.zip

	if [[ ! -d "${INSTALLDIR}" ]] ; then
		echo "${INSTALLDIR} does not exist, creating"
		sudo mkdir -p $INSTALLDIR
	fi

	if [[ -d "${INSTALLDIR}/${LIGHTDIR}" ]] ; then
		echo "${INSTALLDIR}/${LIGHTDIR} already exists, removing old"
		sudo rm -r $INSTALLDIR/$LIGHTDIR
	fi

	if [[ -d "${INSTALLDIR}/${DARKDIR}" ]] ; then
		echo "${INSTALLDIR}/${DARKDIR} already exists, removing old"
		sudo rm -r $INSTALLDIR/$DARKDIR
	fi

	# Move to themes folder
	echo "Moving themes to ${INSTALLDIR}"
	sudo mv Windows-10-master "${INSTALLDIR}/${LIGHTDIR}"
	sudo mv Windows-10-Dark-master "${INSTALLDIR}/${DARKDIR}"

	# Set correct permissions
	echo "Setting correct theme folder permissions"
	sudo chown -R root:root "${INSTALLDIR}/${LIGHTDIR}"
	sudo chown -R root:root "${INSTALLDIR}/${DARKDIR}"
	sudo chmod -R 0755 "${INSTALLDIR}/${LIGHTDIR}"
	sudo chmod -R 0755 "${INSTALLDIR}/${DARKDIR}"

	# Install lxappearance to let user set theme
	sudo apt-get install -q -y lxappearance

	# Cleanup
	cleantmp
	whiptail --title "Set Windows 10 theme" --msgbox "To set the either of the Windows 10 light/dark themes:\nRun 'lxappearance', choose from the list of installed themes and click apply. You may change the theme in this way at anytime, including fonts and cursors." 9 90
else
	echo "Skipping Windows 10 theme install"
fi
