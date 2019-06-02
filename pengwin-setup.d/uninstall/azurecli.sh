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
sudo_rem_file "/etc/apt/trusted.gpg.d/microsoft.gpg"

}

if show_warning "Azure CLI" "$@" ; then
	main "$@"
fi
