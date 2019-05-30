#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling Digital Ocean CTL"

# need to delete go build folder?
sudo_rem_file "/usr/local/bin/doctl"

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/doc.bash_completion"

}

if show_warning "" "" ; then
	main "$@"
fi
