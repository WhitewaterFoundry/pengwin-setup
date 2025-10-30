#!/bin/bash

source commons.sh

function testPyEnv() {

  run_pengwinsetup autoinstall PROGRAMMING PYTHONPI PYENV

  assertEquals "Python was not installed" "1" "$(run "${HOME}"/.pyenv/shims/python3 --version | grep -c '3.1')"
  assertEquals "Pyenv variables are not setup" "1" "$(run cat "${HOME}"/.bashrc | grep -c '^[^#]*\bPYENV_ROOT.*/.pyenv')"
  assertEquals "Pyenv variables are not setup" "1" "$(run cat "${HOME}"/.bashrc | grep -c '^[^#]*\bPATH.*PYENV_ROOT.*/bin')"
}

function testUninstallPyEnv() {

  run_pengwinsetup uninstall PYENV

  test -f "${HOME}"/.pyenv/shims/python3
  assertFalse "Python was not uninstalled" "$?"
  assertEquals "Pyenv variables were not cleaned up" "0" "$(run cat "${HOME}"/.bashrc | grep -c '^[^#]*\bPYENV_ROOT.*/.pyenv')"
  assertEquals "Pyenv variables were not cleaned up" "0" "$(run cat "${HOME}"/.bashrc | grep -c '^[^#]*\bPATH.*PYENV_ROOT.*/bin')"
}

# shellcheck disable=SC1091
source shunit2
