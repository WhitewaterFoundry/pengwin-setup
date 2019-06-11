#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

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

}

if show_warning "Kubernetes" "$@" ; then
	main "$@"
fi