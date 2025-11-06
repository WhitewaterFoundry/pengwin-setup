#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Imported from common.sh
declare SetupDir

#######################################
# Install or upgrade Node.js LTS
# Globals:
#   SetupDir
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_nodejs_lts() {
  export SKIP_YARN=1
  bash "${SetupDir}"/nodejs.sh install PROGRAMMING NODEJS LTS
  local status=$?
  unset SKIP_YARN
  
  if [[ ${status} != 0 ]]; then
    return "${status}"
  fi
  
  # Refresh the command hash table to recognize newly installed binaries
  hash -r
  return 0
}

#######################################
# Install vim-plug for vim
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_vim_plug() {
  local vim_plug_dir="${HOME}/.vim/autoload"
  local vim_plug_file="${vim_plug_dir}/plug.vim"
  
  if [[ -f "${vim_plug_file}" ]]; then
    echo "vim-plug already installed for vim"
    return 0
  fi
  
  echo "Installing vim-plug for vim..."
  mkdir -p "${vim_plug_dir}"
  if curl -fLo "${vim_plug_file}" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    echo "vim-plug installed successfully for vim"
    return 0
  else
    echo "ERROR: Failed to install vim-plug for vim"
    return 1
  fi
}

#######################################
# Install vim-plug for neovim
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_nvim_plug() {
  local nvim_plug_dir="${HOME}/.local/share/nvim/site/autoload"
  local nvim_plug_file="${nvim_plug_dir}/plug.vim"
  
  if [[ -f "${nvim_plug_file}" ]]; then
    echo "vim-plug already installed for neovim"
    return 0
  fi
  
  echo "Installing vim-plug for neovim..."
  mkdir -p "${nvim_plug_dir}"
  if curl -fLo "${nvim_plug_file}" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    echo "vim-plug installed successfully for neovim"
    return 0
  else
    echo "ERROR: Failed to install vim-plug for neovim"
    return 1
  fi
}

#######################################
# Configure copilot.vim plugin in vimrc
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function configure_vim_copilot() {
  local vimrc="${HOME}/.vimrc"
  
  # Check if copilot is already configured
  if [[ -f "${vimrc}" ]] && grep -q "github/copilot.vim" "${vimrc}"; then
    echo "GitHub Copilot already configured in .vimrc"
    return 0
  fi
  
  echo "Configuring GitHub Copilot in .vimrc..."
  
  # Create or update .vimrc with vim-plug section
  if ! grep -q "call plug#begin" "${vimrc}" 2>/dev/null; then
    cat >> "${vimrc}" <<'EOF'

" vim-plug plugins
call plug#begin('~/.vim/plugged')
Plug 'github/copilot.vim'
call plug#end()
EOF
  else
    # Add copilot to existing plug#begin section
    if ! grep -q "Plug 'github/copilot.vim'" "${vimrc}"; then
      sed -i "/call plug#begin/a Plug 'github/copilot.vim'" "${vimrc}"
    fi
  fi
  
  echo "GitHub Copilot configured in .vimrc"
  return 0
}

