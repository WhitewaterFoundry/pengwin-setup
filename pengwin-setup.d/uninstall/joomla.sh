#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#######################################
# Main uninstall function for Joomla
# Globals:
#   None
# Arguments:
#   None
#######################################
function main() {

  echo "Uninstalling Joomla"

  local joomla_root="/var/www/html/joomla_root"

  echo "Removing Joomla installation directory"
  if [[ -d "${joomla_root}" ]]; then
    sudo rm -rf "${joomla_root}"
    echo "... directory removed"
  else
    echo "... directory not found"
  fi

  echo "Joomla uninstallation complete"
  echo "Note: Joomla database and user are preserved as they may contain user data."
  echo "Note: LAMP stack was not removed. To remove it, use 'pengwin-setup uninstall LAMP'"

}

if show_warning "Joomla" "$@"; then
  main "$@"
fi
