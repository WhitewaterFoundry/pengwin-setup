#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

ans_src="/etc/apt/sources.list.d/ansible.sh"
ans_key="93C4A3FD7BB9C367"

function main()
{

echo "Uninstalling Ansible"

remove_package "ansible"

echo "Removing APT source"
if [[ -f "$ans_src" ]] ; then
	sudo rm -f "$ans_src"
else
	echo "... not found!"
fi

echo "Removing APT key"
sudo apt-key del "$ans_key"

}

if show_warning "" "" ; then
	main "$@"
fi

