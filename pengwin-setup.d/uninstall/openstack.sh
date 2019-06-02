#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling OpenStack CLI"

sudo_pip_uninstall "python-openstackclient"

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/osc.bash_completion"

}

if show_warning "OpenStack CLI" "$@" ; then
	main "$@"
fi
