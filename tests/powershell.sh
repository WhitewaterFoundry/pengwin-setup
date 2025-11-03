#!/bin/bash

source commons.sh

function test_main() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]]; then
    return
  fi

  run_pengwinsetup install TOOLS POWERSHELL

  # shellcheck disable=SC2041
  for i in 'powershell' ; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/pwsh
  assertEquals "PowerShell was not installed" "0" "$?"

  assertEquals "PowerShell was not installed" "1" "$(run /usr/bin/pwsh --version | grep -c 'PowerShell')"
}

function test_uninstall() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]]; then
    return
  fi

  run_pengwinsetup install UNINSTALL POWERSHELL

  # shellcheck disable=SC2041
  for i in 'powershell' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/pwsh
  assertEquals "PowerShell was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
