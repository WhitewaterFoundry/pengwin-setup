#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#######################################
# Main uninstall function for Joomla
# Globals:
#   wHome
# Arguments:
#   None
#######################################
function main() {

  echo "Uninstalling Joomla"

  local joomla_root="${wHome}/joomla_root"

  echo "Removing Joomla database"
  if command -v mysql >/dev/null 2>&1 || command -v mariadb >/dev/null 2>&1; then
    if sudo mysql -u root << EOF 2>/dev/null
DROP DATABASE IF EXISTS joomla;
DROP USER IF EXISTS 'joomla'@'localhost';
FLUSH PRIVILEGES;
EOF
    then
      echo "... database removed"
    else
      echo "... database removal failed (may not exist or MySQL not running)"
    fi
  else
    echo "... MySQL/MariaDB not found, skipping database removal"
  fi

  echo "Removing Joomla web directory symlink"
  sudo_rem_file "/var/www/html/joomla_root"

  echo "Removing Joomla installation directory"
  if [[ -d "${joomla_root}" ]]; then
    sudo rm -rf "${joomla_root}"
    echo "... directory removed"
  else
    echo "... directory not found"
  fi

  echo "Joomla uninstallation complete"
  echo "Note: LAMP stack was not removed. To remove it, use 'pengwin-setup uninstall LAMP'"

}

if show_warning "Joomla" "$@"; then
  main "$@"
fi
