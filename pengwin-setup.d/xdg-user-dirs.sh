#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Mapping of XDG constants to Windows Known Folder identifiers
# Primary keys for wslvar -L
declare -A XDG_TO_WINDOWS
XDG_TO_WINDOWS=(
  ["XDG_DESKTOP_DIR"]="Desktop"
  ["XDG_DOCUMENTS_DIR"]="Personal"
  ["XDG_DOWNLOAD_DIR"]="{374DE290-123F-4565-9164-39C4925E467B}"
  ["XDG_MUSIC_DIR"]="My Music"
  ["XDG_PICTURES_DIR"]="My Pictures"
  ["XDG_VIDEOS_DIR"]="My Video"
  ["XDG_TEMPLATES_DIR"]="Templates"
  ["XDG_PUBLICSHARE_DIR"]="PUBLIC"
)

# Alternate mappings for OneDrive-synced folders
declare -A XDG_TO_WINDOWS_ALT
XDG_TO_WINDOWS_ALT=(
  ["XDG_DOWNLOAD_DIR"]="{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}"
  ["XDG_DOCUMENTS_DIR"]="{24D89E24-2F19-4534-9DDE-6A6671FBB8FE}"
  ["XDG_MUSIC_DIR"]="{A0C69A99-21C8-4671-8703-7934162FCF1D}"
  ["XDG_PICTURES_DIR"]="{0DDD015D-B06C-45D5-8C4C-F59713854639}"
  ["XDG_VIDEOS_DIR"]="{35286A68-3C57-41A1-BBB1-0EAE73D76C95}"
)

# Cached wslvar results (populated once)
declare -A WSLVAR_L_CACHE
declare -A WSLVAR_S_CACHE

#######################################
# Load wslvar -L results into cache
# Globals:
#   WSLVAR_L_CACHE
# Arguments:
#   None
# Returns:
#   None
#######################################
function load_wslvar_l_cache() {
  local line key value
  while IFS= read -r line; do
    # Parse "Key : Value" format
    key=$(echo "${line}" | cut -d':' -f1 | sed 's/[[:space:]]*$//')
    value=$(echo "${line}" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | tr -d '\r')
    if [[ -n "${key}" && -n "${value}" ]]; then
      WSLVAR_L_CACHE["${key}"]="${value}"
    fi
  done < <(wslvar -L 2>/dev/null)
}

#######################################
# Load wslvar -S results into cache
# Globals:
#   WSLVAR_S_CACHE
# Arguments:
#   None
# Returns:
#   None
#######################################
function load_wslvar_s_cache() {
  local line key value
  while IFS= read -r line; do
    # Parse "Key : Value" format
    key=$(echo "${line}" | cut -d':' -f1 | sed 's/[[:space:]]*$//')
    value=$(echo "${line}" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | tr -d '\r')
    if [[ -n "${key}" && -n "${value}" ]]; then
      WSLVAR_S_CACHE["${key}"]="${value}"
    fi
  done < <(wslvar -S 2>/dev/null)
}

