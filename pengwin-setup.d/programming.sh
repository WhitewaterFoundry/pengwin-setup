#!/bin/bash

# shellcheck disable=SC1090
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir

function main() {

  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Programming Menu" --checklist --separate-output "Install various programming languages support\n[SPACE to select, ENTER to confirm]:" 17 95 11 \
      "C++" "Install support for Linux C/C++ programming in Visual Studio and CLion  " off \
      "DOTNET" "Install .NET Core SDK from Microsoft and optionally install NuGet  " off \
      "GO" "Install the latest Go from Google" off \
      "JAVA" "Install the SDKMan to manage Java SDKs" off \
      "JETBRAINS" "Install required support to jetbrains tools" off \
      "JOOMLA" "Install development support for Joomla" off \
      "LATEX" "Install TexLive for LaTeX Support" off \
      "NIM" "Install Nim from official sources using choosenim" off \
      "NODEJS" "Install Node.js and npm" off \
      "PYTHONPI" "Install Python 3.9 and download and install latest PyPi" off \
      "RUBY" "Install Ruby using rbenv and optionally install Rails" off \
      "RUST" "Install latest version of Rust via rustup installer" off \

  # shellcheck disable=SC2188
  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"C++"* ]] ; then
    echo "C++"
    bash "${SetupDir}"/cpp-vs-clion.sh "$@"
  fi

  if [[ ${menu_choice} == *"DOTNET"* ]] ; then
    echo "DOTNET"
    bash "${SetupDir}"/dotnet.sh "$@"
  fi

  if [[ ${menu_choice} == *"GO"* ]] ; then
    echo "GO"
    bash "${SetupDir}"/go.sh "$@"
  fi

  if [[ ${menu_choice} == *"JAVA"* ]] ; then
    echo "JAVA"
    bash "${SetupDir}"/java.sh "$@"
  fi

  if [[ ${menu_choice} == *"JOOMLA"* ]] ; then
    echo "JOOMLA"
    bash "${SetupDir}"/joomla.sh "$@"
  fi

  if [[ ${menu_choice} == *"LATEX"* ]] ; then
    echo "LATEX"
    bash "${SetupDir}"/latex.sh "$@"
  fi

  if [[ ${menu_choice} == *"NIM"* ]] ; then
    echo "nim"
    bash "${SetupDir}"/nim.sh "$@"
  fi

  if [[ ${menu_choice} == *"NODEJS"* ]] ; then
    echo "NODE"
    bash "${SetupDir}"/nodejs.sh "$@"
  fi

  if [[ ${menu_choice} == *"PYTHONPI"* ]] ; then
    echo "PYTHON"
    bash "${SetupDir}"/pythonpi.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUBY"* ]] ; then
    echo "RUBY"
    bash "${SetupDir}"/ruby.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUST"* ]] ; then
    echo "RUST"
    bash "${SetupDir}"/rust.sh "$@"
  fi
  if [[ ${menu_choice} == *"JETBRAINS"* ]] ; then
    echo "JETBRAINS"
    bash "${SetupDir}"/jetbrains_support.sh "$@"
  fi

}

main "$@"
