#!/bin/bash

source commons.sh

function testMain() {

  run_pengwinsetup install PROGRAMMING C++

  for i in 'gcc' 'clang' 'gdb' 'build-essential' 'gdbserver' 'rsync' 'zip' 'pkg-config' 'cmake'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "Cmake was not installed" "1" "$(run /usr/bin/cmake --version | grep -c '3')"
}

function testUninstall() {

  run_pengwinsetup uninstall C++ > /dev/null 2>&1

  for i in 'cmake' 'clang'; do
    package_installed "$i"
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/cmake
  assertEquals "Cmake was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
