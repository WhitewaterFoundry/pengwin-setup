#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling AWS CLI"

  # Uninstall AWS CLI v2 (if installed)
  # AWS CLI v2 installs to /usr/local/aws-cli/
  if [[ -d "/usr/local/aws-cli" ]]; then
    echo "Detected AWS CLI v2, removing installation..."
    sudo_rem_file "/usr/local/bin/aws"
    sudo_rem_file "/usr/local/bin/aws_completer"
    sudo_rem_dir "/usr/local/aws-cli"
  fi

  # Uninstall AWS CLI v1 (if installed)
  # AWS CLI v1 installs to /usr/local/aws/
  sudo_rem_file "/usr/local/bin/aws"
  sudo_rem_dir "/usr/local/aws"

  echo "Removing bash completion..."
  sudo_rem_file "/etc/bash_completion.d/aws_bash_completer"
  sudo_rem_file "/etc/bash_completion.d/aws"
  sudo_rem_file "/usr/local/bin/aws_completer"

}

# Check for --skip-warning flag
skip_warning=0
for arg in "$@"; do
  if [[ "${arg}" == "--skip-warning" ]]; then
    skip_warning=1
    break
  fi
done

if [[ ${skip_warning} -eq 1 ]] || show_warning "AWS CLI" "$@"; then
  main "$@"
fi
