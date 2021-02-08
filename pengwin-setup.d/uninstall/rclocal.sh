#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main()
{

echo "Removing rc.local support"

echo "Removing sudoers modifications..."
sudo_rem_file "/etc/sudoers.d/rclocal"

echo "Removing profile modifications..."
sudo_rem_file "/etc/profile.d/rclocal.sh"

}

if show_warning "rc.local" "$@" ; then
	main "$@"
fi
