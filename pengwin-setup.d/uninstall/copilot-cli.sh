#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

function main() {

  echo "Uninstalling GitHub Copilot CLI"

  # Remove npm global package
  if command -v npm &> /dev/null; then
    if npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null; then
      echo "GitHub Copilot CLI npm package removed"
    else
      if sudo npm uninstall -g @githubnext/github-copilot-cli 2>/dev/null; then
        echo "GitHub Copilot CLI npm package removed (with sudo)"
      fi
    fi
  fi

  # Remove shell integration files
  echo "Removing GitHub Copilot CLI shell integration..."
  sudo rm -f /etc/profile.d/github-copilot-cli.sh

  # Remove fish configuration
  rem_file "${HOME}/.config/fish/conf.d/github-copilot-cli.fish"

  echo "GitHub Copilot CLI uninstalled successfully"
}

if show_warning "GitHub Copilot CLI" "$@"; then
  main "$@"
fi
