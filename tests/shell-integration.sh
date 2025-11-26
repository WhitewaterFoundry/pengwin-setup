#!/bin/bash

source commons.sh

declare TEST_USER

readonly PENGWIN_SHELL_INTEGRATION_MARKER='### PENGWIN WINDOWS TERMINAL SHELL INTEGRATION'
readonly SHELL_INTEGRATION_SCRIPT='/usr/local/share/pengwin/wt-shell-integration.sh'

function test_main() {
  run_pengwinsetup autoinstall SETTINGS SHELLS SHELLINT

  # Check that the source line was added to .bashrc
  local bashrc="/home/${TEST_USER}/.bashrc"

  test -f "${bashrc}"
  assertEquals ".bashrc file should exist" "0" "$?"

  grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}"
  assertEquals "Shell integration marker should be present in .bashrc" "0" "$?"

  grep -q "wt-shell-integration.sh" "${bashrc}"
  assertEquals "Source line for shell integration script should be present in .bashrc" "0" "$?"

  # Check that the script was installed to /usr/local/share/pengwin
  test -f "${SHELL_INTEGRATION_SCRIPT}"
  assertEquals "Shell integration script should exist" "0" "$?"

  grep -q "__wt_update_prompt" "${SHELL_INTEGRATION_SCRIPT}"
  assertEquals "Shell integration function should be present in script" "0" "$?"

  grep -q "PS0=" "${SHELL_INTEGRATION_SCRIPT}"
  assertEquals "PS0 should be set for command executed mark" "0" "$?"

  grep -q "WT_SESSION" "${SHELL_INTEGRATION_SCRIPT}"
  assertEquals "WT_SESSION check should be present in script" "0" "$?"
}

function test_uninstall() {
  # First ensure it's installed
  run_pengwinsetup autoinstall SETTINGS SHELLS SHELLINT

  # Then uninstall
  run_pengwinsetup autoinstall UNINSTALL SHELLINT

  local bashrc="/home/${TEST_USER}/.bashrc"

  # Verify the source line was removed from .bashrc
  if [[ -f "${bashrc}" ]]; then
    grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}"
    assertNotEquals "Shell integration marker should NOT be present after uninstall" "0" "$?"
  fi

  # Verify the script was removed
  test -f "${SHELL_INTEGRATION_SCRIPT}"
  assertNotEquals "Shell integration script should NOT exist after uninstall" "0" "$?"
}

# shellcheck disable=SC1091
source shunit2
