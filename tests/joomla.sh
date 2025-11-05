#!/bin/bash

source commons.sh
source mocks.sh

#######################################
# Test Joomla installation
# Globals:
#   None
# Arguments:
#   None
#######################################
function test_main() {

  run_pengwinsetup install PROGRAMMING JOOMLA --debug

  # Check if LAMP stack was installed (required dependency)
  for i in 'mariadb-server' 'apache2' 'php'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  # Check if Joomla directory was created
  local joomla_root="/mnt/c/Users/user/joomla_root"
  assertTrue "Joomla root directory was not created" "[ -d ${joomla_root} ]"

  # Check if symlink was created
  assertTrue "Joomla symlink was not created" "[ -L /var/www/html/joomla_root ]"

  # Check if database was created
  local db_exists
  db_exists=$(sudo mysql -u root -e "SHOW DATABASES LIKE 'joomla';" 2>/dev/null | grep -c joomla)
  assertTrue "Joomla database was not created" "[ ${db_exists} -ge 1 ]"

  # Check if database user was created
  local user_exists
  user_exists=$(sudo mysql -u root -e "SELECT User FROM mysql.user WHERE User='joomla';" 2>/dev/null | grep -c joomla)
  assertTrue "Joomla database user was not created" "[ ${user_exists} -ge 1 ]"

}

#######################################
# Test Joomla uninstall
# Globals:
#   None
# Arguments:
#   None
#######################################
function test_uninstall() {

  run_pengwinsetup uninstall JOOMLA --debug

  # Check if Joomla directory was removed
  local joomla_root="/mnt/c/Users/user/joomla_root"
  assertFalse "Joomla root directory was not removed" "[ -d ${joomla_root} ]"

  # Check if symlink was removed
  assertFalse "Joomla symlink was not removed" "[ -L /var/www/html/joomla_root ]"

  # Database and user should be preserved (user data)
  local db_count
  db_count=$(sudo mysql -u root -e "SHOW DATABASES LIKE 'joomla';" 2>/dev/null | grep -c joomla || echo 0)
  assertTrue "Joomla database should be preserved" "[ ${db_count} -ge 1 ]"

  local user_count
  user_count=$(sudo mysql -u root -e "SELECT User FROM mysql.user WHERE User='joomla';" 2>/dev/null | grep -c joomla || echo 0)
  assertTrue "Joomla database user should be preserved" "[ ${user_count} -ge 1 ]"

  # Note: LAMP stack should NOT be removed by Joomla uninstall
  for i in 'mariadb-server' 'apache2' 'php'; do
    package_installed $i
    assertTrue "package $i should not be uninstalled by Joomla uninstall" "$?"
  done

}

# shellcheck disable=SC1091
source shunit2
