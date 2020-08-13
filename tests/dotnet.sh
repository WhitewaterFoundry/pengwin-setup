#!/bin/bash

source commons.sh

function testMain() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive PROGRAMMING DOTNET --debug #> /dev/null 2>&1

  for i in 'dotnet-sdk-3.1' 'nuget'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals ".NET Core was not installed" "1" "$(/usr/bin/dotnet --version | grep -c '3.1')"

  command -v /usr/bin/nuget
  assertEquals "NUGet was not installed" "0" "$?"
}

function testUninstall() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive UNINSTALL DOTNET > /dev/null 2>&1

  for i in 'dotnet-sdk-3.1' 'nuget'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/dotnet
  assertEquals ".NET Core was not uninstalled" "1" "$?"

  command -v /usr/bin/nuget
  assertEquals "NUGet was not uninstalled" "1" "$?"
}

source shunit2
