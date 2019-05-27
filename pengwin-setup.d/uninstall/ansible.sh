#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

ans_key="93C4A3FD7BB9C367"

function main()
{

echo "Uninstalling Ansible"

remove_package "ansible"
remove_source "ansible" "$ans_key"

}

if show_warning "" "" ; then
	main "$@"
fi

