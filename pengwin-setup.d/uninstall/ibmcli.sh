#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling IBM Cloud CLI"



echo "Removing bash completions..."
sudo_rem_file "/etc/bash_completion.d/ibmcli_completion"

}

if show_warning "" "" ; then
	main "$@"
fi