#######################################
# Configure copilot.vim plugin in init.vim
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function configure_nvim_copilot() {
  local nvim_config_dir="${HOME}/.config/nvim"
  local init_vim="${nvim_config_dir}/init.vim"
  
  mkdir -p "${nvim_config_dir}"
  
  # Check if copilot is already configured
  if [[ -f "${init_vim}" ]] && grep -q "github/copilot.vim" "${init_vim}"; then
    echo "GitHub Copilot already configured in init.vim"
    return 0
  fi
  
  echo "Configuring GitHub Copilot in init.vim..."
  
  # Create or update init.vim with vim-plug section
  if ! grep -q "call plug#begin" "${init_vim}" 2>/dev/null; then
    cat >> "${init_vim}" <<'EOF'

" vim-plug plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'github/copilot.vim'
call plug#end()
EOF
  else
    # Add copilot to existing plug#begin section
    if ! grep -q "Plug 'github/copilot.vim'" "${init_vim}"; then
      sed -i "/call plug#begin/a Plug 'github/copilot.vim'" "${init_vim}"
    fi
  fi
  
  echo "GitHub Copilot configured in init.vim"
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
  
  # Check if nodejs is installed and if version meets requirements
  if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js LTS..."
    if ! install_nodejs_lts; then
      echo "Failed to install Node.js. Cannot proceed with GitHub Copilot installation."
      return 1
    fi
  else
    # Check Node.js version - handle both vX.Y.Z and X.Y.Z formats
    local node_version
    node_version=$(node --version | sed 's/^v//' | cut -d'.' -f1)
    if [[ ${node_version} -lt 18 ]]; then
      echo "Node.js version ${node_version} is below required version 18."
      if (confirm --title "Node.js Upgrade" --yesno "Your Node.js version (${node_version}) is below the required version (18).\n\nWould you like to upgrade Node.js to LTS?" 10 80); then
        echo "Upgrading Node.js to LTS..."
        if ! install_nodejs_lts; then
          echo "Failed to upgrade Node.js. Cannot proceed with GitHub Copilot installation."
          return 1
        fi
      else
        echo "Skipping GitHub Copilot installation due to incompatible Node.js version."
        return 1
      fi
    fi
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
        "VIM" "Install Vim" ${OFF} \
        "NEOVIM" "Install Neovim" ${OFF}
      # shellcheck disable=SC2188
      3>&1 1>&2 2>&3
    )
    
    if [[ ${editor_choice} == "CANCELLED" ]]; then
      echo "Installation cancelled."
      return 1
    fi
    
    if [[ ${editor_choice} == *"VIM"* ]]; then
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
    echo "Configuring GitHub Copilot for Vim..."
    if ! install_vim_plug; then
      echo "ERROR: Failed to install vim-plug for Vim"
      return 1
    fi
    configure_vim_copilot
  fi
  
  # Install vim-plug and configure copilot for neovim
  if [[ "${has_nvim}" == true ]]; then
    echo "Configuring GitHub Copilot for Neovim..."
    if ! install_nvim_plug; then
      echo "ERROR: Failed to install vim-plug for Neovim"
      return 1
    fi
    configure_nvim_copilot
  fi
  
  # Install the plugin(s)
  echo ""
  echo "Installing GitHub Copilot plugin..."
  if [[ "${has_vim}" == true ]]; then
    echo "Running :PlugInstall for Vim..."
    vim +PlugInstall +qall 2>/dev/null || true
  fi
  
  if [[ "${has_nvim}" == true ]]; then
    echo "Running :PlugInstall for Neovim..."
    nvim --headless +PlugInstall +qall 2>/dev/null || true
  fi
  
  echo ""
  echo "GitHub Copilot for Vim/Neovim installed successfully!"
  echo ""
  echo "To authenticate and start using GitHub Copilot:"
  if [[ "${has_vim}" == true ]]; then
    echo "  1. Open Vim: vim"
    echo "  2. Run: :Copilot setup"
  fi
  if [[ "${has_nvim}" == true ]]; then
    echo "  1. Open Neovim: nvim"
    echo "  2. Run: :Copilot setup"
  fi
  echo ""
  echo "After setup, Copilot will provide inline suggestions as you type."
  echo "Press Tab to accept suggestions."
  
  local msg="GitHub Copilot for Vim/Neovim installed successfully!\n\nTo authenticate and start using GitHub Copilot:\n"
  if [[ "${has_vim}" == true ]]; then
    msg="${msg}  1. Open Vim and run: :Copilot setup\n"
  fi
  if [[ "${has_nvim}" == true ]]; then
    msg="${msg}  1. Open Neovim and run: :Copilot setup\n"
  fi
  msg="${msg}\nAfter setup, Copilot will provide inline suggestions as you type.\nPress Tab to accept suggestions."
  
  message --title "GitHub Copilot for Vim/Neovim" --msgbox "${msg}" 16 70
  return 0
}

main "$@"
