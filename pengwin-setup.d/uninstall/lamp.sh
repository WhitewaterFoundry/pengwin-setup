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

  sudo a2dismod php8.4

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
