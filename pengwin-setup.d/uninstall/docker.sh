#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

relaybin='/usr/bin/docker-relay'
relaysudoer='/etc/sudoers.d/docker-relay'
relayprofile='/etc/profile.d/docker-relay.sh'
relayexedir="$wHome/.npiperelay"

dbashcomp='/etc/bash_completion.d/docker'
dcbashcomp='/etc/bash_completion.d/docker-compose'

dockerbin='/usr/bin/docker'
dockercbin='/usr/bin/docker-compose'

wslconf_rgx='^[^#]*\broot=/'
mntbin='/usr/bin/create-mnt-c-link'
mntbin_profile='/etc/profile.d/create-mnt-c-link.sh'
mntbin_rgx='^[^#]*\bsudo\s*ALL=NOPASSWD: /usr/bin/create-mnt-c-link' '/etc/sudoers'

function revert_mnt_point()
{

echo "Offering to revert docker changed Windows volume mount point"
if whiptail --title "DOCKER" --yesno "Would you like to revert your root mount point to WSL default?" 7 85 ; then
	echo "Cleaning changes from /etc/wsl.conf"
	sudo_clean_file "/etc/wsl.conf" "$wslconf_rgx"

	sudo_rem_file "$mntbin"

	echo "Removing create-mnt-c-link profile configuration"
	sudo_rem_file "$mntbin_profile"

	echo "Cleaning create-mnt-c-link changes from /etc/sudoers"
	sudo_clean_file "/etc/sudoers" "$mntbin_rgx"

	whiptail --title "DOCKER" --msgbox "Finished reverting root mount point. Please close and re-open Pengwin to see changes" 8 85
else
	echo "... user opted to keep docker changed mount point."
fi

}

function main()
{

echo "Uninstalling Docker Bridge"

echo "Removing npiperelay.exe"
if [[ -d "$relayexedir" ]] ; then
	if cmd-exe /C "tasklist" | grep -Fq 'npiperelay.exe' ; then
		echo "npiperelay.exe running. Killing process..."
		cmd-exe /C "taskkill /IM 'npiperelay.exe' /F"
	fi

	# Now safe to remove directory
	rm -rf "$relayexedir"
else
	echo "... not found!"
fi

sudo_rem_file "$relaybin"

echo "Removing docker-relay sudoers modification..."
sudo_rem_file "$relaysudoer"

echo "Removing docker-relay profile modification..."
sudo_rem_file "$relayprofile"

sudo_rem_file "$dockerbin"
sudo_rem_file "$dockercbin"

echo "Removing bash completion..."
sudo_rem_file "$dbashcomp"
sudo_rem_file "$dcbashcomp"

echo "Checking root mount path"
if [[ $(wslpath 'C:\\') == '/c' ]] ; then
	revert_mnt_point "$@"
else
	echo "Root mount path already WSL default."
fi

echo "Removing docker user"
if grep -Fq 'docker:' '/etc/passwd' ; then
	sudo deluser docker
else
	echo "... not found!"
fi

echo "Removing docker user group"
if grep -Fq 'docker:' '/etc/group' ; then
	sudo delgroup docker
else
	echo "... not found!"
fi

}

if show_warning "" "" ; then
	main "$@"
fi