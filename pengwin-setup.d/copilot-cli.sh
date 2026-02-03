#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "GitHub Copilot CLI" --yesno "GitHub Copilot CLI is an AI-powered command line tool.\n\nWould you like to install GitHub Copilot CLI?" 8 60); then
  echo "Installing GitHub Copilot CLI"

  # Install GitHub Copilot CLI using the official install script
  echo "Downloading and installing GitHub Copilot CLI..."
  if ! curl -fsSL https://gh.io/copilot-install | bash; then
    echo "ERROR: Failed to install GitHub Copilot CLI."
    echo "Please check the error messages above for details."
    exit 1
  fi

  echo "GitHub Copilot CLI installed successfully!"
  echo ""
  echo "To authenticate, run: copilot /login"
  
  message --title "GitHub Copilot CLI" --msgbox "GitHub Copilot CLI installed successfully!\n\nTo authenticate, run:\n  copilot /login" 10 50
else
  echo "Skipping GitHub Copilot CLI"
fi
