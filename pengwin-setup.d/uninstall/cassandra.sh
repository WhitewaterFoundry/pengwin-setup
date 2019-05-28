#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

cas_src="/etc/apt/sources.list.d/cassandra.list"
cas_key="/etc/apt/trusted.gpg.d/cassandra.gpg"
sudoers_rgx='^[^#]*\bALL=.(root.) NOPASSWD: /bin/mount, /bin/umount'
profile_rgx='^[^#]*\bsudo mount -t proc proc /proc'

function main()
{

echo "Uninstalling Apache Cassandra"

# Removing cassandra
remove_package "cassandra"

echo "Removing APT source"
if [[ -f "$cas_src" ]] ; then
	sudo rm -f "$cas_src"
else
	echo "... not found!"
fi

echo "Removing APT key"
if [[ -f "$cas_key" ]] ; then
	sudo rm -f "$cas_key"
else
	echo "... not found!"
fi

echo "Removing Cassandra-specific changes to /etc/sudoers"
sudo_clean_file "/etc/sudoers" "$sudoers_rgx"

echo "Removing Cassandra-specific changes to /etc/profile"
sudo_clean_file "/etc/profile" "$profile_rgx"

echo "Unlinking Cassandra from user directory"
if [[ -d "$HOME/cassandra" ]] ; then
	sudo unlink "$HOME/cassandra"
else
	echo "... not symlinked!"
fi

echo "Removing remnant files in /etc/cassandra"
if [[ -d "/etc/cassandra" ]] ; then
	sudo rm -rf "/etc/cassandra"
else
	echo "... not found!"
fi

echo "Removing remnant files in /var/lib/cassandra"
if [[ -d "/var/lib/cassandra" ]] ; then
	sudo rm -rf "/var/lib/cassandra"
else
	echo "... not found!"
fi

echo "Removing remnant files in /var/log/cassandra"
if [[ -d "/var/log/cassandra" ]] ; then
	sudo rm -rf "/var/log/cassandra"
else
	echo "... not found!"
fi

}

if show_warning "" "" ; then
	main "$@"
fi
