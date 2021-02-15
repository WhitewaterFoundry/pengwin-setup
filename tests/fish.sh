#!/bin/bash

source commons.sh

declare TEST_USER

function testMain() {
  # shellcheck disable=SC2155

  run_pengwinsetup autoinstall SETTINGS SHELLS FISH

  # shellcheck disable=SC2041
  for i in 'fish' ; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/fish
  assertEquals "FISH was not installed" "0" "$?"
  assertEquals "Fish is not the default shell" "$(command -v fish)" "$(grep ${TEST_USER} </etc/passwd | cut -f 7 -d ":")"
  assertTrue "FILE update-motd.fish" "[ -f /etc/fish/conf.d/update-motd.fish ]"
}

function testUninstall() {
  # shellcheck disable=SC2155
  run_pengwinsetup autoinstall UNINSTALL FISH

  # shellcheck disable=SC2041
  for i in 'fish' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/fish
  assertEquals "FISH was not uninstalled" "1" "$?"
  assertEquals "Bash is not the default shell" "$(command -v bash)" "$(grep ${TEST_USER} </etc/passwd | cut -f 7 -d ":")"
  assertFalse "FILE update-motd.fish" "[ -f /etc/fish/conf.d/update-motd.fish ]"

}

# shellcheck disable=SC1091
source shunit2
