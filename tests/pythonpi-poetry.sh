#!/bin/bash

source commons.sh

#######################################
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function test_py_poetry() {

  run_pengwinsetup install PROGRAMMING PYTHONPI POETRY

  local i
  for i in 'python3' 'make'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  run python3 --version
  run "${HOME}"/.local/bin/poetry --version

  assertEquals "Python was not installed" "1" "$(run python3 --version | grep -c '3.11')"
  assertEquals "Poetry was not installed" "1" "$(run "${HOME}"/.local/bin/poetry --version | grep -c '1.8')"

}

#######################################
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function test_uninstall_py_poetry() {

  run_pengwinsetup uninstall POETRY

  run test -f "${HOME}"/.local/share/pypoetry/venv/bin/poetry
  assertFalse "Poetry was not uninstalled" "$?"
}

# shellcheck disable=SC1091
source shunit2
