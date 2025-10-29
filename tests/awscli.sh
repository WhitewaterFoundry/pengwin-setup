#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install TOOLS CLOUDCLI AWS

  command -v /usr/local/bin/aws

  run /usr/local/bin/aws --version

  assertEquals "AWS CLI was not installed" "0" "$?"
  assertNotEquals "AWS CLI version 2 was not installed" "0" "$(run /usr/local/bin/aws --version 2>&1 | grep -c 'aws-cli/2')"
}

function test_completion() {
  if [[ -f "/etc/bash_completion.d/aws" ]]; then
    assertEquals "AWS CLI bash completion was not installed" "0" "0"
  else
    assertEquals "AWS CLI bash completion was not installed" "0" "1"
  fi
}

function test_uninstall() {
  run_pengwinsetup uninstall AWS

  command -v /usr/local/bin/aws
  assertNotEquals "AWS CLI was not uninstalled" "0" "$?"
  
  if [[ -f "/etc/bash_completion.d/aws" ]]; then
    assertEquals "AWS CLI bash completion was not removed" "0" "1"
  fi
}

# shellcheck disable=SC1091
source shunit2
