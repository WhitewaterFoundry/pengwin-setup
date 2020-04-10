#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function sshkey_select()
{

let count=0
option_list=""
for i in $1 ; do
	let count+=1
	option_list="$option_list $i \"\" off"
done

let width=85
let height=7+count
execstr="whiptail --title \"KEYCHAIN\" --checklist --separate-output \"Pick an SSH key to automatically load:\" $height $width $count $option_list 3>&1 1>&2 2>&3"
result=$(eval $execstr)

if [[ $? != 0 ]] ; then
	echo "User cancelled"
	return
fi

if [[ "$result" == "" ]] ; then
	if whiptail --title "KEYCHAIN" --yesno "No SSH keys selected, would you like to go back and try again?" 10 85 ; then
		echo "Repeat SSH key prompt"
		sshkey_select "$@"
	fi
else
	conf_path="/etc/profile.d/keychain.sh"
	sudo rm -f $conf_path # remove old config file if present
	for i in $result ; do
		key_path="${HOME}/.ssh/$i"
		echo "eval \`keychain --eval --agents ssh \"$key_path\"\`" | sudo tee -a $conf_path
	done

	# Copy configuration to fish
	sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"
	sudo cp "${conf_path}" "${__fish_sysconf_dir}"
fi

}

if (whiptail --title "KEYCHAIN" --yesno "Would you like to install Keychain and set it to load an SSH key of your choice on terminal launch?" 8 85) then
    echo "Installing Keychain"
    sudo apt-get install -q -y keychain

    echo "Checking for user SSH keys..."
    key_list="$(/bin/ls -1 "${HOME}/.ssh" | grep ".\.pub" | sed 's|\.pub||g')"
    if [[ "$key_list" != "" ]] ; then
        echo "Offering user SSH selection"
	sshkey_select "$key_list"
    else
        whiptail --title "KEYCHAIN" --msgbox "No user SSH keys found. If you create key(s) and would like to cache their password on terminal launch, re-run the Keychain installer under pengwin-setup" 10 85
    fi
else
	echo "Skipping Keychain"
fi
