#!/bin/bash

source $(dirname "$0")/common.sh "$@"

#Imported from common.h
declare SetupDir

function main() {

  local menu_choice=$(

    menu --title "GUI Menu" --checklist --separate-output "Uninstall applications and packages installed by pengwin-setup\n[SPACE to select, ENTER to confirm]:" 16 99 8 \
      "ANSIBLE" "Remove Ansible Playbook deployment tools" off \
      "AWS" "Remove AWS CLI tools" off \
      "AZURE" "Remove Azure CLI tools" off \
      "BASH-RL" "Remove optimized Bash readline settings" off \
      "C++" "Remove Linux C/C++ programming support in Visual Studio and CLion" off \
      "CASSANDRA" "Remove Cassandra NoSQL server" off \
      "COLORTOOL" "Remove ColorTool console color scheme setter" off \
      "DO" "Remove Digital Ocean CLI tools" off \
      "DOCKER" "Remove secure bridge between Pengwin and Docker Desktop" off \
      "DOTNET" "Remove Microsoft's .NET Core SDK and NuGet (if installed)" off \
      "FCITX" "Remove all fcitx improved non-Latin input support" off \
      "GO" "Remove Go language" off \
      "GUILIB" "Remove base GUI application libraries" off \
      "HIDPI" "Remove Qt and GTK HiDPI modifications" off \
      "HOMEBREW" "Remove the Homebrew package manager" off \
      "IBM" "Remove IBM Cloud CLI tools" off \
      "JAVA" "Remove SDKMan its installed Java SDKs" off \
      "KEYCHAIN" "Remove Keychain OpenSSH key manager" off \
      "KUBERNETES" "Remove Kubernetes tooling" off \
      "LAMP" "Remove LAMP stack" off \
      "NODEJS" "Remove Node.js, npm and Yarn (if installed)" off \
      "OPENSTACK" "Remove OpenStack CLI tools" off \
      "POWERSHELL" "Remove Powershell for Linux" off \
      "PYENV" "Remove pyenv, its Python version(s) and modules" off \
      "RUBY" "Remove rbenv, Ruby version(s) and Rails (if installed)" off \
      "RUST" "Remove Rust and rustup toolchain installer" off \
      "STARTMENU" "Remove all Pengwin generated Windows Start Menu shortcuts" off \
      "SSH" "Remove SSH server" off \
      "TERRAFORM" "Remove Terraform CLI tools" off \
      "VCXSRV" "Remove VcXsrv X-server" off \
      "VSCODE" "Remove Visual Studio Code for Linux" off \
      "WINTHEME" "Remove Windows 10 theme and LXAppearance" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi

  if [[ ${menu_choice} == *""* ]] ; then
    echo ""
    bash ${SetupDir}/____.sh "$@"
  fi
}

main "$@"
