#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#######################################
# description
# Globals:
#   DEBIAN_FRONTEND
#   HOME
#   NON_INTERACTIVE
#   profile_start_lamp
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function install_lamp() {

  if (confirm --title "LAMP Stack" --yesno "Would you like to install the LAMP Stack?" 10 60); then

    echo "MariaDB Choice for LAMP Stack"

    local menu_choice

    # shellcheck disable=SC2155
    menu_choice=$(

      menu --title "MariaDB" --radiolist "Choose what version of MariaDB you want to install\n[SPACE to select, ENTER to confirm]:" 12 70 3 \
        "10.3" "Install MariaDB 10.3 from MariaDB" off \
        "BUILTIN" "Install MariaDB 10.5 from Debian Official Repo    " off \
        "10.6" "Install MariaDB 10.6 from MariaDB" off

      # shellcheck disable=SC2188
      3>&1 1>&2 2>&3
    )
    echo "Selected:" "${menu_choice}"

    echo "Installing MariaDB Database Server"

    if [[ ${menu_choice} == "CANCELLED" ]]; then
      return 1
    fi

    # shellcheck disable=SC2155
    local selected_version=$(echo "${menu_choice##* }" | grep -E "10\.[1-6]?")
    if [[ -z ${selected_version} || ${menu_choice} == *"BUILTIN"* ]]; then

      if [[ -n ${NON_INTERACTIVE} ]]; then
        export DEBIAN_FRONTEND=noninteractive
      fi

      install_packages mariadb-server mariadb-client
      apt policy mariadb-server

    else
      createtmp

      sudo sed -i '/mariadb/d' /etc/apt/sources.list

      sudo apt-get -y -q install libdbi-perl

      curl -LsSO https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
      sudo bash mariadb_repo_setup --mariadb-server-version="mariadb-${selected_version}" --os-type=debian --os-version=buster

      if [[ -n ${NON_INTERACTIVE} ]]; then
        export DEBIAN_FRONTEND=noninteractive
        sudo debconf-set-selections <<< "mariadb-server-${selected_version} mysql-server/root_password password PASS"
        sudo debconf-set-selections <<< "mariadb-server-${selected_version} mysql-server/root_password_again password PASS"
      fi

      install_packages -t buster mariadb-server mariadb-client mariadb-backup
      apt policy mariadb-server

      cleantmp
    fi

    echo "Installing Apache Web Server"
    install_packages apache2 apache2-utils
    sudo service apache2 start
    sudo apache2 -v

    service apache2 status

    echo "Installing PHP"
    install_packages php libapache2-mod-php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
    sudo a2enmod php7.4

    php -v

    echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php

    sudo service apache2 restart

    wslview "http://localhost/phpinfo.php"

    echo "Installing LAMP as a service"

    local mariadb_service
    if [[ "${selected_version}" == "10.3" ]]; then
      mariadb_service="mysql"
    else
      mariadb_service="mariadb"
    fi

    local start_lamp="/usr/bin/start-lamp"
    sudo tee "${start_lamp}" <<EOF
#!/bin/bash

mysql_status=\$(service ${mariadb_service} status)
if [[ \${mysql_status} = *"is stopped"* ]]; then
  service ${mariadb_service} --full-restart > /dev/null 2>&1
fi

apache2_status=\$(service apache2 status)
if [[ \${apache2_status} = *"is not running"* ]]; then
  service apache2 --full-restart > /dev/null 2>&1
fi

EOF

    sudo chmod 700 "${start_lamp}"

    echo "%sudo   ALL=NOPASSWD: ${start_lamp}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/start-lamp

    profile_start_lamp="/etc/profile.d/start-lamp.sh"
    sudo tee "${profile_start_lamp}" <<EOF
#!/bin/sh

# Check if we have Windows Path
if ( command -v cmd.exe >/dev/null ); then

  sudo ${start_lamp}

fi

EOF

    touch "${HOME}"/.should-restart

    bash /etc/profile.d/start-lamp.sh

  else
    echo "Skipping SSH Server"
  fi

}

#######################################
# description
# Arguments:
#  None
#######################################
function main() {

  install_lamp

}

main
