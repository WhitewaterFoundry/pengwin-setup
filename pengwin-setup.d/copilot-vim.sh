#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# shellcheck source=nodejs-common.sh
source "$(dirname "$0")/nodejs-common.sh"

# Imported from common.sh
declare SetupDir

#######################################
# Install vim-plug for an editor
# Globals:
#   None
# Arguments:
#   $1: editor name ("vim" or "neovim")
#   $2: plugin directory path
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_plug() {
  local editor_name="$1"
  local plug_dir="$2"
  local plug_file="${plug_dir}/plug.vim"
  
  if [[ -f "${plug_file}" ]]; then
    echo "vim-plug already installed for ${editor_name}"
    return 0
  fi
  
  echo "Installing vim-plug for ${editor_name}..."
  mkdir -p "${plug_dir}"
  if curl -fLo "${plug_file}" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    echo "vim-plug installed successfully for ${editor_name}"
    return 0
  else
    echo "ERROR: Failed to install vim-plug for ${editor_name}"
    return 1
  fi
}

#######################################
# Configure copilot.vim plugin in config file
# Globals:
#   None
# Arguments:
#   $1: editor name ("vim" or "neovim")
#   $2: config file path
#   $3: plugin directory path
# Returns:
#   0 on success, non-zero on failure
#######################################
function configure_copilot() {
  local editor_name="$1"
  local config_file="$2"
  local plugin_dir="$3"
  local config_name
  
  config_name=$(basename "${config_file}")
  
  # Create config directory if needed
  mkdir -p "$(dirname "${config_file}")"
  
  # Check if copilot is already configured
  if [[ -f "${config_file}" ]] && grep -q "github/copilot.vim" "${config_file}"; then
    echo "GitHub Copilot already configured in ${config_name}"
    return 0
  fi
  
  echo "Configuring GitHub Copilot in ${config_name}..."
  
  # Create or update config file with vim-plug section
  if ! grep -q "call plug#begin" "${config_file}" 2>/dev/null; then
    cat >> "${config_file}" <<EOF

" vim-plug plugins
call plug#begin('${plugin_dir}')
Plug 'github/copilot.vim'
call plug#end()
EOF
  else
    # Add copilot to existing plug#begin section
    if ! grep -q "Plug 'github/copilot.vim'" "${config_file}"; then
      sed -i "/call plug#begin/a Plug 'github/copilot.vim'" "${config_file}"
    fi
  fi
  
  echo "GitHub Copilot configured in ${config_name}"
  return 0
}

#######################################
# Setup copilot for a specific editor
# Globals:
#   None
# Arguments:
#   $1: editor name ("vim" or "neovim")
#   $2: editor command ("vim" or "nvim")
#   $3: autoload directory path
#   $4: config file path
#   $5: plugin directory path
# Returns:
#   0 on success, non-zero on failure
#######################################
function setup_editor_copilot() {
  local editor_name="$1"
  local editor_cmd="$2"
  local autoload_dir="$3"
  local config_file="$4"
  local plugin_dir="$5"
  
  echo "Configuring GitHub Copilot for ${editor_name}..."
  
  if ! install_plug "${editor_name}" "${autoload_dir}"; then
    echo "ERROR: Failed to install vim-plug for ${editor_name}"
    return 1
  fi
  
  configure_copilot "${editor_name}" "${config_file}" "${plugin_dir}"
  
  echo "Running :PlugInstall for ${editor_name}..."
  if [[ "${editor_cmd}" == "vim" ]]; then
    vim +PlugInstall +qall 2>/dev/null
  else
    nvim --headless +PlugInstall +qall 2>/dev/null
  fi

  if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to install copilot.vim plugin for ${editor_name}"
    return 1
  fi
  return 0
}

