#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstall Azure command line tools"

# Remove packages
remove_package "azure-cli" "jq"

echo "Removing APT source..."
sudo_rem_file "/etc/apt/sources.list.d/azurecli.list"

echo "Removing APT key..."
safe_rem_microsoftgpg

}

if show_warning "Azure CLI" "$@" ; then
	main "$@"
fi
