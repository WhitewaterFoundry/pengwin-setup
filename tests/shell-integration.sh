#!/bin/bash

source commons.sh

declare TEST_USER

readonly PENGWIN_SHELL_INTEGRATION_MARKER='### PENGWIN WINDOWS TERMINAL SHELL INTEGRATION'

function test_main() {
  run_pengwinsetup autoinstall SETTINGS SHELLS SHELLINT

  # Check that the shell integration was added to .bashrc
  local bashrc="/home/${TEST_USER}/.bashrc"

  test -f "${bashrc}"
  assertEquals ".bashrc file should exist" "0" "$?"

  grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}"
  assertEquals "Shell integration marker should be present in .bashrc" "0" "$?"

  grep -q "__wt_update_prompt" "${bashrc}"
  assertEquals "Shell integration function should be present in .bashrc" "0" "$?"

  grep -q "PS0=" "${bashrc}"
  assertEquals "PS0 should be set for command executed mark" "0" "$?"

  grep -q "WT_SESSION" "${bashrc}"
  assertEquals "WT_SESSION check should be present in .bashrc" "0" "$?"
}

function test_uninstall() {
  # First ensure it's installed
  run_pengwinsetup autoinstall SETTINGS SHELLS SHELLINT

  # Then uninstall
  run_pengwinsetup autoinstall UNINSTALL SHELLINT

  local bashrc="/home/${TEST_USER}/.bashrc"

  # Verify the shell integration was removed
  if [[ -f "${bashrc}" ]]; then
    grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}"
    assertNotEquals "Shell integration marker should NOT be present after uninstall" "0" "$?"

    grep -q "__wt_update_prompt" "${bashrc}"
    assertNotEquals "Shell integration function should NOT be present after uninstall" "0" "$?"
  fi
}

# shellcheck disable=SC1091
source shunit2
