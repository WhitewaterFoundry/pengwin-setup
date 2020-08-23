#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function main() {

  local UninstallDir="${SetupDir}/uninstall"
  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Uninstall Menu" --checklist --separate-output "Uninstall applications and packages installed by pengwin-setup\n[SPACE to select, ENTER to confirm]:" 20 95 12 \
      "ANSIBLE" "Remove Ansible Playbook deployment tools" off \
      "AWS" "Remove AWS CLI tools" off \
      "AZURE" "Remove Azure CLI tools" off \
      "BASH-RL" "Remove optimized Bash readline settings" off \
      "C++" "Remove Linux C/C++ programming support in Visual Studio and CLion    " off \
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
      "IBUS" "Remove all ibus improved non-Latin input support" off \
      "JAVA" "Remove SDKMan its installed Java SDKs" off \
      "KEYCHAIN" "Remove Keychain OpenSSH key manager" off \
      "KUBERNETES" "Remove Kubernetes tooling" off \
      "LAMP" "Remove LAMP stack" off \
      "NIM" "Remove choosenim and any installed Nim components" off \
      "NODEJS" "Remove Node.js, npm and Yarn (if installed)" off \
      "OPENSTACK" "Remove OpenStack CLI tools" off \
      "POWERSHELL" "Remove Powershell for Linux" off \
      "PYENV" "Remove pyenv, its Python version(s) and modules" off \
      "RCLOCAL" "Remove rclocal support (the file /etc/rc.local) is kept" off \
      "RUBY" "Remove rbenv, Ruby version(s) and Rails (if installed)" off \
      "RUST" "Remove Rust and rustup toolchain installer" off \
      "STARTMENU" "Remove all Pengwin generated Windows Start Menu shortcuts" off \
      "SSH" "Remove SSH server" off \
      "TERRAFORM" "Remove Terraform CLI tools" off \
      "VCXSRV" "Remove VcXsrv X-server" off \
      "VSCODE" "Remove Visual Studio Code for Linux" off \
      "WINTHEME" "Remove Windows 10 theme and LXAppearance" off \
      "WSLTTY" "Remove WSLtty" off \
      "X410" "Remove the X410 X-server autostart" off \

  # shellcheck disable=SC2188
  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"ANSIBLE"* ]] ; then
    echo "ANSIBLE"
    bash "${UninstallDir}"/ansible.sh "$@"
  fi

  if [[ ${menu_choice} == *"AWS"* ]] ; then
    echo "AWS"
    bash "${UninstallDir}"/awscli.sh "$@"
  fi

  if [[ ${menu_choice} == *"AZURE"* ]] ; then
    echo "AZURE"
    bash "${UninstallDir}"/azurecli.sh "$@"
  fi

  if [[ ${menu_choice} == *"BASH-RL"* ]] ; then
    echo "BASH-RL"
    bash "${UninstallDir}"/shell-opts.sh "$@"
  fi

  if [[ ${menu_choice} == *"C++"* ]] ; then
    echo "C++"
    bash "${UninstallDir}"/cpp-vs-clion.sh "$@"
  fi

  if [[ ${menu_choice} == *"CASSANDRA"* ]] ; then
    echo "CASSANDRA"
    bash "${UninstallDir}"/cassandra.sh "$@"
  fi

  if [[ ${menu_choice} == *"COLORTOOL"* ]] ; then
    echo "COLORTOOL"
    bash "${UninstallDir}"/colortool.sh "$@"
  fi

  if [[ ${menu_choice} == *"DO"* ]] ; then
    echo "DO"
    bash "${UninstallDir}"/doctl.sh "$@"
  fi

  if [[ ${menu_choice} == *"DOCKER"* ]] ; then
    echo "DOCKER"
    bash "${UninstallDir}"/docker.sh "$@"
  fi

  if [[ ${menu_choice} == *"DOTNET"* ]] ; then
    echo "DOTNET"
    bash "${UninstallDir}"/dotnet.sh "$@"
  fi

  if [[ ${menu_choice} == *"FCITX"* ]] ; then
    echo "FCITX"
    bash "${UninstallDir}"/fcitx.sh "$@"
  fi

  if [[ ${menu_choice} == *"GO"* ]] ; then
    echo "GO"
    bash "${UninstallDir}"/go.sh "$@"
  fi

  if [[ ${menu_choice} == *"GTERM"* ]] ; then
    echo "GO"
    bash "${UninstallDir}"/gterm.sh "$@"
  fi

  if [[ ${menu_choice} == *"GUILIB"* ]] ; then
    echo "GUILIB"
    bash "${UninstallDir}"/guilib.sh "$@"
  fi

  if [[ ${menu_choice} == *"HIDPI"* ]] ; then
    echo "HIDPI"
    bash "${UninstallDir}"/hidpi.sh "$@"
  fi

  if [[ ${menu_choice} == *"HOMEBREW"* ]] ; then
    echo "HOMEBREW"
    bash "${UninstallDir}"/brew.sh "$@"
  fi

  if [[ ${menu_choice} == *"IBM"* ]] ; then
    echo "IBM"
    bash "${UninstallDir}"/ibmcli.sh "$@"
  fi

  if [[ ${menu_choice} == *"IBUS"* ]] ; then
    echo "ibus"
    bash "${UninstallDir}"/ibus.sh "$@"
  fi

  if [[ ${menu_choice} == *"JAVA"* ]] ; then
    echo "JAVA"
    bash "${UninstallDir}"/java.sh "$@"
  fi

  if [[ ${menu_choice} == *"KEYCHAIN"* ]] ; then
    echo "KEYCHAIN"
    bash "${UninstallDir}"/keychain.sh "$@"
  fi

  if [[ ${menu_choice} == *"KUBERNETES"* ]] ; then
    echo "KUBERNETES"
    bash "${UninstallDir}"/kubernetes.sh "$@"
  fi

  if [[ ${menu_choice} == *"LAMP"* ]] ; then
    echo "LAMP"
    bash "${UninstallDir}"/lamp.sh "$@"
  fi

  if [[ ${menu_choice} == *"NIM"* ]] ; then
    echo "NIM"
    bash "${UninstallDir}"/nim.sh "$@"
  fi

  if [[ ${menu_choice} == *"NODEJS"* ]] ; then
    echo "NODEJS"
    bash "${UninstallDir}"/nodejs.sh "$@"
  fi

  if [[ ${menu_choice} == *"OPENSTACK"* ]] ; then
    echo "OPENSTACK"
    bash "${UninstallDir}"/openstack.sh "$@"
  fi

  if [[ ${menu_choice} == *"POWERSHELL"* ]] ; then
    echo "POWERSHELL"
    bash "${UninstallDir}"/powershell.sh "$@"
  fi

  if [[ ${menu_choice} == *"PYENV"* ]] ; then
    echo "PYENV"
    bash "${UninstallDir}"/pyenv.sh "$@"
  fi

  if [[ ${menu_choice} == *"RCLOCAL"* ]] ; then
    echo "RCLOCAL"
    bash "${UninstallDir}"/rclocal.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUBY"* ]] ; then
    echo "RUBY"
    bash "${UninstallDir}"/rbenv.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUST"* ]] ; then
    echo "RUST"
    bash "${UninstallDir}"/rust.sh "$@"
  fi

  if [[ ${menu_choice} == *"STARTMENU"* ]] ; then
    echo "STARTMENU"
    bash "${UninstallDir}"/shortcut.sh "$@"
  fi

  if [[ ${menu_choice} == *"SSH"* ]] ; then
    echo "SSH"
    bash "${UninstallDir}"/ssh.sh "$@"
  fi

  if [[ ${menu_choice} == *"TERRAFORM"* ]] ; then
    echo "TERRAFORM"
    bash "${UninstallDir}"/terraform.sh "$@"
  fi

  if [[ ${menu_choice} == *"VCXSRV"* ]] ; then
    echo "VCXSRV"
    bash "${UninstallDir}"/vcxsrv.sh "$@"
  fi

  if [[ ${menu_choice} == *"VSCODE"* ]] ; then
    echo "VSCODE"
    bash "${UninstallDir}"/vscode.sh "$@"
  fi

  if [[ ${menu_choice} == *"WINTHEME"* ]] ; then
    echo "WINTHEME"
    bash "${UninstallDir}"/theme.sh "$@"
  fi

  if [[ ${menu_choice} == *"WSLTTY"* ]] ; then
    echo "WSLTTY"
    bash "${UninstallDir}"/wsltty.sh "$@"
  fi

  if [[ ${menu_choice} == *"X410"* ]] ; then
    echo "X410"
    bash "${UninstallDir}"/x410.sh "$@"
  fi

}

main "$@"
