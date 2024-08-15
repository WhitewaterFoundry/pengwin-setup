#!/bin/bash

source commons.sh

function testMain() {

  run_pengwinsetup install PROGRAMMING C++ --debug

  for i in 'gcc' 'clang' 'gdb' 'build-essential' 'gdbserver' 'rsync' 'zip' 'pkg-config' 'cmake'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "Cmake was not installed" "1" "$(run /usr/bin/cmake --version | grep -c '3')"

  if [[ "$(uname -m)" == "x86_64" ]] ; then
    assertEquals "MS Cmake was not installed" "1" "$(run /usr/local/bin/cmake --version | grep -c '3.1')"
  fi

}

function testUninstall() {

  run_pengwinsetup uninstall C++ > /dev/null 2>&1

  for i in 'cmake' 'clang'; do
    package_installed "$i"
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/cmake
  assertEquals "Cmake was not uninstalled" "1" "$?"

  if [[ "$(uname -m)" == "x86_64" ]] ; then
    command -v /usr/local/bin/cmake
    assertEquals "MS Cmake was not uninstalled" "1" "$?"
  fi
}

# shellcheck disable=SC1091
source shunit2
