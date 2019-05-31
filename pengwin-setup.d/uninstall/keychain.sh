#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Keychain and profile modifications"

echo "Removing profile modification..."
sudo_rem_file "/etc/profile.d/keychain.sh"

remove_package "keychain"

}

if show_warning "" "" ; then
	main "$@"
fi
