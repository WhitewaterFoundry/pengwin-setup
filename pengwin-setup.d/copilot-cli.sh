#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Imported from common.sh
declare SetupDir

if (confirm --title "GitHub Copilot CLI" --yesno "GitHub Copilot CLI is an AI-powered command line tool.\n\nThis requires Node.js 22+ and npm 10+.\nIf not installed, the Node.js LTS installer will be launched.\n\nWould you like to install GitHub Copilot CLI?" 12 80); then
  echo "Installing GitHub Copilot CLI"
  
  # Ensure Node.js meets minimum version requirement
  if ! ensure_nodejs_version 22 "GitHub Copilot CLI"; then
    exit 1
  fi

  # Install GitHub Copilot CLI via npm
  echo "Installing @githubnext/github-copilot-cli via npm..."
  if ! npm install -g @githubnext/github-copilot-cli 2>&1; then
    echo "Failed to install with user permissions, trying with sudo..."
    if ! sudo npm install -g @githubnext/github-copilot-cli 2>&1; then
      echo "ERROR: Failed to install GitHub Copilot CLI via npm."
      echo "Please check the error messages above for details."
      exit 1
    fi
  fi

  # Set up shell aliases (github-copilot-cli provides these)
  COPILOT_ALIAS_FILE="/etc/profile.d/github-copilot-cli.sh"
  echo "Setting up GitHub Copilot CLI shell integration..."
  sudo tee "${COPILOT_ALIAS_FILE}" <<'EOF'
#!/bin/bash

# GitHub Copilot CLI aliases
eval "$(github-copilot-cli alias -- "$0")"
EOF

  # Set up for fish shell if installed
  if command -v fish &> /dev/null; then
    FISH_DIR="${HOME}/.config/fish/conf.d"
    FISH_CONF="${FISH_DIR}/github-copilot-cli.fish"
    
    mkdir -p "${FISH_DIR}"
    cat > "${FISH_CONF}" <<'EOF'
#!/bin/fish

# GitHub Copilot CLI aliases
github-copilot-cli alias -- fish | source
EOF
    echo "GitHub Copilot CLI fish shell integration configured"
  fi

  echo "GitHub Copilot CLI installed successfully!"
  echo ""
  echo "To authenticate, run: github-copilot-cli auth"
  echo "For command suggestions, use: ?? <your question>"
  echo "For git command suggestions, use: git? <your question>"
  echo "For gh (GitHub CLI) suggestions, use: gh? <your question>"
  
  message --title "GitHub Copilot CLI" --msgbox "GitHub Copilot CLI installed successfully!\n\nTo authenticate, run:\n  github-copilot-cli auth\n\nFor command suggestions, use:\n  ?? <your question>\n\nFor git command suggestions, use:\n  git? <your question>\n\nFor gh (GitHub CLI) suggestions, use:\n  gh? <your question>" 16 70
  
  touch "${HOME}"/.should-restart
else
  echo "Skipping GitHub Copilot CLI"
fi
