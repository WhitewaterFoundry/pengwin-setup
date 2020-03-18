#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "ibus" --yesno "Would you like to install ibus for improved non-Latin input via iBus?" 8 65) then
	echo "Installing ibus"
	echo "sudo apt-get install ibus-gtk* ibus fonts-noto-cjk fonts-noto-color-emoji dbus-x11 zenity -y"
	sudo apt-get install ibus '^ibus-gtk*' fonts-noto-cjk fonts-noto-color-emoji dbus-x11 zenity -y
	FCCHOICE=$(whiptail --title "iBus engines" --checklist --separate-output "Select iBus engine:" 15 65 8 \
	"sunpinyin" "Chinese sunpinyin" off \
	"libpinyin" "Chinese libpinyin" off \
	"pinyin" "Chinese pinyin" off \
	"rime" "Chinese rime" off \
	"chewing" "Chinese chewing" off \
	"mozc" "Japanese mozc" on \
	"kkc" "Japanese kkc" off \
	"hangul" "Korean hangul" off \
	"unikey" "Vietnamese unikey" off \
	"table" "Tables (Includes all available tables)" off 3>&1 1>&2 2>&3
)

	if [[ $FCCHOICE == *"sunpinyin"* ]] ; then
		sudo apt-get install ibus-sunpinyin -y
	fi

	if [[ $FCCHOICE == *"libpinyin"* ]] ; then
		sudo apt-get install ibus-libpinyin -y
	fi

	if [[ $FCCHOICE == *"rime"* ]] ; then
		sudo apt-get install ibus-rime -y
	fi

	if [[ $FCCHOICE == *"pinyin"* ]] ; then
		sudo apt-get install ibus-pinyin -y
	fi

	if [[ $FCCHOICE == *"chewing"* ]] ; then
		sudo apt-get install ibus-chewing -y
	fi

	if [[ $FCCHOICE == *"mozc"* ]] ; then
		sudo apt-get install ibus-mozc mozc-utils-gui -y
	fi

	if [[ $FCCHOICE == *"kkc"* ]] ; then
		sudo apt-get install ibus-kkc -y
	fi

	if [[ $FCCHOICE == *"hangul"* ]] ; then
		sudo apt-get install ibus-hangul -y
	fi

	if [[ $FCCHOICE == *"unikey"* ]] ; then
		sudo apt-get install ibus-unikey -y
	fi

	if [[ $FCCHOICE == *"tables"* ]] ; then
		sudo apt-get install ibus-table '^ibus-table-*' -y
	fi

	echo "Setting environmental variables"
	export XIM=ibus
	export XIM_PROGRAM=/usr/bin/ibus
	export QT_IM_MODULE=ibus
	export GTK_IM_MODULE=ibus
	export XMODIFIERS=@im=ibus
	export DefaultIMModule=ibus

	echo "Saving environmental variables to /etc/profile.d/ibus.sh"
	sudo sh -c 'echo "export XIM=ibus" >> /etc/profile.d/ibus.sh'
	sudo sh -c 'echo "export XIM_PROGRAM=/usr/bin/ibus" >> /etc/profile.d/ibus.sh'
	sudo sh -c 'echo "export QT_IM_MODULE=ibus" >> /etc/profile.d/ibus.sh'
	sudo sh -c 'echo "export GTK_IM_MODULE=ibus" >> /etc/profile.d/ibus.sh'
	sudo sh -c 'echo "export XMODIFIERS=@im=ibus" >> /etc/profile.d/ibus.sh'
	sudo sh -c 'echo "export DefaultIMModule=ibus" >> /etc/profile.d/ibus.sh'

	if (whiptail --title "ibus daemon" --yesno "Would you like Setup iBus now? WARNING: Requires an X server to be running or it will generate errors." 9 70) then
		echo "Setting up iBus"
		ibus-daemon -x -d
		ibus-setup
		pkill ibus-daemon
		ibus-daemon -x -d
	else
		echo "Skipping ibus setup"
		whiptail --title "Note about ibus Setup" --msgbox "You will need to run \n$ ibus-daemon -drx\n$ dbus-launch ibus-setup\n to setup iBus before running GUI apps." 8 85
	fi

	if (whiptail --title "ibus daemon" --yesno "Would you like iBus daemon to run each time you open Pengwin? WARNING: Requires an X server to be running or it will generate errors." 9 70) then
		echo "Placing ibus-daemon in /etc/profile.d/ibus.sh"
		sudo sh -c 'echo "ibus-daemon -drx > /dev/null 2>&1" >> /etc/profile.d/ibus.sh'
	else
		echo "Skipping ibus-daemon"
		whiptail --title "Note about ibus-daemon" --msgbox "You will need to run $ ibus-daemon -drx to enable iBus before running GUI apps." 8 85
	fi
else
	echo "Skipping ibus"
fi
