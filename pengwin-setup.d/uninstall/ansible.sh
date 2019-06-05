#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

ans_key="93C4A3FD7BB9C367"

function main()
{

echo "Uninstalling Ansible"

remove_package "ansible"

echo "Removing APT source..."
sudo_rem_file "/etc/apt/sources.list.d/ansible.list"

echo "Removing APT key"
sudo apt-key del "$ans_key"

}

if show_warning "ansible" "$@" ; then
	main "$@"
fi

