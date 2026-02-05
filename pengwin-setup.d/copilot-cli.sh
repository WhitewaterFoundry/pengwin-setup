#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# shellcheck source=nodejs-common.sh
source "$(dirname "$0")/nodejs-common.sh"

# Minimum Node.js version required for GitHub Copilot CLI
readonly COPILOT_MIN_NODEJS_VERSION=18

#######################################
# Install GitHub Copilot CLI via npm (for WSL1)
# Globals:
#   HOME - User's home directory
#   COPILOT_MIN_NODEJS_VERSION - Minimum required Node.js version
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_copilot_npm() {
  echo "Installing GitHub Copilot CLI via npm (WSL1 method)..."

  # First ensure Node.js is installed via version manager
  if ! ensure_nodejs_version "${COPILOT_MIN_NODEJS_VERSION}" "GitHub Copilot CLI"; then
    return 1
  fi

  # Refresh command hash table after possible Node.js installation
  hash -r

  # Source the N profile to get the updated PATH
  if [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/n-prefix.sh"
  fi

  # Install @github/copilot package globally via npm
  echo "Installing @github/copilot npm package..."
  if ! npm install -g @github/copilot; then
    echo "ERROR: Failed to install @github/copilot package."
    return 1
  fi

  # Create profile.d script with alias for WSL1
  # Note: Using single-quoted heredoc ('EOF') is intentional - variables expand at
  # runtime (when user logs in) not at installation time
  echo "Setting up alias in /etc/profile.d/github-copilot.sh"
  sudo tee "/etc/profile.d/github-copilot.sh" <<'EOF'
#!/bin/sh

# Add $HOME/.local/bin to PATH for GitHub Copilot CLI
if [ -d "${HOME}/.local/bin" ]; then
  case ":${PATH}:" in
    *":${HOME}/.local/bin:"*) ;;
    *) export PATH="${HOME}/.local/bin:${PATH}" ;;
  esac
fi

# Alias for WSL1 compatibility - run copilot binary with explicit ld-linux loader
# Only apply the workaround if WSL2 is not set (i.e., we're in WSL1)
# This allows users who switch to WSL2 to run copilot directly
if [ -z "${WSL2}" ]; then
  alias copilot='/lib64/ld-linux-x86-64.so.2 ${HOME}/.local/bin/copilot'
fi
EOF

  # Also set up for fish shell
  # Note: Using single-quoted heredoc - variables expand at runtime for each user
  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"
  sudo tee "${__fish_sysconf_dir}/github-copilot.fish" <<'EOF'
#!/bin/fish

# Add $HOME/.local/bin to PATH for GitHub Copilot CLI
if test -d "$HOME/.local/bin"
  if not contains "$HOME/.local/bin" $PATH
    set --export PATH "$HOME/.local/bin" $PATH
  end
end

# Alias for WSL1 compatibility - run copilot binary with explicit ld-linux loader
# Only apply the workaround if WSL2 is not set (i.e., we're in WSL1)
# This allows users who switch to WSL2 to run copilot directly
if not set -q WSL2
  alias copilot '/lib64/ld-linux-x86-64.so.2 $HOME/.local/bin/copilot'
end
EOF

  return 0
}

#######################################
# Install GitHub Copilot CLI via official binary installer (for WSL2)
# Globals:
#   HOME - User's home directory
#   TMPDIR - Temporary directory (set by createtmp)
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_copilot_binary() {
  echo "Installing GitHub Copilot CLI via official installer..."

  # Ensure curl is installed for downloading
  install_packages curl

  # Ensure $HOME/.local/bin exists and is in the PATH
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${PATH}"

  # Create temporary directory for the installer
  createtmp
  install_script="${TMPDIR}/copilot-install.sh"

  # Download the installer script
  echo "Downloading GitHub Copilot CLI installer..."
  if ! curl -fsSL https://gh.io/copilot-install -o "${install_script}"; then
    echo "ERROR: Failed to download GitHub Copilot CLI installer."
    cleantmp
    return 1
  fi

  # Make the script executable and run it
  # Note: Unset VERSION to avoid conflict with pengwin-setup's VERSION variable
  # The GitHub install script uses VERSION to determine which copilot version to download
  chmod +x "${install_script}"
  echo "Running GitHub Copilot CLI installer..."
  if ! VERSION="" bash "${install_script}"; then
    echo "ERROR: Failed to install GitHub Copilot CLI."
    echo "Please check the error messages above for details."
    cleantmp
    return 1
  fi

  cleantmp

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

  return 0
}

if (confirm --title "GitHub Copilot CLI" --yesno "GitHub Copilot CLI is an AI-powered command line tool.\n\nThis installer downloads and runs the official GitHub install script.\n\nWould you like to install GitHub Copilot CLI?" 10 65); then
  echo "Installing GitHub Copilot CLI"

  # Use different installation method based on WSL version
  if is_wsl1; then
    echo "WSL1 detected: Using npm installation method"
    if ! install_copilot_npm; then
      exit 1
    fi
  else
    if ! install_copilot_binary; then
      exit 1
    fi
  fi

  echo "GitHub Copilot CLI installed successfully!"
  echo ""
  echo "To authenticate, run: copilot login"
  
  message --title "GitHub Copilot CLI" --msgbox "GitHub Copilot CLI installed successfully!\n\nTo authenticate, run:\n  copilot login" 10 50

  enable_should_restart
else
  echo "Skipping GitHub Copilot CLI"
fi
