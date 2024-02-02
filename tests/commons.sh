#!/bin/bash

export TEST_USER=test_user

#######################################
# description
# Globals:
#   HOME
#   LANG
#   PATH
#   SHUNIT_TMPDIR
#   TERM
#   TEST_USER
# Arguments:
#  None
#######################################
function oneTimeSetUp() {
  # shellcheck disable=SC2155
  export PATH="$(pwd)/stubs:${PATH}"
  export HOME="/home/${TEST_USER}"
  export TERM="xterm-256color"
  export LANG=en_US.utf8

  sudo /usr/sbin/adduser --quiet --disabled-password --gecos '' ${TEST_USER}
  sudo /usr/sbin/usermod -aG adm,cdrom,sudo,dip,plugdev ${TEST_USER}

  if [[ -n "${USER}" ]]; then
    sudo /usr/sbin/usermod -aG "${USER}" ${TEST_USER}
    sudo /usr/sbin/usermod -aG ${TEST_USER} "${USER}"
  fi

  echo "%${TEST_USER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/passwordless-sudo
  sudo chmod +x run-pengwin-setup.sh
  sudo chmod +x stubs/*

  sudo chmod 777 -R "${SHUNIT_TMPDIR}"

  # Add the stub path

  echo "PATH=\"$(pwd)/stubs:\${PATH}\"" | sudo tee /etc/profile.d/00-a.sh
  echo 'TERM="xterm-256color"' | sudo tee -a /etc/profile.d/00-a.sh

  export SHUNIT_TMPDIR
}

#######################################
# description
# Globals:
#   TEST_USER
# Arguments:
#  None
#######################################
function oneTimeTearDown() {
  if id "${TEST_USER}" &>/dev/null; then
    sudo killall -u "${TEST_USER}"
    sudo /usr/sbin/deluser ${TEST_USER}

    if [[ $(groups | grep -c "${TEST_USER}") != 0 ]]; then
      sudo /usr/sbin/groupdel ${TEST_USER}
    fi
  fi
}

#######################################
# description
# Arguments:
#   1
# Returns:
#   0 ...
#   1 ...
#######################################
function package_installed() {

  # shellcheck disable=SC2155
  local result=$(apt -qq list "$1" 2>/dev/null | grep -c "\[install\|\[upgradable") # so it matches english "install" and also german "installiert"

  if [[ $result == 0 ]]; then
    return 1
  else
    return 0
  fi
}

#######################################
# description
# Arguments:
#  None
#######################################
function run_test() {
  echo "Start: $* *****************************************************************"
  time "$@"
  echo "End: $* *****************************************************************"
}

#######################################
# description
# Globals:
#   TEST_USER
# Arguments:
#  None
#######################################
function run_pengwinsetup() {
  sudo su - -c "$(pwd)/run-pengwin-setup.sh $*" ${TEST_USER}
}

#######################################
# description
# Globals:
#   TEST_USER
# Arguments:
#  None
#######################################
function run() {
  sudo su - -c "$*" ${TEST_USER} 2>/dev/null
}

#######################################
# description
# Arguments:
#   1
#######################################
function check_script() {
  local installed_script="$1"

  test -f "${installed_script}"
  assertEquals "${installed_script} was not installed" "0" "$?"

  shellcheck "${installed_script}"
  assertEquals "shellcheck reported errors on ${installed_script}" "0" "$?"
}
