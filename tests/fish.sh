#!/bin/bash

source commons.sh

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
  assertEquals "Fish is not the default shell" "$(grep $USER </etc/passwd | cut -f 7 -d ":")" "/usr/bin/fish"

}

function testUninstall() {
  # shellcheck disable=SC2155
  run_pengwinsetup autoinstall UNINSTALL FISH --debug

  # shellcheck disable=SC2041
  for i in 'fish' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/fish
  assertEquals "FISH was not uninstalled" "1" "$?"
  assertEquals "Bash is not the default shell" "$(grep $USER </etc/passwd | cut -f 7 -d ":")" "/usr/bin/bash"

}

source shunit2
