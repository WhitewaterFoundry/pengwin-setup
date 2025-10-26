#!/bin/bash

source commons.sh
source mocks.sh

mariadb_version="${1:-BUILTIN}"
shift

#######################################
# Test LAMP installation
# Globals:
#   i
#   mariadb_version
# Arguments:
#  None
#######################################
function test_lamp() {

  run_pengwinsetup install SERVICES LAMP "${mariadb_version}"

  for i in 'mariadb-server' 'mariadb-client' 'apache2' 'php' 'libdbi-perl'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done


  local mariadb_version_number

  if [[ "${mariadb_version}" == "BUILTIN" ]]; then
    mariadb_version_number="11.*MariaDB"
  else
    mariadb_version_number="${mariadb_version}"
  fi

  local mariadb_command
  mariadb_command="/usr/bin/mariadb"

  assertTrue "MySQL was not installed" "[ -x ${mariadb_command} ]"

  "${mariadb_command}" --version
  assertEquals "MySQL was not installed" "1" "$("${mariadb_command}" --version | grep -c "${mariadb_version_number}")"
}

#######################################
# Test LAMP uninstall
# Globals:
#   i
#   mariadb_version
# Arguments:
#  None
#######################################
function test_uninstall() {
  run_pengwinsetup uninstall LAMP

  for i in 'mariadb-server' 'mariadb-client' 'apache2' 'php' 'libdbi-perl'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  local mariadb_command
  if [[ "${mariadb_version}" == "10.3" ]]; then
    mariadb_command="/usr/bin/mysql"
  else
    mariadb_command="/usr/bin/mariadb"
  fi

  assertFalse "MySQL was not uninstalled" "[ -x ${mariadb_command} ]"

}

# shellcheck disable=SC1091
source shunit2
