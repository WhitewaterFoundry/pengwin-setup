#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/uninstall/uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling IBM Cloud CLI"

  # Uninstall kubectl
  bash $(dirname "$0")/kubectl.sh

  echo "Removing bash completions..."
  sudo_rem_file "/etc/bash_completion.d/ibmcli_completion"

  sudo_rem_file "/usr/local/bin/bluemix"
  sudo_rem_file "/usr/local/bin/bx"
  sudo_rem_file "/usr/local/bin/ibmcloud"
  sudo_rem_file "/usr/local/bin/ibmcloud-analytics"

  sudo_rem_dir "/usr/local/ibmcloud"
  rem_dir "$HOME/.bluemix"

}

if show_warning "IBM Cloud CLI" "$@"; then
  main "$@"
fi
