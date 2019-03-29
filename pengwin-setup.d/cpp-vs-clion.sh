#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function main {

  if (confirm --title "C++" --yesno "Would you like to install Linux C/C++ support for Visual Studio or CLion development?\n\nSSH server will be installed and configured" 12 70) ; then

    echo "Installing C++ support"


    if ! (service ssh status) ; then
      bash ${SetupDir}/services.sh --enable-ssh --yes
    fi

    if [[ $? != 0 ]] ; then
      return 1
    fi

    sudo apt-get -y -q install gcc clang gdb build-essential gdbserver
    sudo apt-get -y -q autoremove
    sudo apt-get -y -q clean

    if ! (cmake) ; then

      createtmp
      echo "Installing CMake"

      local dist="$(uname -m)"
      wget -O cmake.sh "https://github.com/Microsoft/CMake/releases/download/untagged/cmake-3.13.18112701-MSVC_2-Linux-${dist/86_/}.sh"
      sudo bash cmake.sh  --skip-license --prefix=/usr/local

      cleantmp
    fi

  else
    echo "Skipping C++"
  fi

}

main "$@"