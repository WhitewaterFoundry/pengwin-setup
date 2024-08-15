#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS CLOUDCLI TERRAFORM

  command -v /usr/bin/terraform
  assertEquals "Terraform was not installed" "0" "$?"
  assertEquals "Terraform was not installed" "1" "$(run /usr/bin/terraform --version | grep -c '1.9')"
}

function test_uninstall() {
  run_pengwinsetup uninstall TERRAFORM

  command -v /usr/bin/terraform
  assertEquals "Terraform was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
