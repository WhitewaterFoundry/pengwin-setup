#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

yarn_key='72EC F46A 56B4 AD39 C907  BBB7 1646 B01B 86E5 0310'
line_rgx='^[^#]*\bN_PREFIX='

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

echo "Removing PATH modifier(s)..."
sudo_rem_file "/etc/profile.d/n-prefix.sh"
if [[ -f "$HOME/.bashrc" ]] ; then
	echo "$HOME/.bashrc found, cleaning"
	clean_file "$HOME/.bashrc" "$line_rgx"
fi
if [[ -f "$HOME/.zshrc" ]] ; then
	echo "$HOME/.zshrc found, cleaning"
	clean_file "$HOME/.zshrc" "$line_rgx"
fi

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/npm"

remove_package "yarn"

echo "Removing APT source"
sudo_rem_file "/etc/apt/sources.list.d/yarn.list"

echo "Removing APT key"
sudo apt-key del "$yarn_key"

}

if show_warning "nodejs" "$@" ; then
	main "$@"
fi
