#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling AWS CLI"

  # Uninstall AWS CLI v2 (if installed)
  if [[ -f "/usr/local/bin/aws" ]] && [[ -f "/usr/local/aws-cli/aws" ]]; then
    echo "Detected AWS CLI v2, using official uninstaller..."
    sudo /usr/local/aws-cli/v2/current/bin/aws --version 2>&1 | grep -q "aws-cli/2" && \
      sudo rm -f /usr/local/bin/aws && \
      sudo rm -f /usr/local/bin/aws_completer && \
      sudo rm -rf /usr/local/aws-cli
  fi

  # Uninstall AWS CLI v1 (if installed)
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
