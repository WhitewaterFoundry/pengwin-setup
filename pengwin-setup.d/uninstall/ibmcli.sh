#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

kubectl_key1='D0BC 747F D8CA F711 7500  D6FA 3746 C208 A731 7B0F'
kubectl_key2='54A6 47F9 048D 5688 D7DA  2ABE 6A03 0B21 BA07 F4FB'

function main()
{

echo "Uninstalling IBM Cloud CLI"

sudo_rem_file "/usr/local/bin/bluemix"
sudo_rem_file "/usr/local/bin/bx"
sudo_rem_file "/usr/local/bin/ibmcloud"
sudo_rem_file "/usr/local/bin/ibmcloud-analytics"
sudo_rem_file "/usr/local/bin/helm"
sudo_rem_file "/usr/local/bin/tiller"

sudo_rem_dir "/usr/local/ibmcloud"
rem_dir "$HOME/.bluemix"

remove_package "kubectl"

echo "Removing kubectl APT source..."
sudo_rem_file "/etc/apt/sources.list.d/kubernetes.list"

echo "Removing kubectl APT keys..."
sudo apt-key del "$kubectl_key1"
sudo apt-key del "$kubectl_key2"

echo "Removing bash completions..."
sudo_rem_file "/etc/bash_completion.d/ibmcli_completion"
sudo_rem_file "/etc/bash_completion.d/helm_completions.bash"

}

if show_warning "IBM Cloud CLI" "$@" ; then
	main "$@"
fi
