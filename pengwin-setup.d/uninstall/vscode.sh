#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling VisualStudio Code"

remove_package "code"
remove_package "code-insiders"
rem_dir "$HOME/.vscode"

echo "Removing APT source..."
sudo_rem_file "/etc/apt/sources.list.d/vscode.list"

echo "Removing Microsoft APT key..."
safe_rem_microsoftgpg

# Undo temporary udev workarounds
echo "Reverting udev VSCode workarounds"
sudo apt-mark unhold udev libudev1
sudo apt-get update
sudo apt-get install -y -q udev libudev1

echo "Removing Debian stable APT source..."
safe_rem_debianstablesrc

echo "Regenerating start-menu entry cache..."
bash ${SetupDir}/shortcut.sh --yes

}

if show_warning "VisualStudio Code" "$@" ; then
	main "$@"
fi
