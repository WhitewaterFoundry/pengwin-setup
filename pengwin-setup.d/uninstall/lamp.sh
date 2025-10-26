#!/bin/bash

# shellcheck source=./uninstall-common.sh
source "$(dirname "$0")/uninstall-common.sh" "$@"

#######################################
# description
# Arguments:
#  None
#######################################
function main() {

  echo "Uninstalling LAMP stack"

  local php_module_version
  if command -v php >/dev/null; then
    php_module_version=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || true)
  fi

  if [[ -n ${php_module_version} ]]; then
    sudo a2dismod "php${php_module_version}"
  fi

  sudo_rem_file "/etc/profile.d/start-lamp.sh"
  sudo_rem_file "/etc/sudoers.d/start-lamp"

  sudo_rem_file "/usr/bin/start-lamp"

  remove_package "mariadb-server" "mariadb-client" "mariadb-backup" "apache2" "apache2-utils" "php" "libapache2-mod-php" "php-cli" "php-fpm" "php-json" "php-pdo" "php-mysql" "php-zip" "php-gd" "php-mbstring" "php-curl" "php-xml" "php-pear" "php-bcmath" "libdbi-perl"

  sudo_rem_file "/etc/apt/sources.list.d/mariadb.list"
  sudo_rem_file "/etc/apt/sources.list.d/mariadb.sources"
  sudo_rem_file "/etc/apt/preferences.d/mariadb-enterprise.pref"

  sudo_rem_file "/etc/apt/trusted.gpg.d/mariadb-keyring-2019.gpg"
  sudo_rem_file "/etc/apt/keyrings/mariadb-keyring.pgp"
  sudo_rem_file "/var/www/html/phpinfo.php"

  sudo apt-get -y autoremove

  sudo apt-get update
}

if show_warning "LAMP stack" "$@"; then
  main "$@"
fi