#######################################
# Display installation success message
# Globals:
#   None
# Arguments:
#   $1: has_vim (true/false)
#   $2: has_nvim (true/false)
# Returns:
#   0 on success
#######################################
function display_success_message() {
  local has_vim="$1"
  local has_nvim="$2"
  
  # Display success message
  echo ""
  echo "GitHub Copilot for Vim/Neovim installed successfully!"
  echo ""
  echo "To authenticate and start using GitHub Copilot:"
  
  local msg="GitHub Copilot for Vim/Neovim installed successfully!\n\nTo authenticate and start using GitHub Copilot:\n"
  local instructions=""
  
  if [[ "${has_vim}" == true ]]; then
    instructions="  1. Open Vim and run: :Copilot setup"
    echo "  1. Open Vim: vim"
    echo "  2. Run: :Copilot setup"
  fi
  if [[ "${has_nvim}" == true ]]; then
    if [[ -n "${instructions}" ]]; then
      instructions="${instructions}\n  OR\n"
      echo "  OR"
    fi
    instructions="${instructions}  1. Open Neovim and run: :Copilot setup"
    echo "  1. Open Neovim: nvim"
    echo "  2. Run: :Copilot setup"
  fi
  
  echo ""
  echo "After setup, Copilot will provide inline suggestions as you type."
  echo "Press Tab to accept suggestions."
  
  msg="${msg}${instructions}\n\nAfter setup, Copilot will provide inline suggestions as you type.\nPress Tab to accept suggestions."
  
  message --title "GitHub Copilot for Vim/Neovim" --msgbox "${msg}" 16 70
  return 0
}

#######################################
# Main installation function
# Globals:
#   SetupDir
# Arguments:
#   All script arguments
# Returns:
#   0 on success, non-zero on failure
#######################################
function main() {
  if ! (confirm --title "GitHub Copilot for Vim/Neovim" --yesno "GitHub Copilot is an AI-powered code completion tool for Vim/Neovim.\n\nThis requires Node.js 18+ and either Vim or Neovim.\nIf not installed, they will be installed automatically.\n\nWould you like to install GitHub Copilot for Vim/Neovim?" 12 80); then
    echo "Skipping GitHub Copilot for Vim/Neovim"
    return 0
  fi

  echo "Installing GitHub Copilot for Vim/Neovim"
  
  # Ensure Node.js meets minimum version requirement
  if ! ensure_nodejs_version 18 "GitHub Copilot"; then
    return 1
  fi

  # Refresh command hash table after possible Node.js installation
  hash -r

  # Source the N profile to get the updated PATH
  if [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/n-prefix.sh"
  fi

  # Be sure Windows npm don't get in the way
  if [[ -f "/etc/profile.d/rm-win-npm-path.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/rm-win-npm-path.sh"
  fi

  # Determine which editor(s) to configure
  local has_vim=false
  local has_nvim=false
  
  if command -v vim &> /dev/null; then
    has_vim=true
  fi
  
  if command -v nvim &> /dev/null; then
    has_nvim=true
  fi
  
  # If neither is installed, ask which one to install
  if [[ "${has_vim}" == false ]] && [[ "${has_nvim}" == false ]]; then
    local editor_choice
    # shellcheck disable=SC2155,SC2086
    editor_choice=$(
      menu --title "Editor Selection" "${DIALOG_TYPE}" "Neither Vim nor Neovim is installed.\nWhich would you like to install?\n[ENTER to confirm]:" 12 70 2 \
        "VIM_" "Install Vim" ${OFF} \
        "NEOVIM" "Install Neovim" ${OFF}
      # shellcheck disable=SC2188
      3>&1 1>&2 2>&3
    )
    
    if [[ ${editor_choice} == "CANCELLED" ]]; then
      echo "Installation cancelled."
      return 1
    fi
    
    if [[ ${editor_choice} == *"VIM_"* ]]; then
      echo "Installing Vim..."
      install_packages vim
      has_vim=true
    fi
    
    if [[ ${editor_choice} == *"NEOVIM"* ]]; then
      echo "Installing Neovim..."
      install_packages neovim
      has_nvim=true
    fi
  fi
  
  # Install vim-plug and configure copilot for vim
  if [[ "${has_vim}" == true ]]; then
    if ! setup_editor_copilot "Vim" "vim" "${HOME}/.vim/autoload" "${HOME}/.vimrc" "${HOME}/.vim/plugged"; then
      return 1
    fi
  fi
  
  # Install vim-plug and configure copilot for neovim
  if [[ "${has_nvim}" == true ]]; then
    if ! setup_editor_copilot "Neovim" "nvim" "${HOME}/.local/share/nvim/site/autoload" "${HOME}/.config/nvim/init.vim" "${HOME}/.local/share/nvim/plugged"; then
      return 1
    fi
  fi
  
  # Display success message
  display_success_message "${has_vim}" "${has_nvim}"
  return 0
}

main "$@"