#######################################
# Get Windows folder path from cache
# Globals:
#   WSLVAR_L_CACHE
#   WSLVAR_S_CACHE
# Arguments:
#   1 - wslvar key (e.g., "Desktop", "{GUID}", "PUBLIC")
# Returns:
#   Windows path or empty string if not found
#######################################
function get_windows_path() {
  local key="$1"
  local win_path

  # Try wslvar -L cache first
  win_path="${WSLVAR_L_CACHE[${key}]}"

  if [[ -z "${win_path}" ]]; then
    # Try wslvar -S cache
    win_path="${WSLVAR_S_CACHE[${key}]}"
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
# Try to resolve a Windows key to a valid Linux path
# Globals:
#   None
# Arguments:
#   1 - Windows key (e.g., "Desktop", "{GUID}")
# Returns:
#   Linux path if valid and exists, empty string otherwise
#######################################
function try_resolve_windows_key() {
  local win_key="$1"
  local win_path
  local linux_path

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
# Get the Windows path for an XDG directory constant
# Tries primary key first, then alternate key
# Globals:
#   XDG_TO_WINDOWS
#   XDG_TO_WINDOWS_ALT
# Arguments:
#   1 - XDG constant name (e.g., "XDG_DESKTOP_DIR", "XDG_DOCUMENTS_DIR")
# Returns:
#   Linux path to Windows folder or empty string
#######################################
function get_xdg_windows_path() {
  local xdg_const="$1"
  local linux_path

  # Try primary key first, then alternate key (for OneDrive-synced folders)
  for mapping_array in "XDG_TO_WINDOWS" "XDG_TO_WINDOWS_ALT"; do
    local -n arr="${mapping_array}"
    linux_path=$(try_resolve_windows_key "${arr[${xdg_const}]}")
    if [[ -n "${linux_path}" ]]; then
      echo "${linux_path}"
      return
    fi
  done

  echo ""
}

#######################################
# Parse user-dirs.dirs file and extract directory path for a given XDG constant
# Globals:
#   HOME
# Arguments:
#   1 - user_dirs_file path
#   2 - XDG constant name (e.g., "XDG_DESKTOP_DIR")
# Returns:
#   Absolute path to the directory
#######################################
function get_xdg_dir_from_config() {
  local user_dirs_file="$1"
  local xdg_const="$2"
  local dir_value

  # Extract the value for the given XDG constant
  dir_value=$(grep "^${xdg_const}=" "${user_dirs_file}" 2>/dev/null | cut -d'=' -f2 | tr -d '"')

  if [[ -z "${dir_value}" ]]; then
    echo ""
    return
  fi

  # Replace $HOME with actual home directory
  dir_value="${dir_value/\$HOME/${HOME}}"

  echo "${dir_value}"
}

#######################################
# Create symlink from XDG directory to Windows folder
# Removes empty XDG directory if it exists and creates symlink
# Globals:
#   None
# Arguments:
#   1 - XDG directory path (full path from user-dirs.dirs)
#   2 - Target path (Windows folder in Linux path format)
# Returns:
#   0 on success, 1 on failure
#######################################
function create_xdg_symlink() {
  local xdg_path="$1"
  local target_path="$2"

  # Check if target exists
  if [[ ! -d "${target_path}" ]]; then
    echo "Target path does not exist: ${target_path}"
    return 1
  fi

  # If symlink already exists and points to correct location, skip
  if [[ -L "${xdg_path}" ]]; then
    # Canonicalize both paths for proper comparison
    local canonical_current
    local canonical_target
    canonical_current=$(readlink -f "${xdg_path}" 2>/dev/null || echo "")
    canonical_target=$(readlink -f "${target_path}" 2>/dev/null || echo "")
    if [[ "${canonical_current}" == "${canonical_target}" ]]; then
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

  echo "Loading Windows folder paths (this may take a moment)..."
  load_wslvar_l_cache
  load_wslvar_s_cache

  echo "Mapping XDG directories to Windows folders..."

  # XDG constants to process (read from user-dirs.dirs for localized names)
  local xdg_constants=("XDG_DESKTOP_DIR" "XDG_DOCUMENTS_DIR" "XDG_DOWNLOAD_DIR" "XDG_MUSIC_DIR" "XDG_PICTURES_DIR" "XDG_VIDEOS_DIR" "XDG_TEMPLATES_DIR" "XDG_PUBLICSHARE_DIR")

  local xdg_const
  for xdg_const in "${xdg_constants[@]}"; do
    local xdg_dir_path
    local target_path

    # Get the directory path from user-dirs.dirs (handles localization)
    xdg_dir_path=$(get_xdg_dir_from_config "${user_dirs_file}" "${xdg_const}")

    if [[ -z "${xdg_dir_path}" ]]; then
      echo "Could not find ${xdg_const} in user-dirs.dirs"
      continue
    fi

    # Get the corresponding Windows folder path
    target_path=$(get_xdg_windows_path "${xdg_const}")

    if [[ -n "${target_path}" ]]; then
      create_xdg_symlink "${xdg_dir_path}" "${target_path}"
    else
      echo "Could not find Windows path for ${xdg_const}"
    fi
  done

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
