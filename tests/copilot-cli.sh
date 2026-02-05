#!/bin/bash

source commons.sh

#######################################
# Test GitHub Copilot CLI installation in WSL2 mode (binary installer)
# Arguments:
#  None
#######################################
function test_wsl2_install() {
  # Set WSL2=1 to test WSL2 behavior (binary installer)
  export WSL2=1

  run_pengwinsetup install AIUTILS COPILOT-CLI

  # Check if copilot binary is installed in user's local bin
  assertTrue "copilot binary was not installed" "[ -f /home/${TEST_USER}/.local/bin/copilot ]"

  # Check if copilot command is executable
  run test -x /home/${TEST_USER}/.local/bin/copilot
  assertTrue "copilot binary is not executable" "$?"

  # Check if PATH configuration file exists
  assertTrue "PATH configuration file not found" "[ -f /etc/profile.d/github-copilot.sh ]"

  # In WSL2 mode, the profile.d script should NOT contain the alias
  assertFalse "WSL2 profile.d should not contain alias" "grep -q 'alias copilot' /etc/profile.d/github-copilot.sh"
}

#######################################
# Test GitHub Copilot CLI uninstallation after WSL2 install
# Arguments:
#  None
#######################################
function test_wsl2_uninstall() {
  run_pengwinsetup install UNINSTALL COPILOT-CLI

  # Check if copilot binary is removed from user's local bin
  assertFalse "copilot binary was not uninstalled" "[ -f /home/${TEST_USER}/.local/bin/copilot ]"

  # Check if PATH configuration file is removed
  assertFalse "PATH configuration file still exists" "[ -f /etc/profile.d/github-copilot.sh ]"
}

#######################################
# Test GitHub Copilot CLI installation in WSL1 mode (npm installer)
# Arguments:
#  None
#######################################
function test_wsl1_install() {
  # Unset WSL2 to test WSL1 behavior (npm installer with alias)
  unset WSL2

  run_pengwinsetup install AIUTILS COPILOT-CLI

  # Check if PATH configuration file exists
  assertTrue "PATH configuration file not found" "[ -f /etc/profile.d/github-copilot.sh ]"

  # In WSL1 mode, the profile.d script should contain the alias with WSL2 check
  assertTrue "WSL1 profile.d should contain alias" "grep -q 'alias copilot' /etc/profile.d/github-copilot.sh"

  # Check that the alias includes the WSL2 runtime check
  assertTrue "WSL1 profile.d should check WSL2 at runtime" "grep -q 'if \[ -z \"\${WSL2}\" \]' /etc/profile.d/github-copilot.sh"
}

#######################################
# Test GitHub Copilot CLI uninstallation after WSL1 install
# Arguments:
#  None
#######################################
function test_wsl1_uninstall() {
  run_pengwinsetup install UNINSTALL COPILOT-CLI

  # Check if PATH configuration file is removed
  assertFalse "PATH configuration file still exists" "[ -f /etc/profile.d/github-copilot.sh ]"
}

# shellcheck disable=SC1091
source shunit2
