#!/bin/bash

# Common Node.js utility functions for pengwin-setup
# This file contains functions for detecting and managing Node.js version managers
# (N and NVM) and ensuring Node.js meets minimum version requirements.

#######################################
# Check if N version manager is installed
# Checks for N_PREFIX environment variable and n binary
# Globals:
#   N_PREFIX - N version manager prefix directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 if N is installed, 1 otherwise
#######################################
function is_n_installed() {
  # Source the profile script if it exists but N_PREFIX is not set
  if [[ -z "${N_PREFIX}" ]] && [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/n-prefix.sh"
  fi

  # Check if N_PREFIX is set and n binary exists
  if [[ -n "${N_PREFIX}" ]] && [[ -x "${N_PREFIX}/bin/n" ]]; then
    return 0
  fi

  # Also check default location
  if [[ -x "${HOME}/n/bin/n" ]]; then
    return 0
  fi

  return 1
}

#######################################
# Check if NVM (Node Version Manager) is installed
# Checks for NVM_DIR environment variable and nvm function/script
# Globals:
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 if NVM is installed, 1 otherwise
#######################################
function is_nvm_installed() {
  # Source the profile script if it exists but NVM_DIR is not set
  if [[ -z "${NVM_DIR}" ]] && [[ -f "/etc/profile.d/nvm-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/nvm-prefix.sh"
  fi

  # Check if NVM_DIR is set and nvm.sh exists
  if [[ -n "${NVM_DIR}" ]] && [[ -s "${NVM_DIR}/nvm.sh" ]]; then
    return 0
  fi

  # Also check default location
  if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
    return 0
  fi

  return 1
}

#######################################
# Install or upgrade Node.js using N version manager
# Installs N version manager and latest Node.js version
# Globals:
#   SetupDir - Directory containing setup scripts
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_nodejs_via_n() {
  export SKIP_YARN=1
  bash "${SetupDir}"/nodejs.sh install PROGRAMMING NODEJS NVERMAN
  local status=$?
  unset SKIP_YARN

  if [[ ${status} != 0 ]]; then
    return "${status}"
  fi

  # Refresh the command hash table to recognize newly installed binaries
  hash -r

  # Source the N profile to get the updated PATH
  if [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/n-prefix.sh"
  fi

  return 0
}

#######################################
# Install or upgrade Node.js using NVM version manager (requires NVM preinstalled)
# Installs latest Node.js version via NVM (using 'node' alias which points to latest)
# In NVM, 'nvm install node' installs/upgrades to the latest available version
# Note: This function assumes NVM is already installed and available in ${NVM_DIR}
#   or ${HOME}/.nvm; it does not install NVM itself.
# Globals:
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_nodejs_via_nvm() {
  # Ensure NVM is loaded
  local nvm_dir="${NVM_DIR:-${HOME}/.nvm}"

  if [[ -s "${nvm_dir}/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    source "${nvm_dir}/nvm.sh"
  else
    echo "NVM not found at ${nvm_dir}"
    return 1
  fi

  # 'node' is an NVM alias for the latest Node.js version
  echo "Installing latest Node.js via NVM..."
  if ! nvm install node --latest-npm; then
    echo "Failed to install Node.js via NVM"
    return 1
  fi

  # Refresh the command hash table to recognize newly installed binaries
  hash -r

  return 0
}

#######################################
# Upgrade Node.js using the installed version manager
# Detects which version manager is installed (N or NVM) and uses it to upgrade
# Globals:
#   N_PREFIX - N version manager prefix directory
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function upgrade_nodejs_via_version_manager() {
  # Check which version manager is installed and use it
  if is_n_installed; then
    echo "Upgrading Node.js via N version manager..."
    install_nodejs_via_n
    return $?
  elif is_nvm_installed; then
    echo "Upgrading Node.js via NVM..."
    install_nodejs_via_nvm
    return $?
  else
    echo "No version manager detected"
    return 1
  fi
}

#######################################
# Ensure Node.js meets minimum version requirement
# Checks if Node.js is installed via a version manager (N or NVM) and meets
# minimum version. If Node.js is installed via package manager but no version
# manager, installs N version manager to avoid npm permission issues.
# Globals:
#   N_PREFIX - N version manager prefix directory
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   $1: minimum required version (e.g., 18)
#   $2: product name for error messages (e.g., "GitHub Copilot")
# Returns:
#   0 on success, non-zero on failure
#######################################
function ensure_nodejs_version() {
  local min_version="$1"
  local product_name="$2"
  local has_version_manager=false
  local node_version

  # Check if a version manager is installed (N or NVM)
  if is_n_installed || is_nvm_installed; then
    has_version_manager=true
    echo "Node.js version manager detected."

    # Check if Node.js is available
    if ! command -v node &> /dev/null; then
      echo "Node.js not found. Loading version manager startup scripts"
      if is_n_installed; then
        # Source the profile script if it exists but N_PREFIX is not set
        if [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
          # shellcheck source=/dev/null
          source "/etc/profile.d/n-prefix.sh"
        fi
      fi

      if is_nvm_installed; then
        # Ensure NVM is loaded
        local nvm_dir="${NVM_DIR:-${HOME}/.nvm}"

        if [[ -s "${nvm_dir}/nvm.sh" ]]; then
          # shellcheck source=/dev/null
          source "${nvm_dir}/nvm.sh"
        fi
      fi
    fi
  fi

  # Check if Node.js is available
  if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js via N version manager..."
    if ! install_nodejs_via_n; then
      echo "Failed to install Node.js. Cannot proceed with ${product_name} installation."
      return 1
    fi
    return 0
  fi

  # Node.js exists - extract and validate version
  node_version=$(node --version 2>/dev/null | sed 's/^v//' | cut -d'.' -f1)

  # Validate that node_version is a valid integer
  if ! [[ "${node_version}" =~ ^[0-9]+$ ]]; then
    echo "Error: Unable to determine Node.js version. Got: '${node_version}'"
    echo "Please check your Node.js installation."
    return 1
  fi

  # Check version first to avoid prompting about version manager if version is already sufficient
  if [[ ${node_version} -ge ${min_version} ]]; then
    # Version is sufficient
    if [[ "${has_version_manager}" == false ]]; then
      # Node.js is installed via package manager but version is sufficient
      # Offer to install version manager to avoid potential npm permission issues
      echo "Node.js version ${node_version} meets requirements, but no version manager detected."
      echo "Installing via package manager can cause npm permission issues."

      if (confirm --title "Install Node.js Version Manager" --yesno "Node.js is installed via package manager, which can cause npm permission issues for plugins like ${product_name}.\n\nWould you like to install the N version manager to manage Node.js properly?\n\nNote: This will install Node.js in your home directory." 14 80); then
        echo "Installing N version manager..."
        if ! install_nodejs_via_n; then
          echo "Failed to install N version manager. Continuing with system Node.js."
        fi
      else
        echo "Continuing with system Node.js installation."
      fi
    fi
    return 0
  fi

  # Version is insufficient - need to upgrade
  echo "Node.js version ${node_version} is below required version ${min_version}."

  if [[ "${has_version_manager}" == true ]]; then
    # Version manager installed, offer to upgrade via it
    if (confirm --title "Node.js Upgrade" --yesno "Your Node.js version (${node_version}) is below the required version (${min_version}).\n\nWould you like to upgrade Node.js using the version manager?" 10 80); then
      echo "Upgrading Node.js..."
      if ! upgrade_nodejs_via_version_manager; then
        echo "Failed to upgrade Node.js. Cannot proceed with ${product_name} installation."
        return 1
      fi
    else
      echo "Skipping ${product_name} installation due to incompatible Node.js version."
      return 1
    fi
  else
    # No version manager, offer to install N version manager
    if (confirm --title "Node.js Upgrade" --yesno "Your Node.js version (${node_version}) is below the required version (${min_version}).\n\nWould you like to install the N version manager and upgrade Node.js?\n\nNote: This is recommended to avoid npm permission issues." 12 80); then
      echo "Installing N version manager and upgrading Node.js..."
      if ! install_nodejs_via_n; then
        echo "Failed to upgrade Node.js. Cannot proceed with ${product_name} installation."
        return 1
      fi
    else
      echo "Skipping ${product_name} installation due to incompatible Node.js version."
      return 1
    fi
  fi

  return 0
}
