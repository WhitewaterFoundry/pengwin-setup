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

function clean_initfile()
{

# Usage: clean_initfile <INITFILE> <REGEX>

# Following n (node version manager) install script,
# best to clean init file by writing to memory then
# writing back to file
local initFileContents
initFileContents=$(grep -Ev "$2" "$1")
printf '%s' "$initFileContents" > "$1"

}

function remove_package()
{

# Usage: remove_package <PACKAGE>
echo "Removing APT package: $1"
if dpkg-query -s "$1" | grep 'installed' > /dev/null 2>&1 ; then
	sudo apt-get remove -y -q --autoremove "$1"
else
	echo "... not installed!"
fi

}

function remove_source()
{

# Usage: remove_source <SOURCENAME> <GPGKEY>
local sourceFile="/etc/apt/sources.list.d/$1.list"

echo "Removing APT source: $1"
if [[ -f "$sourceFile" ]] ; then
	sudo rm -f "$sourceFile"
else
	echo "... not found!"
fi

echo "Removing APT key: $2"
sudo apt-key del "$2"

}
