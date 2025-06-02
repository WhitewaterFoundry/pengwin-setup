#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS CLOUDCLI TERRAFORM

  command -v /usr/bin/terraform

  run /usr/bin/terraform --version

  assertEquals "Terraform was not installed" "0" "$?"
  assertNotEquals "Terraform was not installed" "0" "$(run /usr/bin/terraform --version | grep -c '1.12')"
  assertNotEquals "Terraform needs to be updated in the installer," "2" "$(run /usr/bin/terraform --version | grep -c '1.12')"
}

function test_uninstall() {
  run_pengwinsetup uninstall TERRAFORM

  command -v /usr/bin/terraform
  assertNotEquals "Terraform was not uninstalled" "0" "$?"
}

# shellcheck disable=SC1091
source shunit2
