#!/bin/bash

source commons.sh

function testMain() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup autoinstall PROGRAMMING DOTNET

  for i in 'dotnet-sdk-7.0' 'nuget'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals ".NET Core was not installed" "1" "$(run_command_as_testuser /usr/bin/dotnet --version | grep -c '7.0')"

  command -v /usr/bin/nuget
  assertEquals "NUGet was not installed" "0" "$?"
}

function testUninstall() {
  # shellcheck disable=SC2155
  local dist="$(uname -m)"
  if [[ ${dist} != "x86_64" ]] ; then
    return
  fi

  run_pengwinsetup autoinstall UNINSTALL DOTNET

  for i in 'dotnet-sdk-7.0' 'nuget'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/dotnet
  assertEquals ".NET Core was not uninstalled" "1" "$?"

  command -v /usr/bin/nuget
  assertEquals "NUGet was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
