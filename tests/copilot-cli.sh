#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install AIUTILS COPILOT-CLI

  # Check if copilot binary is installed in user's local bin
  assertTrue "copilot binary was not installed" "[ -f /home/${TEST_USER}/.local/bin/copilot ]"

  # Check if copilot command is executable
  run test -x /home/${TEST_USER}/.local/bin/copilot
  assertTrue "copilot binary is not executable" "$?"

  # Check if PATH configuration file exists
  assertTrue "PATH configuration file not found" "[ -f /etc/profile.d/github-copilot.sh ]"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL COPILOT-CLI

  # Check if copilot binary is removed from user's local bin
  assertFalse "copilot binary was not uninstalled" "[ -f /home/${TEST_USER}/.local/bin/copilot ]"

  # Check if PATH configuration file is removed
  assertFalse "PATH configuration file still exists" "[ -f /etc/profile.d/github-copilot.sh ]"
}

# shellcheck disable=SC1091
source shunit2
