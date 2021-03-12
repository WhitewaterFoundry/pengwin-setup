#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main()
{

echo "Uninstalling Kubernetes"

# Uninstall kubectl
bash $(dirname "$0")/kubectl.sh

echo "Removing bash completions..."
sudo_rem_file "/etc/bash_completion.d/kubectx"
sudo_rem_file "/etc/bash_completion.d/kubens"

sudo_rem_file "/usr/local/bin/kubectx"
sudo_rem_file "/usr/local/bin/kubens"

rem_dir "$HOME/.kube"

if docker version > /dev/null 2>&1 ; then
	echo "Offering docker uninstall"
	if (whiptail --title "docker" --yesno "It seems Docker secure bridge is currently installed, would you like to uninstall this too?" 8 85) ; then
		bash $(dirname "$0")/docker.sh
	else
		echo "... user cancelled"
	fi
fi

}

if show_warning "Kubernetes" "$@" ; then
	main "$@"
fi
