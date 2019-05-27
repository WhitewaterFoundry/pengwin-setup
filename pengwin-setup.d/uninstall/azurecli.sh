#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

azure_src="/etc/apt/sources.list.d/azurecli.list"
azure_key="/etc/apt/trusted.gpg.d/microsoft.gpg"

function main()
{

echo "Uninstall Azure command line tools"

# Remove packages
remove_package "azure-cli" "jq"

echo "Removing APT source"
if [[ -f "$azure_src" ]] ; then
	sudo rm -f "$azure_src"
else
	echo "... not found!"
fi

echo "Removing APT key"
if [[ -f "$azure_key" ]] ; then
	sudo rm -f "$azure_key"
else
	echo "... not found!"
fi

}

if show_warning "" "" ; then
	main "$@"
fi
