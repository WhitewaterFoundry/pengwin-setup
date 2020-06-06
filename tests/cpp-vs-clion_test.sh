#!/bin/bash

source commons.sh

function testMain() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive PROGRAMMING C++

  for i in 'gcc' 'clang' 'gdb' 'build-essential' 'gdbserver' 'rsync' 'zip' 'pkg-config' 'cmake'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "MS Cmake was not installed" "1" "$(/usr/bin/cmake --version | grep -c '3.16')"
  assertEquals "Cmake was not installed" "1" "$(/usr/local/bin/cmake --version | grep -c '3.17')"
}

function testUninstall() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive UNINSTALL C++

  for i in 'cmake clang'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/cmake
  assertEquals "Cmake was not uninstalled" "1" "$?"

  command -v /usr/local/bin/cmake
  assertEquals "MS Cmake was not uninstalled" "1" "$?"
}

source shunit2
