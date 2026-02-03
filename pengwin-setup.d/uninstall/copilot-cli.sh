#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GitHub Copilot CLI"

  # Remove copilot binary from user's local bin
  rem_file "${HOME}/.local/bin/copilot"

  # Remove copilot binary from system-wide location (if installed with sudo)
  sudo_rem_file "/usr/local/bin/copilot"

  # Remove legacy shell integration files (from previous npm-based installation)
  sudo_rem_file "/etc/profile.d/github-copilot-cli.sh"

  # Remove PATH configuration added by the new binary installer
  sudo_rem_file "/etc/profile.d/github-copilot.sh"

  # Remove fish configuration
  rem_file "${HOME}/.config/fish/conf.d/github-copilot-cli.fish"
  sudo_rem_file "${__fish_sysconf_dir:=/etc/fish/conf.d}/github-copilot.fish"

  # Remove legacy npm package if still present
  if command -v npm &> /dev/null; then
    if npm list -g @githubnext/github-copilot-cli &>/dev/null; then
      if npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null || \
         sudo npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null; then
        echo "Removed legacy npm package"
      else
        echo "Note: Could not remove legacy npm package @githubnext/github-copilot-cli"
      fi
    fi
  fi

  echo "GitHub Copilot CLI uninstalled successfully"
}

if show_warning "GitHub Copilot CLI" "$@"; then
  main "$@"
fi
