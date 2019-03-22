#!/bin/bash

source $(dirname "$0")/common.sh "$@"

function main() {

  local menu_choice=$(

    menu --title "Programming Menu" --checklist --separate-output "Install various programming languages support\n[SPACE to select, ENTER to confirm]:" 25 70 7 \
      "DOTNET" "Install .NET Core SDK from Microsoft and optionally install NuGet" off \
      "GO" "Install the latest Go from Google" off \
      "JAVA" "Install the Java OpenJDK and JRE" off \
      "NODEJS" "Install Node.js and npm" off \
      "PYTHONPI" "Install Python 3.7 and download and install latest PyPi" off \
      "RUBY" "Install Ruby using rbenv and optionally install Rails" off \
      "RUST" "Install latest version of Rust via rustup installer" off \

  3>&1 1>&2 2>&3)

  if [[ ${editor_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"DOTNET"* ]] ; then
    echo "DOTNET"
    bash ${SetupDir}/dotnet.sh "$@"
  fi

  if [[ ${menu_choice} == *"GO"* ]] ; then
    echo "GO"
    bash ${SetupDir}/go.sh "$@"
  fi

  if [[ ${menu_choice} == *"JAVA"* ]] ; then
    echo "JAVA"
    bash ${SetupDir}/java.sh "$@"
  fi

  if [[ ${menu_choice} == *"NODEJS"* ]] ; then
    echo "NODE"
    bash ${SetupDir}/nodejs.sh "$@"
  fi


  if [[ ${menu_choice} == *"PYTHONPI"* ]] ; then
    echo "PYTHON"
    bash ${SetupDir}/pythonpi.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUBY"* ]] ; then
    echo "RUBY"
    bash ${SetupDir}/ruby.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUST"* ]] ; then
    echo "RUST"
    bash ${SetupDir}/rust.sh "$@"
  fi


}

main "$@"