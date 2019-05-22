#!/bin/bash

source $(dirname "$0")/../common.sh "$@"

function show_warning()
{

# Usage: show_warning <INSTALL_ITEM> <INSTALL_DIR>
if whiptail --title "!! $1 !!" --yesno "Are you sure you would like to uninstall $1?\n\nWhile you can reinstall $1 again from pengwin-setup, any of your own files in the '$2' install directory WILL BE PERMANENTLY DELETED.\n\nSelect 'yes' if you would like to proceed" 14 85 ; then
	if whiptail --title "!! $1 !!" --yesno "Are you absolutely sure you'd like to proceed in uninstalling $1?" 7 85
	
	fi
else
	echo "User cancelled"
	
fi

}

show_warning "rbenv" "$HOME/.rbenv"
