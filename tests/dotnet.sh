#!/bin/bash

source commons.sh

function testMain() {
  run_pengwinsetup autoinstall PROGRAMMING DOTNET

  package_installed 'dotnet-sdk-10.0'
  assertTrue "package 'dotnet-sdk-10.0' is not installed" "$?"

  assertEquals ".NET Core was not installed" "1" "$(run /usr/bin/dotnet --version | grep -c '10.0')"
}

function testUninstall() {
  run_pengwinsetup autoinstall UNINSTALL DOTNET

  package_installed 'dotnet-sdk-10.0'
  assertFalse "package 'dotnet-sdk-10.0' is not uninstalled" "$?"

  command -v /usr/bin/dotnet
  assertEquals ".NET Core was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
