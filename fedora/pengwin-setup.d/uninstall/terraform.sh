#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

terra_rgx='^[^#]*\bcomplete -C /usr/bin/terraform terraform'

function main() {

  echo "Uninstalling Terraform"

  sudo_rem_file "/usr/bin/terraform"
  clean_file "$HOME/.bashrc" "$terra_rgx"

}

if show_warning "Terraform" "$@"; then
  main "$@"
fi
