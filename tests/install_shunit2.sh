#!/bin/bash

(
  # shellcheck disable=SC2164
  cd
  git clone https://github.com/kward/shunit2.git
  echo "PATH=\"\${PATH}:\${HOME}/shunit2\"" >> ${HOME}/.bashrc
)

export PATH="${PATH}:${HOME}/shunit2"

sudo apt-get -y -q install shellcheck
