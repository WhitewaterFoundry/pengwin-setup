#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

function install_lamp() {

  if (confirm --title "LAMP Stack" --yesno "Would you like to install the LAMP Stack?" 10 60); then

    echo "MariaDB Choice for LAMP Stack"
    # shellcheck disable=SC2155
    local menu_choice=$(

      menu --title "MariaDB" --radiolist "Choose what version of MariaDB you want to install\n[SPACE to select, ENTER to confirm]:" 14 65 6 \
        "10.3" "Install MariaDB 10.3 from MariaDB" off \
        "10.4" "Install MariaDB 10.4 from MariaDB" off \
        "10.5" "Install MariaDB 10.5 from MariaDB" off \
        "10.6" "Install MariaDB 10.6 from MariaDB" off \
        "10.11" "Install MariaDB 10.11 from MariaDB" off \
        "BUILTIN" "Install MariaDB from Debian Official Repo    " off

      # shellcheck disable=SC2188
      3>&1 1>&2 2>&3
    )

    echo "Installing MariaDB Database Server"

    if [[ ${menu_choice} == "CANCELLED" ]] || [[ ${menu_choice} == "BUILTIN" ]]; then
      install_packages mariadb-server mariadb-client
      apt policy mariadb-server
    else
      if curl -sSO https://downloads.mariadb.com/MariaDB/mariadb-keyring-2019.gpg; then
        if curl -sS https://downloads.mariadb.com/MariaDB/mariadb-keyring-2019.gpg.sha256 | sha256sum -c --quiet; then
          echo 'Running apt-get update...'
          if sudo mv mariadb-keyring-2019.gpg /etc/apt/trusted.gpg.d/ &&
            sudo apt-get -q update; then
            echo 'Done adding trusted package signing keys'
          else
            echo 'Failed to add trusted package signing keys'
            exit 1
          fi
        else
          echo 'Failed to verify trusted package signing keys keyring file'
          exit 1
        fi
      else
        echo 'Failed to download trusted package signing keys keyring file'
      fi
      sudo apt-get -y -q install software-properties-common
      sudo add-apt-repository "deb http://downloads.mariadb.com/MariaDB/mariadb-${menu_choice}/repo/debian buster main"
      sudo apt-get -q update
      install_packages -t buster mariadb-server mariadb-client
      apt policy mariadb-server
    fi

    service mariadb status

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

    startLamp="/usr/bin/start-lamp"
    #local startLamp
    sudo tee "${startLamp}" <<EOF
#!/bin/bash

mysql_status=\$(service mysql status)
if [[ \${mysql_status} = *"is stopped"* ]]; then
  service mysql --full-restart > /dev/null 2>&1
fi

apache2_status=\$(service apache2 status)
if [[ \${apache2_status} = *"is not running"* ]]; then
  service apache2 --full-restart > /dev/null 2>&1
fi

EOF

    sudo chmod 700 "${startLamp}"

    echo "%sudo   ALL=NOPASSWD: ${startLamp}" | sudo EDITOR='tee -a' visudo --quiet --file=/etc/sudoers.d/start-lamp

    profile_start_lamp="/etc/profile.d/start-lamp.sh"
    sudo tee "${profile_start_lamp}" <<EOF
#!/bin/bash

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  sudo ${startLamp}

fi

EOF

  else
    echo "Skipping SSH Server"
  fi

}

function main() {

  install_lamp

}

main
