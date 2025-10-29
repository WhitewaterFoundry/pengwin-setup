#!/bin/bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"
declare wHome
declare SetupDir

function main {

  if (confirm --title "C++" --yesno "Would you like to install Linux C/C++ support for Visual Studio or CLion development?" 12 70) ; then

    echo "Installing C++ support"

    install_packages gcc clang gdb build-essential gdbserver rsync zip pkg-config cmake

  else
    echo "Skipping C++"
  fi

}

main "$@"
