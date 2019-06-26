#!/usr/bin/env bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir
JOOMLA_VERSION="3-9-8"

function main() {

  createtmp

  bash ${SetupDir}/lamp.sh "$@" --yes

  sudo service mysql start

  sudo sed -i "s/\(output_buffering = \)\([0-9]*\)/\1Off/" /etc/php/7.*/apache2/php.ini
  sudo service apache2 restart

  wget -O Joomla.tar.bz2 https://downloads.joomla.org/cms/joomla3/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.bz2?format=bz2
  sudo tar -xjvf Joomla.tar.bz2 --overwrite --directory /var/www/html/ #--strip-components 1 docker/docker

  sudo chown -R www-data:www-data /var/www/html
  sudo rm -f /var/www/html/index.html

  sudo mysql -u root << EOF

CREATE DATABASE joomla;
GRANT ALL PRIVILEGES ON joomla.* TO 'joomla'@'localhost' IDENTIFIED BY 'joomla';

EOF
  wslview "http://localhost/index.php"

  cleantmp
}

main "$@"