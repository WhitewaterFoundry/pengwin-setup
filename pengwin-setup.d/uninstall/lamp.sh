#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstalling LAMP stack"

sudo_rem_file "/etc/profile.d/start-lamp.sh"
sudo_rem_file "/etc/sudoers.d/start-lamp"

sudo_rem_file "/usr/bin/start-lamp"

remove_package "mariadb-server" "mariadb-client" "apache2" "apache2-utils" "php" "libapache2-mod-php" "php-cli" "php-fpm" "php-json" "php-pdo" "php-mysql" "php-zip" "php-gd" "php-mbstring" "php-curl" "php-xml" "php-pear" "php-bcmath"

sudo_rem_file "/var/www/html/phpinfo.php"

}

if show_warning "LAMP stack" "$@" ; then
	main "$@"
fi