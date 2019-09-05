#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

nodesource_key='9FD3 B784 BC1C 6FC3 1A8A  0A1C 1655 A0AB 6857 6280'
yarn_key='72EC F46A 56B4 AD39 C907  BBB7 1646 B01B 86E5 0310'
n_line_rgx='^[^#]*\bN_PREFIX='

function main()
{

echo "Uninstalling nodejs (including n version manager, npm and yarn package managers)"

# Check for ruby rails install
echo "Checking if Ruby on Rails installed..."
if gem list --local | grep '^rails' > /dev/null 2>&1 ; then
	echo "Rails install detected. Showing user warning"
	if ! (whiptail --title "nodejs" --yesno "A Ruby on Rails install has been detected, which relies upon nodejs. Are you sure you'd like to continue uninstalling nodejs? As this may break your Ruby on Rails install" 9 85) ; then
		echo "User cancelled nodejs uninstall"
		exit 1
	fi
fi

rem_dir "$HOME/n"
rem_dir "$HOME/.npm"
rem_dir "$HOME/.nvm"

echo "Removing PATH modifier(s)..."
sudo_rem_file "/etc/profile.d/n-prefix.sh"
sudo_rem_file "/etc/profile.d/nvm-prefix.sh"
sudo_rem_file "/etc/profile.d/rm-win-npm-path.sh"
sudo_rem_file "/etc/fish/conf.d/n-prefix.fish"
sudo_rem_file "/etc/fish/conf.d/nvm-prefix.fish"
# The .bashrc path clean shouldn't be needed on newer installs, but takes into account legacy pengwin-setup nodejs installs
if [[ -f "$HOME/.bashrc" ]] ; then
	echo "$HOME/.bashrc found, cleaning"
	clean_file "$HOME/.bashrc" "$n_line_rgx"
fi

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/npm"
sudo_rem_file "/etc/bash_completion.d/nvm"

remove_package "yarn" "nodejs"

echo "Removing APT source(s)"
sudo_rem_file "/etc/apt/sources.list.d/yarn.list"
sudo_rem_file "/etc/apt/sources.list.d/nodesource.list"

echo "Removing APT key(s)"
sudo apt-key del "$yarn_key"
sudo apt-key del "$nodesource_key"

}

if show_warning "nodejs" "$@" ; then
	main "$@"
fi
