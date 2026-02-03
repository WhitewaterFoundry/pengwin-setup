#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "GitHub Copilot CLI" --yesno "GitHub Copilot CLI is an AI-powered command line tool.\n\nThis installer downloads and runs the official GitHub install script.\n\nWould you like to install GitHub Copilot CLI?" 10 65); then
  echo "Installing GitHub Copilot CLI"

  # Ensure $HOME/.local/bin exists and is in the PATH
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${PATH}"

  # Install GitHub Copilot CLI using the official install script
  echo "Downloading and installing GitHub Copilot CLI..."
  if ! curl -fsSL https://gh.io/copilot-install | bash; then
    echo "ERROR: Failed to install GitHub Copilot CLI."
    echo "Please check the error messages above for details."
    exit 1
  fi

  # Create profile.d script to add $HOME/.local/bin to PATH on login
  echo "Setting up PATH configuration in /etc/profile.d/github-copilot.sh"
  sudo tee "/etc/profile.d/github-copilot.sh" <<'EOF'
#!/bin/sh

# Add $HOME/.local/bin to PATH for GitHub Copilot CLI
if [ -d "${HOME}/.local/bin" ]; then
  case ":${PATH}:" in
    *":${HOME}/.local/bin:"*) ;;
    *) export PATH="${HOME}/.local/bin:${PATH}" ;;
  esac
fi
EOF

  # Also set up for fish shell
  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"
  sudo tee "${__fish_sysconf_dir}/github-copilot.fish" <<'EOF'
#!/bin/fish

# Add $HOME/.local/bin to PATH for GitHub Copilot CLI
if test -d "$HOME/.local/bin"
  if not contains "$HOME/.local/bin" $PATH
    set --export PATH "$HOME/.local/bin" $PATH
  end
end
EOF

  echo "GitHub Copilot CLI installed successfully!"
  echo ""
  echo "To authenticate, run: copilot /login"
  
  message --title "GitHub Copilot CLI" --msgbox "GitHub Copilot CLI installed successfully!\n\nTo authenticate, run:\n  copilot /login" 10 50
else
  echo "Skipping GitHub Copilot CLI"
fi
