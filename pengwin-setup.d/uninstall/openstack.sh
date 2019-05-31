#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function sudo_pip_remove()
{

# Usage: sudo_pip_remove <PACKAGE>
echo "Removing $@"
if pip --version > /dev/null 2>&1 ; then
	if pip list | grep "$@" > /dev/null 2>&1 ; then
		sudo pip uninstall "$@"
		return
	fi
fi

echo "... not installed!"

}

function main()
{

echo "Uninstalling OpenStack CLI"

sudo_pip_remove "python-openstackclient"

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/osc.bash_completion"

}

if show_warning "" "" ; then
	main "$@"
fi
