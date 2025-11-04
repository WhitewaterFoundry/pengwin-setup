#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install GUI SYNAPTIC

  for i in 'synaptic' 'lsb-release' ; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/sbin/synaptic
  assertEquals "Synaptic was not installed" "0" "$?"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL SYNAPTIC

  # shellcheck disable=SC2041
  for i in 'synaptic' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/sbin/synaptic
  assertEquals "Synaptic was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
