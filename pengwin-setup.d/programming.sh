#!/bin/bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

function main() {

  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "Programming Menu" "${DIALOG_TYPE}" "Install various programming languages support\n[ENTER to confirm]:" 22 95 12 \
      "C++" "Install support for Linux C/C++ programming in Visual Studio and CLion  " ${OFF} \
      "DOTNET" "Install .NET Core SDK from Microsoft and optionally install NuGet  " ${OFF} \
      "GO" "Install the latest Go from Google" ${OFF} \
      "JAVA" "Install the SDKMan to manage Java SDKs" ${OFF} \
      "JETBRAINS" "Install required support to jetbrains tools" ${OFF} \
      "JOOMLA" "Install development support for Joomla" ${OFF} \
      "LATEX" "Install TexLive for LaTeX Support" ${OFF} \
      "NIM" "Install Nim from official sources using choosenim" ${OFF} \
      "NODEJS" "Install Node.js and npm" ${OFF} \
      "PYTHONPI" "Install Python 3.13, download and install latest PyPi" ${OFF} \
      "RUBY" "Install Ruby using rbenv and optionally install Rails" ${OFF} \
      "RUST" "Install latest version of Rust via rustup installer" ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  local exit_status

  if [[ ${menu_choice} == *"C++"* ]]; then
    echo "C++"
    bash "${SetupDir}"/cpp-vs-clion.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"DOTNET"* ]]; then
    echo "DOTNET"
    bash "${SetupDir}"/dotnet.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"GO"* ]]; then
    echo "GO"
    bash "${SetupDir}"/go.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"JAVA"* ]]; then
    echo "JAVA"
    bash "${SetupDir}"/java.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"JOOMLA"* ]]; then
    echo "JOOMLA"
    bash "${SetupDir}"/joomla.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"LATEX"* ]]; then
    echo "LATEX"
    bash "${SetupDir}"/latex.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"NIM"* ]]; then
    echo "nim"
    bash "${SetupDir}"/nim.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"NODEJS"* ]]; then
    echo "NODE"
    bash "${SetupDir}"/nodejs.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"PYTHONPI"* ]]; then
    echo "PYTHON"
    bash "${SetupDir}"/pythonpi.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"RUBY"* ]]; then
    echo "RUBY"
    bash "${SetupDir}"/ruby.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"RUST"* ]]; then
    echo "RUST"
    bash "${SetupDir}"/rust.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"JETBRAINS"* ]]; then
    echo "JETBRAINS"
    bash "${SetupDir}"/jetbrains-support.sh "$@"
    exit_status=$?
  fi

  if [[ ${exit_status} != 0 && ! ${NON_INTERACTIVE} ]]; then
    local status
    main "$@"
    status=$?
    return $status
  fi

  return ${exit_status}
}

main "$@"
