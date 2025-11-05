#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install AI COPILOT-CLI

  # Check if github-copilot-cli is installed
  command -v github-copilot-cli
  assertTrue "GitHub Copilot CLI was not installed" "$?"

  # Check if shell integration file exists
  assertTrue "Shell integration file not found" "[ -f /etc/profile.d/github-copilot-cli.sh ]"

  # Verify npm package is installed
  npm list -g @githubnext/github-copilot-cli
  assertTrue "GitHub Copilot CLI npm package not found" "$?"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL COPILOT-CLI

  # Check if github-copilot-cli is removed
  command -v github-copilot-cli
  assertFalse "GitHub Copilot CLI was not uninstalled" "$?"

  # Check if shell integration file is removed
  assertFalse "Shell integration file still exists" "[ -f /etc/profile.d/github-copilot-cli.sh ]"
}

# shellcheck disable=SC1091
source shunit2
