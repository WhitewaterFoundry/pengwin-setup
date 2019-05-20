#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function sshkey_prompt()
{

let count=0
option_list=""
for i in $1 ; do
	let count+=1
	option_list="$option_list $i \"\" off"
done

let width=85
let height=7+count
execstr="whiptail --title \"KEYCHAIN\" --radiolist \"Pick an SSH key:\" $height $width $count $option_list 3>&1 1>&2 2>&3"
eval $execstr

}

if (whiptail --title "KEYCHAIN" --yesno "Would you like to install Keychain and set it to start on console launch?" 8 85) then
    echo "Installing Keychain"
    sudo apt-get install -q -y keychain

    echo "Checking for user SSH keys..."
    key_list="$(/bin/ls -1 "${HOME}/.ssh" | grep ".\.pub" | sed 's|.pub||g')"
    if [[ "$key_list" != "" ]] ; then
        echo "Offering user SSH selection"
        conf_path="/etc/profile.d/keychain.sh"

        key_list="$(/bin/ls -1 "${HOME}/.ssh" | grep ".\.pub" | sed 's|.pub||g')"
	result=$(sshkey_prompt "$key_list")
	key_path="${HOME}/.ssh/$result"

	echo "eval \`keychain --eval --agents ssh \"$key_path\"\`" | sudo tee $conf_path

        # Copy configuration to fish
        sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"
        sudo cp "${conf_path}" "${__fish_sysconf_dir}"
    else
        whiptail --title "KEYCHAIN" --msgbox "No user SSH keys found. If you create key(s) and would like to cache their password on terminal launch, re-run the Keychain installer under pengwin-setup" 10 85
    fi
else
	echo "Skipping Keychain"
fi
