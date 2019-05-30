#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling AWS cli"

sudo_rem_file "/usr/local/bin/aws"
sudo_rem_dir "/usr/local/aws"

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/aws_bash_completer"
sudo_rem_file "/usr/local/bin/aws_completer"

}

if show_warning "" "" ; then
	main "$@"
fi
