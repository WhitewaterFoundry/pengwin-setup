#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Mapping of XDG directory names to Windows Known Folder identifiers
# Format: XDG_NAME:WSLVAR_KEY[:ALT_KEY]
# Some folders have multiple possible Windows identifiers (e.g., OneDrive-synced folders)
declare -A XDG_TO_WINDOWS
XDG_TO_WINDOWS=(
  ["DESKTOP"]="Desktop"
  ["DOCUMENTS"]="Personal"
  ["DOWNLOAD"]="{374DE290-123F-4565-9164-39C4925E467B}"
  ["MUSIC"]="My Music"
  ["PICTURES"]="My Pictures"
  ["VIDEOS"]="My Video"
  ["TEMPLATES"]="Templates"
)

# Additional mappings for OneDrive-synced folders
declare -A XDG_TO_WINDOWS_ALT
XDG_TO_WINDOWS_ALT=(
  ["DOWNLOAD"]="{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"
  ["DOCUMENTS"]="{24D89E24-2F19-4534-9DDE-6A6671FBB8FE}"
  ["MUSIC"]="{A0C69A99-21C8-4671-8703-7934162FCF1D}"
  ["PICTURES"]="{0DDD015D-B06C-45D5-8C4C-F59713854639}"
  ["VIDEOS"]="{35286A68-3C57-41A1-BBB1-0EAE73D76C95}"
)

#######################################
# Get Windows folder path using wslvar
# Globals:
#   None
# Arguments:
#   1 - wslvar key (e.g., "Desktop", "{GUID}")
# Returns:
#   Windows path or empty string if not found
#######################################
function get_windows_path() {
  local key="$1"
  local win_path

  # Try wslvar -L first (for Known Folders)
  win_path=$(wslvar -L "${key}" 2>/dev/null | tr -d '\r')

  if [[ -z "${win_path}" ]]; then
    # Try wslvar -S for shell folders
    win_path=$(wslvar -S "${key}" 2>/dev/null | tr -d '\r')
  fi

  echo "${win_path}"
}

#######################################
# Convert Windows path to Linux path
# Globals:
#   None
# Arguments:
#   1 - Windows path
# Returns:
#   Linux path or empty string if conversion fails
#######################################
function convert_to_linux_path() {
  local win_path="$1"
  local linux_path

  if [[ -n "${win_path}" ]]; then
    linux_path=$(wslpath -u "${win_path}" 2>/dev/null)
  fi

  echo "${linux_path}"
}

#######################################
# Get the Windows path for an XDG directory
# Tries primary key first, then alternate key
# Globals:
#   XDG_TO_WINDOWS
#   XDG_TO_WINDOWS_ALT
# Arguments:
#   1 - XDG directory name (e.g., "DESKTOP", "DOCUMENTS")
# Returns:
#   Linux path to Windows folder or empty string
#######################################
function get_xdg_windows_path() {
  local xdg_name="$1"
  local win_key
  local win_path
  local linux_path

  # Try primary key
  win_key="${XDG_TO_WINDOWS[${xdg_name}]}"
  if [[ -n "${win_key}" ]]; then
    win_path=$(get_windows_path "${win_key}")
    linux_path=$(convert_to_linux_path "${win_path}")

    if [[ -n "${linux_path}" && -d "${linux_path}" ]]; then
      echo "${linux_path}"
      return
    fi
  fi

  # Try alternate key (for OneDrive-synced folders)
  win_key="${XDG_TO_WINDOWS_ALT[${xdg_name}]}"
  if [[ -n "${win_key}" ]]; then
    win_path=$(get_windows_path "${win_key}")
    linux_path=$(convert_to_linux_path "${win_path}")

    if [[ -n "${linux_path}" && -d "${linux_path}" ]]; then
      echo "${linux_path}"
      return
    fi
  fi

  echo ""
}

#######################################
# Get PUBLIC folder path using wslvar -S
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Linux path to Windows Public folder
#######################################
function get_public_path() {
  local win_path
  local linux_path

  win_path=$(wslvar -S PUBLIC 2>/dev/null | tr -d '\r')
  if [[ -n "${win_path}" ]]; then
    linux_path=$(wslpath -u "${win_path}" 2>/dev/null)
    echo "${linux_path}"
  else
    echo ""
  fi
}

