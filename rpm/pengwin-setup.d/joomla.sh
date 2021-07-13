#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir
declare wHome
JOOMLA_VERSION="3-9-8"

function install_joomla() {

  if (confirm --title "Joomla" --yesno "Would you like to install the Joomla development server? It includes LAMP Stack" 10 60) ; then

    bash ${SetupDir}/lamp.sh "$@" --yes

    createtmp
    sudo service mysql start

    sudo sed -i "s/\(output_buffering = \)\([0-9]*\)/\1Off/" /etc/php/7.*/apache2/php.ini
    sudo service apache2 restart

    wget -O Joomla.tar.bz2 https://downloads.joomla.org/cms/joomla3/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.bz2?format=bz2

    local joomla_root="${wHome}/joomla_root"
    mkdir -p "${joomla_root}"
    sudo tar -xjvf Joomla.tar.bz2 --overwrite --directory "${joomla_root}"
    sudo chown -R www-data:www-data "${joomla_root}/installation"

    sudo ln -s "${joomla_root}" /var/www/html/joomla_root
    sudo mysql -u root << EOF

CREATE DATABASE joomla;
GRANT ALL PRIVILEGES ON joomla.* TO 'joomla'@'localhost' IDENTIFIED BY 'joomla';

EOF
    wslview "http://localhost/joomla_root/index.php"

    cleantmp

    bash ${SetupDir}/services.sh --enable-ssh
  else
    echo "Skipping Joomla"
  fi
}

function main() {

  install_joomla "$@"

}

main "$@"
