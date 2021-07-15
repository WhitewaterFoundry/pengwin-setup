#!/bin/bash

source commons.sh
source mocks.sh

mariadb_version="${1:-BUILTIN}"
shift

function testLAMP() {

  run_pengwinsetup install SERVICES LAMP "${mariadb_version}" --debug

  for i in 'mariadb-server' 'mariadb-client' 'apache2' 'php' 'libdbi-perl'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

}

function testUninstall() {
  run_pengwinsetup uninstall LAMP

  for i in 'mariadb-server' 'mariadb-client' 'apache2' 'php' 'libdbi-perl'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

}

# shellcheck disable=SC1091
source shunit2
