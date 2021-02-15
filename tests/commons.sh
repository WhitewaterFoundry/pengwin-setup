#!/bin/bash

export TEST_USER=test_user

function oneTimeSetUp() {
  # shellcheck disable=SC2155
  export PATH="$(pwd)/stubs:${PATH}"
  export HOME="/home/${TEST_USER}"
  export TERM="xterm-256color"

  sudo /usr/sbin/adduser --quiet --disabled-password --gecos '' ${TEST_USER}
  sudo /usr/sbin/usermod -aG adm,cdrom,sudo,dip,plugdev ${TEST_USER}
  echo "%${TEST_USER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/passwordless-sudo
  sudo chmod +x run-pengwin-setup.sh
  sudo chmod +x stubs/*

  sudo chmod 777 -R "${SHUNIT_TMPDIR}"

  # Add the stub path
  echo "PATH=\"$(pwd)/stubs:\${PATH}\"" | sudo tee /etc/profile.d/00-a.sh
  echo 'TERM="xterm-256color"' | sudo tee -a /etc/profile.d/00-a.sh

  export SHUNIT_TMPDIR
}

function oneTimeTearDown() {
  if id "test_user" &>/dev/null; then
    sudo /usr/sbin/deluser ${TEST_USER} &>/dev/null
  fi

}

function package_installed() {

  # shellcheck disable=SC2155
  local result=$(apt -qq list $1 2>/dev/null | grep -c "\[install") # so it matches english "install" and also german "installiert"

  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

function run_test() {
  echo "Start: $@ *****************************************************************"
  time "$@"
  echo "End: $@ *****************************************************************"
}

function run_pengwinsetup() {
  sudo su - -c "$(pwd)/run-pengwin-setup.sh $*" ${TEST_USER}
}

function run_command_as_testuser() {
  sudo su - -c "$*" ${TEST_USER}
}

function check_script() {
  local installed_script="$1"

  test -f "${installed_script}"
  assertEquals "${installed_script} was not installed" "0" "$?"

  shellcheck "${installed_script}"
  assertEquals "shellcheck reported errors on ${installed_script}" "0" "$?"
}
