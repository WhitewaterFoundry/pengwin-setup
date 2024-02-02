#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS ANSIBLE

  # shellcheck disable=SC2041
  for i in 'ansible' ; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/ansible
  assertEquals "Ansible was not installed" "0" "$?"

  export LANG="en_US.UTF-8"
  export LC_CTYPE="en.US.UTF-8"
  assertEquals "Ansible was not installed" "1" "$(run /usr/bin/ansible --version | grep -c 'ansible \[core 2')"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL ANSIBLE

  # shellcheck disable=SC2041
  for i in 'ansible' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/ansible
  assertEquals "Ansible was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
