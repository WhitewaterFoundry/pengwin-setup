#!/bin/bash
source commons.sh

function test_install() {

  run_pengwinsetup install PROGRAMMING JETBRAINS --debug

  local i
  for i in 'rsync' 'zip'; do
    package_installed "$i"
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "Toolbox was not installed" "1" "$(run ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox --version | grep -c 'Toolbox 3')"
}

# shellcheck disable=SC1091
source shunit2
