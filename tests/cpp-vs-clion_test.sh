#!/bin/bash

source commons.sh

function testMain() {

  apt-get install -y -q libc6-dev
  return
  
  ../pengwin-setup --noupdate --assume-yes --noninteractive PROGRAMMING C++ --debug #> /dev/null 2>&1

  for i in 'gcc' 'clang' 'gdb' 'build-essential' 'gdbserver' 'rsync' 'zip' 'pkg-config' 'cmake'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "Cmake was not installed" "1" "$(/usr/bin/cmake --version | grep -c '3.16')"

  if [[ "$(uname -m)" == "x86_64" ]] ; then
    assertEquals "MS Cmake was not installed" "1" "$(/usr/local/bin/cmake --version | grep -c '3.17')"
  fi
  
}

function testUninstall() {

  ../pengwin-setup --noupdate --assume-yes --noninteractive UNINSTALL C++ > /dev/null 2>&1

  for i in 'cmake clang'; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/cmake
  assertEquals "Cmake was not uninstalled" "1" "$?"

  if [[ "$(uname -m)" == "x86_64" ]] ; then
    command -v /usr/local/bin/cmake
    assertEquals "MS Cmake was not uninstalled" "1" "$?"
  fi
}

source shunit2
