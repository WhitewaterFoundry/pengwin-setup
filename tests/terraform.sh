#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup autoinstall TOOLS CLOUDCLI TERRAFORM

  command -v /usr/bin/terraform
  assertEquals "Terraform was not installed" "0" "$?"
  assertEquals "Terraform was not installed" "1" "$(run_command_as_testuser /usr/bin/terraform --version | grep -c '1.2')"
}

function test_uninstall() {
  run_pengwinsetup autoinstall UNINSTALL TERRAFORM

  command -v /usr/bin/terraform
  assertEquals "Terraform was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