#######################################
# Create symlink from XDG directory to Windows folder
# Removes empty XDG directory if it exists and creates symlink
# Globals:
#   HOME
# Arguments:
#   1 - XDG directory name (e.g., "Desktop", "Documents")
#   2 - Target path (Windows folder in Linux path format)
# Returns:
#   0 on success, 1 on failure
#######################################
function create_xdg_symlink() {
  local xdg_dir_name="$1"
  local target_path="$2"
  local xdg_path="${HOME}/${xdg_dir_name}"

  # Check if target exists
  if [[ ! -d "${target_path}" ]]; then
    echo "Target path does not exist: ${target_path}"
    return 1
  fi

  # If symlink already exists and points to correct location, skip
  if [[ -L "${xdg_path}" ]]; then
    local current_target
    current_target=$(readlink -f "${xdg_path}")
    if [[ "${current_target}" == "${target_path}" ]]; then
      echo "Symlink already exists and is correct: ${xdg_path} -> ${target_path}"
      return 0
    else
      echo "Updating symlink: ${xdg_path} -> ${target_path}"
      rm -f "${xdg_path}"
    fi
  # If directory exists, check if empty and remove
  elif [[ -d "${xdg_path}" ]]; then
    if [[ -z "$(ls -A "${xdg_path}" 2>/dev/null)" ]]; then
      echo "Removing empty directory: ${xdg_path}"
      rmdir "${xdg_path}"
    else
      echo "Directory not empty, cannot replace: ${xdg_path}"
      return 1
    fi
  fi

  # Create symlink
  echo "Creating symlink: ${xdg_path} -> ${target_path}"
  ln -s "${target_path}" "${xdg_path}"
  return $?
}

#######################################
# Map XDG user directories to Windows folders
# Globals:
#   HOME
#   XDG_CONFIG_HOME
# Arguments:
#   None
# Returns:
#   0 on success
#######################################
function map_xdg_dirs() {
  local xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
  local user_dirs_file="${xdg_config_home}/user-dirs.dirs"

  echo "Installing xdg-user-dirs package..."
  install_packages xdg-user-dirs

  echo "Generating XDG user directories configuration..."
  xdg-user-dirs-update

  if [[ ! -f "${user_dirs_file}" ]]; then
    echo "Error: user-dirs.dirs file not created at ${user_dirs_file}"
    return 1
  fi

  echo "Mapping XDG directories to Windows folders..."

  # Map each XDG directory
  local xdg_names=("DESKTOP" "DOCUMENTS" "DOWNLOAD" "MUSIC" "PICTURES" "VIDEOS" "TEMPLATES")
  local dir_names=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Videos" "Templates")

  local i
  for i in "${!xdg_names[@]}"; do
    local xdg_name="${xdg_names[$i]}"
    local dir_name="${dir_names[$i]}"
    local target_path

    target_path=$(get_xdg_windows_path "${xdg_name}")

    if [[ -n "${target_path}" ]]; then
      create_xdg_symlink "${dir_name}" "${target_path}"
    else
      echo "Could not find Windows path for ${xdg_name}"
    fi
  done

  # Handle Public folder separately (uses wslvar -S PUBLIC)
  local public_path
  public_path=$(get_public_path)
  if [[ -n "${public_path}" ]]; then
    create_xdg_symlink "Public" "${public_path}"
  else
    echo "Could not find Windows Public folder path"
  fi

  echo "XDG user directories mapped successfully!"
  return 0
}

#######################################
# Main function for XDG user directories mapping
# Arguments:
#   Script arguments
# Returns:
#   0 on success, 1 on cancel
#######################################
function main() {
  if (confirm --title "XDG User Directories" --yesno "Would you like to map XDG user directories (Desktop, Documents, Downloads, etc.) to corresponding Windows Library folders?\n\nThis will:\n- Install xdg-user-dirs package\n- Create symbolic links from Linux home directories to Windows folders\n- Empty matching directories will be removed and replaced with symlinks\n\nThis helps integrate Linux GUI applications with Windows file locations." 16 76); then
    echo "Mapping XDG user directories to Windows folders..."
    map_xdg_dirs
  else
    echo "Skipping XDG user directories mapping"
  fi
}

main "$@"
