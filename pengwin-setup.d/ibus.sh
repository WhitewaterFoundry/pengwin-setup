#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "ibus" --yesno "Would you like to install ibus for improved non-Latin input?" 8 65) then
	echo "Installing ibus"
	echo "sudo apt-get install fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11 -y"
	sudo apt-get install fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11 -y
	FCCHOICE=$(whiptail --title "fcitx engines" --checklist --separate-output "Select fcitx engine:" 15 65 8 \
	"sunpinyin" "Chinese sunpinyin" off \
	"libpinyin" "Chinese libpinyin" off \
	"rime" "Chinese rime" off \
	"googlepinyin" "Chinese googlepinyin" off \
	"chewing" "Chinese chewing" off \
	"mozc" "Japanese mozc" on \
	"kkc" "Japanese kkc" off \
	"hangul" "Korean hangul" off \
	"unikey" "Vietnamese unikey" off \
	"sayura" "Sinhalese sayura" off \
	"table" "Tables (Includes all available tables)" off 3>&1 1>&2 2>&3
)

	if [[ $FCCHOICE == *"sunpinyin"* ]] ; then
		sudo apt-get install fcitx-sunpinyin -y
	fi

	if [[ $FCCHOICE == *"libpinyin"* ]] ; then
		sudo apt-get install fcitx-libpinyin -y
	fi

	if [[ $FCCHOICE == *"rime"* ]] ; then
		sudo apt-get install fcitx-rime -y
	fi

	if [[ $FCCHOICE == *"googlepinyin"* ]] ; then
		sudo apt-get install fcitx-googlepinyin -y
	fi

	if [[ $FCCHOICE == *"chewing"* ]] ; then
		sudo apt-get install fcitx-chewing -y
	fi

	if [[ $FCCHOICE == *"mozc"* ]] ; then
		sudo apt-get install fcitx-mozc -y
	fi

	if [[ $FCCHOICE == *"kkc"* ]] ; then
		sudo apt-get install fcitx-kkc fcitx-kkc-dev -y
	fi

	if [[ $FCCHOICE == *"hangul"* ]] ; then
		sudo apt-get install fcitx-hangul -y
	fi

	if [[ $FCCHOICE == *"unikey"* ]] ; then
		sudo apt-get install fcitx-unikey -y
	fi

	if [[ $FCCHOICE == *"sayura"* ]] ; then
		sudo apt-get install fcitx-sayura -y
	fi

	if [[ $FCCHOICE == *"tables"* ]] ; then
		sudo apt-get install fcitx-table fcitx-table-all -y
	fi

	echo "Setting environmental variables"
	export GTK_IM_MODULE=fcitx
	export QT_IM_MODULE=fcitx
	export XMODIFIERS=@im=fcitx
	export DefaultIMModule=fcitx

	echo "Saving environmental variables to /etc/profile.d/fcitx.sh"
	sudo sh -c 'echo "export LC_CTYPE=\"zh_CN.UTF-8\"" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "export XIM=ibus" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "export XIM_PROGRAM=/usr/bin/ibus" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "export QT_IM_MODULE=ibus" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "export GTK_IM_MODULE=ibus" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "export XMODIFIERS=@im=ibus" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "export DefaultIMModule=ibus" >> /etc/profile.d/fcitx.sh'
	sudo sh -c 'echo "ibus-daemon -drx" >> /etc/profile.d/fcitx.sh'


	if (whiptail --title "ibus daemon" --yesno "Would you like iBus daemon to run each time you open Pengwin? WARNING: Requires an X server to be running or it will generate errors." 9 70) then
		echo "Placing fcitx-autostart in /etc/profile.d/fcitx"
		sudo sh -c 'echo "ibus-daemon -drx > /dev/null 2>&1" >> /etc/profile.d/.sh'
	else
		echo "Skipping fcitx-autostart"
		whiptail --title "Note about fcitx-autostart" --msgbox "You will need to run $ fcitx-autostart to enable fcitx before running GUI apps." 8 85
	fi

	whiptail --title "Note about fcitx-config-gtk3" --msgbox "You can configure fcitx later by running $ fcitx-config-gtk3" 8 70
else
	echo "Skipping fcitx"
fi
