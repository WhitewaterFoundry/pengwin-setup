#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

function install_lamp() {

  if (confirm --title "LAMP Stack" --yesno "Would you like to Install the LAMP Stack?" 10 60) ; then

    echo "Installing MariaDB Database Server"
    sudo apt-get -y -q install mariadb-server mariadb-client
    apt policy mariadb-server

    service mariadb status

    echo "Installing Apache Web Server"
    sudo apt-get -y -q install apache2 apache2-utils
    sudo service apache2 start
    sudo apache2 -v

    service apache2 status

    echo "Installing PHP"
    sudo apt-get -y -q install php libapache2-mod-php php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath
    sudo a2enmod php7.3

    php -v

    echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php

    wslview "http://localhost/phpinfo.php"

    echo "Installing LAMP as a service"

    startLamp="/usr/bin/start-lamp"
    #local startLamp
    sudo tee "${startLamp}" << EOF
#!/bin/bash

mysql_status=\$(service mysql status)
if [[ \${mysql_status} = *"is not running"* ]]; then
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
    sudo tee "${profile_start_lamp}" << EOF
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