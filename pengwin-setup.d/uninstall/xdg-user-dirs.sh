#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

# List of XDG directory symlinks to remove
declare -a XDG_DIRS=("Desktop" "Documents" "Downloads" "Music" "Pictures" "Videos" "Templates" "Public")

#######################################
# Restore XDG directory by removing symlink and recreating empty directory
# Globals:
#   HOME
# Arguments:
#   1 - Directory name (e.g., "Desktop", "Documents")
# Returns:
#   None
#######################################
function restore_xdg_dir() {
  local dir_name="$1"
  local dir_path="${HOME}/${dir_name}"

  if [[ -L "${dir_path}" ]]; then
    echo "Removing symlink: ${dir_path}"
    rm -f "${dir_path}"

    echo "Recreating directory: ${dir_path}"
    mkdir -p "${dir_path}"
  else
    echo "Not a symlink, skipping: ${dir_path}"
  fi
}

#######################################
# Main uninstall function
# Globals:
#   HOME
#   XDG_DIRS
# Arguments:
#   None
# Returns:
#   None
#######################################
function main() {
  echo "Uninstalling XDG user directories mapping..."

  # Restore each XDG directory
  for dir_name in "${XDG_DIRS[@]}"; do
    restore_xdg_dir "${dir_name}"
  done

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
