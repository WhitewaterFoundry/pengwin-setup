#!/bin/bash

(
  # shellcheck disable=SC2164
  cd
  git clone https://github.com/AJIOB/shunit2.git
  cd shunit2 && git checkout AJIOB/add-time-stamps
  echo "PATH=\"\${PATH}:\${HOME}/shunit2\"" >> "${HOME}"/.bashrc
)

export PATH="${PATH}:${HOME}/shunit2"

sudo apt-get -y -q install shellcheck

