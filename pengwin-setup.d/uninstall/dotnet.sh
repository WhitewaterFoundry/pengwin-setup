#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

dotnet_src="/etc/apt/sources.list.d/"
dotnet_key="/etc/apt/trusted.gpgp.d/microsoft.gpg"

function main()
{

remove_package "dotnet-sdk-2.2"

echo "Removing APT source"
if [[ -f "$dotnet_src" ]] ; then

else
	echo "... not found!"
fi

echo "Removing APT key"
if [[ -f "$dotnet_key" ]] ; then

else
	echo "... not found!"
fi

}
