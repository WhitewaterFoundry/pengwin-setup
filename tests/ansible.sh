#!/bin/bash

source commons.sh

function testMain() {
  run_pengwinsetup autoinstall TOOLS ANSIBLE

  # shellcheck disable=SC2041
  for i in 'ansible' ; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/ansible
  assertEquals "Ansible was not installed" "0" "$?"
  assertEquals "Ansible was not installed" "1" "$(run_command_as_testuser /usr/bin/ansible --version | grep -c '2.9')"
}

function testUninstall() {
  run_pengwinsetup autoinstall UNINSTALL ANSIBLE

  # shellcheck disable=SC2041
  for i in 'ansible' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/ansible
  assertEquals "Ansible was not uninstalled" "1" "$?"
}

source shunit2
