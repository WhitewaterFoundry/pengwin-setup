#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GitHub Copilot CLI"

  # Remove copilot binary from user's local bin
  if [[ -f "${HOME}/.local/bin/copilot" ]]; then
    rm -f "${HOME}/.local/bin/copilot"
    echo "Removed copilot binary from ${HOME}/.local/bin"
  fi

  # Remove copilot binary from system-wide location (if installed with sudo)
  if [[ -f "/usr/local/bin/copilot" ]]; then
    sudo rm -f /usr/local/bin/copilot
    echo "Removed copilot binary from /usr/local/bin"
  fi

  # Remove legacy shell integration files (from previous npm-based installation)
  if [[ -f /etc/profile.d/github-copilot-cli.sh ]]; then
    sudo rm -f /etc/profile.d/github-copilot-cli.sh
    echo "Removed legacy shell integration file"
  fi

  # Remove legacy fish configuration
  rem_file "${HOME}/.config/fish/conf.d/github-copilot-cli.fish"

  # Remove legacy npm package if still present
  if command -v npm &> /dev/null; then
    if npm list -g @githubnext/github-copilot-cli &>/dev/null; then
      npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null || \
        sudo npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null
      echo "Removed legacy npm package"
    fi
  fi

  echo "GitHub Copilot CLI uninstalled successfully"
}

if show_warning "GitHub Copilot CLI" "$@"; then
  main "$@"
fi
