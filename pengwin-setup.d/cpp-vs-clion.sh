#!/bin/bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"
declare wHome
declare SetupDir

function main {

  if (confirm --title "C++" --yesno "Would you like to install Linux C/C++ support for Visual Studio or CLion development?\n\nSSH server will be installed and configured" 12 70) ; then

    echo "Installing C++ support"


    if ! (service ssh status) ; then
      bash "${SetupDir}"/services.sh --enable-ssh --yes "$@"
    fi

    # shellcheck disable=SC2181
    if [[ $? != 0 ]] ; then
      return 1
    fi

    install_packages gcc clang gdb build-essential gdbserver rsync zip

    #Installs the Microsoft version of CMake for Visual Studio
    createtmp
    echo "Installing CMake"

    # shellcheck disable=SC2155
    local dist="$(uname -m)"
    if [[ ${dist} == "x86_64" ]] ; then
      wget -O cmake.sh "https://github.com/microsoft/CMake/releases/download/v3.17.3587832/cmake-3.17.3587832-MSVC_2-Linux-${dist/86_/}.sh"
      sudo bash cmake.sh  --skip-license --prefix=/usr/local
    fi

    #Installs the regular version for CLion
    install_packages pkg-config cmake
    sudo apt-get -y -q autoremove
    sudo apt-get -y -q clean

    #Fix bug with Pengwin name, Kept for compatibility reasons
    local success=0
    cd "${wHome}" || success=1
    if [[ ${success} ]] ; then
      local reg_exp='\(<microsoft-id>\)Pengwin\(</microsoft-id>\)'
      for l in .CLion*/config/options/wsl.distributions.xml; do
        if (grep -q ${reg_exp} <"${l}") ; then
          sed -i "s#${reg_exp}#\1WLinux\2#" "${l}"
        fi
      done
    fi

    #Apply the fix in newer paths
    success=0
    cd "$(wslpath -u "$(wslvar APPDATA)")" || success=1
    if [[ ${success} ]] ; then
      local reg_exp='\(<microsoft-id>\)Pengwin\(</microsoft-id>\)'
      for l in JetBrains/*/options/wsl.distributions.xml; do
        if (grep -q ${reg_exp} <"${l}") ; then
          sed -i "s#${reg_exp}#\1WLinux\2#" "${l}"
        fi
      done
    fi

    cleantmp
  else
    echo "Skipping C++"
  fi

}

main "$@"
