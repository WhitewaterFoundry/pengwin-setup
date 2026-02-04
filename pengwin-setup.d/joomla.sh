#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir
declare wHome
JOOMLA_VERSION="5.2.1"
JOOMLA_TAG="5.2.1"

#######################################
# Install Joomla CMS development environment
# Globals:
#   SetupDir
#   wHome
#   JOOMLA_VERSION
#   JOOMLA_TAG
# Arguments:
#   None
#######################################
function install_joomla() {

  if (confirm --title "Joomla" --yesno "Would you like to install the Joomla ${JOOMLA_VERSION} development server? It includes LAMP Stack" 10 70) ; then

    start_apt_progress

    echo "Installing LAMP Stack for Joomla"
    if ! bash "${SetupDir}"/lamp.sh "$@" --yes; then
      echo "Error: Failed to install LAMP stack. Cannot continue with Joomla installation."
      return 1
    fi

    createtmp
    
    echo "Starting MySQL service"
    # Start MySQL/MariaDB based on init system
    if is_systemd_running; then
      sudo systemctl start mariadb || sudo systemctl start mysql
    else
      sudo service mysql start || sudo service mariadb start
    fi
    
    # Update PHP configuration for Joomla 5
    echo "Configuring PHP for Joomla"
    local php_ini
    php_ini=$(find /etc/php -name "php.ini" -path "*/apache2/*" 2>/dev/null | head -1)
    
    if [[ -n "${php_ini}" ]]; then
      sudo sed -i "s/\(output_buffering = \)\([0-9]*\)/\1Off/" "${php_ini}"
      sudo sed -i "s/;*\(memory_limit = \).*/\1256M/" "${php_ini}"
      sudo sed -i "s/;*\(upload_max_filesize = \).*/\110M/" "${php_ini}"
      sudo sed -i "s/;*\(post_max_size = \).*/\113M/" "${php_ini}"
    fi
    
    # Restart apache2 based on init system
    if is_systemd_running; then
      sudo systemctl restart apache2
    else
      sudo service apache2 restart
    fi

    echo "Downloading Joomla ${JOOMLA_VERSION}"
    # Download from GitHub releases
    if ! wget -O Joomla.tar.gz "https://github.com/joomla/joomla-cms/releases/download/${JOOMLA_TAG}/Joomla_${JOOMLA_TAG}-Stable-Full_Package.tar.gz"; then
      echo "Error: Failed to download Joomla. Please check your internet connection."
      cleantmp
      return 1
    fi

    local joomla_root="/var/www/html/joomla_root"
    echo "Installing Joomla to ${joomla_root}"
    sudo mkdir -p "${joomla_root}"
    if ! sudo tar -xzvf Joomla.tar.gz --overwrite --directory "${joomla_root}"; then
      echo "Error: Failed to extract Joomla archive."
      cleantmp
      return 1
    fi
    
    sudo chown -R www-data:www-data "${joomla_root}"
    
    echo "Setting up Joomla database"
    if ! sudo mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS joomla;
CREATE USER IF NOT EXISTS 'joomla'@'localhost' IDENTIFIED BY 'joomla';
GRANT ALL PRIVILEGES ON joomla.* TO 'joomla'@'localhost';
FLUSH PRIVILEGES;
EOF
    then
      echo "Warning: Database setup may have failed. You may need to configure it manually."
    fi

    end_apt_progress

    echo ""
    echo "Joomla ${JOOMLA_VERSION} installation complete!"
    echo "Database: joomla"
    echo "Database User: joomla"
    echo "Database Password: joomla"
    echo ""
    echo "Opening Joomla installer in browser..."
    
    wslview "http://localhost/joomla_root/index.php" 2>/dev/null || echo "Please open http://localhost/joomla_root/index.php in your browser"

    cleantmp

  else
    echo "Skipping Joomla"
  fi
}

#######################################
# Main function
# Arguments:
#   None
#######################################
function main() {

  install_joomla "$@"

}

main "$@"
