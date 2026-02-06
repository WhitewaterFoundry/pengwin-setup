#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

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
# Remove XDG directory symlink (only if it is a symlink)
# Globals:
#   None
# Arguments:
#   1 - Directory path
# Returns:
#   None
#######################################
function remove_xdg_symlink() {
  local dir_path="$1"

  if [[ -L "${dir_path}" ]]; then
    echo "Removing symlink: ${dir_path}"
    rm -f "${dir_path}"
  else
    echo "Not a symlink, skipping: ${dir_path}"
  fi
}

#######################################
# Main uninstall function
# Globals:
#   HOME
#   XDG_CONFIG_HOME
# Arguments:
#   None
# Returns:
#   None
#######################################
function main() {
  local xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
  local user_dirs_file="${xdg_config_home}/user-dirs.dirs"

  echo "Uninstalling XDG user directories mapping..."

  # XDG constants to process
  local xdg_constants=("XDG_DESKTOP_DIR" "XDG_DOCUMENTS_DIR" "XDG_DOWNLOAD_DIR" "XDG_MUSIC_DIR" "XDG_PICTURES_DIR" "XDG_VIDEOS_DIR" "XDG_TEMPLATES_DIR" "XDG_PUBLICSHARE_DIR")

  # Remove symlinks based on user-dirs.dirs file (handles localized names)
  if [[ -f "${user_dirs_file}" ]]; then
    for xdg_const in "${xdg_constants[@]}"; do
      local xdg_dir_path
      xdg_dir_path=$(get_xdg_dir_from_config "${user_dirs_file}" "${xdg_const}")

      if [[ -n "${xdg_dir_path}" ]]; then
        remove_xdg_symlink "${xdg_dir_path}"
      fi
    done

    # Delete the user-dirs.dirs file
    echo "Removing user-dirs.dirs configuration file..."
    rm -f "${user_dirs_file}"
  else
    echo "user-dirs.dirs file not found, skipping symlink removal"
  fi

  # Regenerate XDG directories
  if command -v xdg-user-dirs-update &>/dev/null; then
    echo "Regenerating XDG user directories..."
    xdg-user-dirs-update
  fi

  # Ask if user wants to remove xdg-user-dirs package
  if (confirm --title "xdg-user-dirs Package" --yesno "Would you like to also remove the xdg-user-dirs package?" 8 60); then
    remove_package "xdg-user-dirs"
  else
    echo "Keeping xdg-user-dirs package installed"
  fi

  echo "XDG user directories mapping removed successfully!"
}

if show_warning "XDG User Directories Mapping" "$@"; then
  main "$@"
fi
