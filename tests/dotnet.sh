#!/bin/bash

source commons.sh

function testMain() {
  run_pengwinsetup autoinstall PROGRAMMING DOTNET

  for i in 'dotnet-sdk-5.0' 'nuget'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals ".NET Core was not installed" "1" "$(run_command_as_testuser /usr/bin/dotnet --version | grep -c '5.0')"

  command -v /usr/bin/nuget
  assertEquals "NUGet was not installed" "0" "$?"
}

function testUninstall() {
  run_pengwinsetup autoinstall UNINSTALL DOTNET

  for i in 'dotnet-sdk-5.0' 'nuget'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/dotnet
  assertEquals ".NET Core was not uninstalled" "1" "$?"

  command -v /usr/bin/nuget
  assertEquals "NUGet was not uninstalled" "1" "$?"
}

source shunit2
