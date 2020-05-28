#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

kubectl_key1='D0BC 747F D8CA F711 7500  D6FA 3746 C208 A731 7B0F'
kubectl_key2='54A6 47F9 048D 5688 D7DA  2ABE 6A03 0B21 BA07 F4FB'

function main()
{

echo "Uninstalling kubectl"

# Check if IBM CLI or Kubernetes still installed
if ibmcloud --version > /dev/null 2>&1 ; then
	echo "... IBM CLI tools still installed, skipping kubectl uninstall."
	exit 1
fi
if kubectx  > /dev/null 2>&1 ; then
	echo "... Kubernetes tooling still installed, skipping kubectl uninstall."
	exit 1
fi

sudo_rem_file "/usr/local/bin/helm"
sudo_rem_file "/usr/local/bin/tiller"

echo "Removing bash completion..."
sudo_rem_file "/etc/bash_completion.d/helm_completions.bash"

remove_package "kubectl"

echo "Removing kubectl APT source..."
sudo_rem_file "/etc/apt/sources.list.d/kubernetes.list"

echo "Removing kubectl APT keys..."
sudo apt-key del "$kubectl_key1"
sudo apt-key del "$kubectl_key2"

}

main "$@"
