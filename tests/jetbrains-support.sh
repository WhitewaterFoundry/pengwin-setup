#!/bin/bash
source commons.sh

function test_install() {

  run_pengwinsetup install PROGRAMMING JETBRAINS

  local i
  for i in 'rsync' 'zip'; do
    package_installed "$i"
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "Toolbox was not installed" "1" "$(run ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox --version | grep -c 'Toolbox')"
}

function test_uninstall() {

  run_pengwinsetup install UNINSTALL JETBRAINS

  assertFalse "Toolbox directory still exists" "[ -d /home/${TEST_USER}/.local/share/JetBrains/Toolbox ]"
  assertFalse "Toolbox symlink still exists" "[ -L /home/${TEST_USER}/.local/bin/jetbrains-toolbox ]"
}

# shellcheck disable=SC1091
source shunit2
