#!/bin/bash

source $(dirname "$0")/../common.sh "$@"

function show_warning()
{

# Usage: show_warning <UNINSTALL_ITEM> <UNINSTALL_DIRS> <PREVIOUS_ARGS>
local uninstall_item="$1"
local uninstall_dir="$2"
shift 2

if whiptail --title "!! $uninstall_item !!" --yesno "Are you sure you would like to uninstall $uninstall_item?\n\nWhile you can reinstall $uninstall_item again from pengwin-setup, any of your own files in the $uninstall_dir install directory(s) WILL BE PERMANENTLY DELETED.\n\nSelect 'yes' if you would like to proceed" 14 85 ; then
	if whiptail --title "!! $uninstall_item !!" --yesno "Are you absolutely sure you'd like to proceed in uninstalling $uninstall_item?" 7 85 ; then
		echo "User confirmed $uninstall_item uninstall"
		return
	fi
fi

echo "User cancelled $uninstall_item uninstall"
bash ${SetupDir}/uninstall.sh "$@"

}

function clean_configs()
{

# Usage: clean_bashrc <STRING_TO_CLEAN>

if [[ -f "$HOME/.bashrc" ]] ; then
sed -i "s|||g" "$HOME/.bashrc"
fi

if [[ -f "$HOME/.zshrc" ]] ; then

fi

if [[ -f "$HOME/.config/fish" ]] ; then

fi

}
