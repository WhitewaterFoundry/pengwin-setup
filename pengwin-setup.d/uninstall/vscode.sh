#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling VisualStudio Code"

remove_package "code"

echo "Removing APT source..."
sudo_rem_file "/etc/apt/sources.list.d/vscode.list"

echo "Removing APT key..."
sudo_rem_file "/etc/apt/trusted.gpg.d/microsoft.gpg"

# Undo temporary udev workarounds
echo "Reverting udev VSCode workarounds"
sudo apt-mark unhold udev libudev1
sudo apt-get update
sudo apt-get install -y -q udev libudev1

}

if show_warning "" "" ; then
	main "$@"
fi
