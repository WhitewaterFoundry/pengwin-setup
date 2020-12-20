#!/bin/bash

source commons.sh

function testPyEnv() {
  run_pengwinsetup autoinstall PROGRAMMING PYTHONPI PYENV

  for i in 'python3' 'make'; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  assertEquals "Python was not installed" "1" "$(run_command_as_testuser "${HOME}"/.pyenv/shims/python3 --version | grep -c '3.9.1')"
  assertEquals "Pyenv variables are not setup" "1" "$(grep -c '^[^#]*\bPATH.*/.pyenv/bin' "${HOME}"/.bashrc)"

}

function testUninstallPyEnv() {

  run_pengwinsetup uninstall PYENV

  test -f "${HOME}"/.pyenv/shims/python3
  assertFalse "Python was not uninstalled" "$?"
  assertEquals "Pyenv variables were not cleaned up" "0" "$(grep -c '^[^#]*\bPATH.*/.pyenv/bin' "${HOME}"/.bashrc)"
}

source shunit2
