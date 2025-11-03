#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir
declare wHome
JOOMLA_VERSION="5-2-1"
JOOMLA_MAJOR="5"

#######################################
# Install Joomla CMS development environment
# Globals:
#   SetupDir
#   wHome
#   JOOMLA_VERSION
#   JOOMLA_MAJOR
# Arguments:
#   None
#######################################
function install_joomla() {

  if (confirm --title "Joomla" --yesno "Would you like to install the Joomla ${JOOMLA_VERSION} development server? It includes LAMP Stack" 10 70) ; then

    echo "Installing LAMP Stack for Joomla"
    bash "${SetupDir}"/lamp.sh "$@" --yes
    
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to install LAMP stack. Cannot continue with Joomla installation."
      return 1
    fi

    createtmp
    
    echo "Starting MySQL service"
    sudo service mysql start || sudo service mariadb start
    
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
    
    sudo service apache2 restart

    echo "Downloading Joomla ${JOOMLA_VERSION}"
    wget -O Joomla.tar.bz2 "https://downloads.joomla.org/cms/joomla${JOOMLA_MAJOR}/${JOOMLA_VERSION}/Joomla_${JOOMLA_VERSION}-Stable-Full_Package.tar.bz2?format=bz2"
    
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to download Joomla. Please check your internet connection."
      cleantmp
      return 1
    fi

    local joomla_root="${wHome}/joomla_root"
    echo "Installing Joomla to ${joomla_root}"
    mkdir -p "${joomla_root}"
    sudo tar -xjvf Joomla.tar.bz2 --overwrite --directory "${joomla_root}"
    
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to extract Joomla archive."
      cleantmp
      return 1
    fi
    
    sudo chown -R www-data:www-data "${joomla_root}"

    # Create symlink if it doesn't exist
    if [[ ! -e "/var/www/html/joomla_root" ]]; then
      sudo ln -s "${joomla_root}" /var/www/html/joomla_root
    elif [[ ! -L "/var/www/html/joomla_root" ]]; then
      echo "Warning: /var/www/html/joomla_root exists but is not a symlink. Skipping symlink creation."
    fi
    
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
