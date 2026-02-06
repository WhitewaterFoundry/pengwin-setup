#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GitHub Copilot CLI"

  # Remove copilot binary from user's local bin
  rem_file "${HOME}/.local/bin/copilot"

  # Remove copilot binary from system-wide location (if installed with sudo)
  sudo_rem_file "/usr/local/bin/copilot"

  # Remove PATH configuration (new and legacy profile.d scripts)
  sudo_rem_file "/etc/profile.d/z-github-copilot.sh"
  sudo_rem_file "/etc/profile.d/github-copilot-cli.sh"

  # Remove fish configuration (new and legacy files)
  rem_file "${HOME}/.config/fish/conf.d/z-github-copilot-cli.fish"
  rem_file "${HOME}/.config/fish/conf.d/github-copilot-cli.fish"
  sudo_rem_file "${__fish_sysconf_dir:=/etc/fish/conf.d}/z-github-copilot.fish"

  # Remove @github/copilot npm package (WSL1 installation method)
  if command -v npm &> /dev/null; then
    if npm list -g @github/copilot &>/dev/null; then
      if npm uninstall -g @github/copilot 2>/dev/null || \
         sudo npm uninstall -g @github/copilot 2>/dev/null; then
        echo "Removed @github/copilot npm package"
      else
        echo "Note: Could not remove npm package @github/copilot"
      fi
    fi
  fi

  echo "GitHub Copilot CLI uninstalled successfully"
}

if show_warning "GitHub Copilot CLI" "$@"; then
  main "$@"
fi
