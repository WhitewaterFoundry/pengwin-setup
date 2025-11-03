#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

function main() {

  local UninstallDir="${SetupDir}/uninstall"
  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "Uninstall Menu" "${DIALOG_TYPE}" "Uninstall applications and packages installed by pengwin-setup\n[ENTER to confirm]:" 0 0 0 \
      "ANSIBLE" "Remove Ansible Playbook deployment tools" ${OFF} \
      "AWS" "Remove AWS CLI tools" ${OFF} \
      "AZURE" "Remove Azure CLI tools" ${OFF} \
      "BASH-RL" "Remove optimized Bash readline settings" ${OFF} \
      "C++" "Remove Linux C/C++ programming support in Visual Studio and CLion    " ${OFF} \
      "CASSANDRA" "Remove Cassandra NoSQL server" ${OFF} \
      "COLORTOOL" "Remove ColorTool console color scheme setter" ${OFF} \
      "DIGITALOCEAN" "Remove Digital Ocean CLI tools" ${OFF} \
      "DOCKER" "Remove secure bridge between Pengwin and Docker Desktop" ${OFF} \
      "DOTNET" "Remove Microsoft's .NET Core SDK and NuGet (if installed)" ${OFF} \
      "FCITX" "Remove all fcitx improved non-Latin input support" ${OFF} \
      "FISH" "Remove FISH Shell" ${OFF} \
      "GO" "Remove Go language" ${OFF} \
      "GUILIB" "Remove base GUI application libraries" ${OFF} \
      "HIDPI" "Remove Qt and GTK HiDPI modifications" ${OFF} \
      "HOMEBREW" "Remove the Homebrew package manager" ${OFF} \
      "IBM" "Remove IBM Cloud CLI tools" ${OFF} \
      "IBUS" "Remove all ibus improved non-Latin input support" ${OFF} \
      "JAVA" "Remove SDKMan its installed Java SDKs" ${OFF} \
      "JETBRAINS" "Remove JetBrains Toolbox" ${OFF} \
      "KEYCHAIN" "Remove Keychain OpenSSH key manager" ${OFF} \
      "KUBERNETES" "Remove Kubernetes tooling" ${OFF} \
      "LAMP" "Remove LAMP stack" ${OFF} \
      "LATEX" "Remove TexLive LaTeX packages" ${OFF} \
      "MSEDIT" "Remove Microsoft Edit TUI editor" ${OFF} \
      "NIM" "Remove choosenim and any installed Nim components" ${OFF} \
      "NODEJS" "Remove Node.js, npm and Yarn (if installed)" ${OFF} \
      "OPENSTACK" "Remove OpenStack CLI tools" ${OFF} \
      "POETRY" "Remove Poetry" ${OFF} \
      "POWERSHELL" "Remove Powershell for Linux" ${OFF} \
      "PYENV" "Remove pyenv, its Python version(s) and modules" ${OFF} \
      "RCLOCAL" "Remove rclocal support (the file /etc/rc.local) is kept" ${OFF} \
      "RUBY" "Remove rbenv, Ruby version(s) and Rails (if installed)" ${OFF} \
      "RUST" "Remove Rust and rustup toolchain installer" ${OFF} \
      "STARTMENU" "Remove all Pengwin generated Windows Start Menu shortcuts" ${OFF} \
      "SSH" "Remove SSH server" ${OFF} \
      "SYSTEMD" "Disable SystemD support" ${OFF} \
      "TERRAFORM" "Remove Terraform CLI tools" ${OFF} \
      "VCXSRV" "Remove VcXsrv X-server" ${OFF} \
      "VSCODE" "Remove Visual Studio Code for Linux" ${OFF} \
      "WINTHEME" "Remove Windows 10 theme and LXAppearance" ${OFF} \
      "WSLTTY" "Remove WSLtty" ${OFF} \
      "X410" "Remove the X410 X-server autostart" ${OFF} \
      "XFCE" "Remove XFCE Desktop environment" ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"ANSIBLE"* ]]; then
    echo "ANSIBLE"
    bash "${UninstallDir}"/ansible.sh "$@"
  fi

  if [[ ${menu_choice} == *"AWS"* ]]; then
    echo "AWS"
    bash "${UninstallDir}"/awscli.sh "$@"
  fi

  if [[ ${menu_choice} == *"AZURE"* ]]; then
    echo "AZURE"
    bash "${UninstallDir}"/azurecli.sh "$@"
  fi

  if [[ ${menu_choice} == *"BASH-RL"* ]]; then
    echo "BASH-RL"
    bash "${UninstallDir}"/shell-opts.sh "$@"
  fi

  if [[ ${menu_choice} == *"C++"* ]]; then
    echo "C++"
    bash "${UninstallDir}"/cpp-vs-clion.sh "$@"
  fi

  if [[ ${menu_choice} == *"CASSANDRA"* ]]; then
    echo "CASSANDRA"
    bash "${UninstallDir}"/cassandra.sh "$@"
  fi

  if [[ ${menu_choice} == *"COLORTOOL"* ]]; then
    echo "COLORTOOL"
    bash "${UninstallDir}"/colortool.sh "$@"
  fi

  if [[ ${menu_choice} == *"DIGITALOCEAN"* ]]; then
    echo "DIGITALOCEAN"
    bash "${UninstallDir}"/doctl.sh "$@"
  fi

  if [[ ${menu_choice} == *"DOCKER"* ]]; then
    echo "DOCKER"
    bash "${UninstallDir}"/docker.sh "$@"
  fi

  if [[ ${menu_choice} == *"DOTNET"* ]]; then
    echo "DOTNET"
    bash "${UninstallDir}"/dotnet.sh "$@"
  fi

  if [[ ${menu_choice} == *"FCITX"* ]]; then
    echo "FCITX"
    bash "${UninstallDir}"/fcitx.sh "$@"
  fi

  if [[ ${menu_choice} == *"FISH"* ]]; then
    echo "FISH"
    bash "${UninstallDir}"/fish.sh "$@"
  fi

  if [[ ${menu_choice} == *"GO"* ]]; then
    echo "GO"
    bash "${UninstallDir}"/go.sh "$@"
  fi

  if [[ ${menu_choice} == *"GTERM"* ]]; then
    echo "GO"
    bash "${UninstallDir}"/gterm.sh "$@"
  fi

  if [[ ${menu_choice} == *"GUILIB"* ]]; then
    echo "GUILIB"
    bash "${UninstallDir}"/guilib.sh "$@"
  fi

  if [[ ${menu_choice} == *"HIDPI"* ]]; then
    echo "HIDPI"
    bash "${UninstallDir}"/hidpi.sh "$@"
  fi

  if [[ ${menu_choice} == *"HOMEBREW"* ]]; then
    echo "HOMEBREW"
    bash "${UninstallDir}"/brew.sh "$@"
  fi

  if [[ ${menu_choice} == *"IBM"* ]]; then
    echo "IBM"
    bash "${UninstallDir}"/ibmcli.sh "$@"
  fi

  if [[ ${menu_choice} == *"IBUS"* ]]; then
    echo "ibus"
    bash "${UninstallDir}"/ibus.sh "$@"
  fi

  if [[ ${menu_choice} == *"JAVA"* ]]; then
    echo "JAVA"
    bash "${UninstallDir}"/java.sh "$@"
  fi

  if [[ ${menu_choice} == *"JETBRAINS"* ]]; then
    echo "JETBRAINS"
    bash "${UninstallDir}"/jetbrains-support.sh "$@"
  fi

  if [[ ${menu_choice} == *"KEYCHAIN"* ]]; then
    echo "KEYCHAIN"
    bash "${UninstallDir}"/keychain.sh "$@"
  fi

  if [[ ${menu_choice} == *"KUBERNETES"* ]]; then
    echo "KUBERNETES"
    bash "${UninstallDir}"/kubernetes.sh "$@"
  fi

  if [[ ${menu_choice} == *"LAMP"* ]]; then
    echo "LAMP"
    bash "${UninstallDir}"/lamp.sh "$@"
  fi

  if [[ ${menu_choice} == *"LATEX"* ]]; then
    echo "LATEX"
    bash "${UninstallDir}"/latex.sh "$@"
  fi

  if [[ ${menu_choice} == *"NIM"* ]]; then
    echo "NIM"
    bash "${UninstallDir}"/nim.sh "$@"
  fi

  if [[ ${menu_choice} == *"MSEDIT"* ]]; then
    echo "MSEDIT"
    bash "${UninstallDir}"/microsoft-edit.sh "$@"
  fi

  if [[ ${menu_choice} == *"NODEJS"* ]]; then
    echo "NODEJS"
    bash "${UninstallDir}"/nodejs.sh "$@"
  fi

  if [[ ${menu_choice} == *"OPENSTACK"* ]]; then
    echo "OPENSTACK"
    bash "${UninstallDir}"/openstack.sh "$@"
  fi

  if [[ ${menu_choice} == *"POWERSHELL"* ]]; then
    echo "POWERSHELL"
    bash "${UninstallDir}"/powershell.sh "$@"
  fi

  if [[ ${menu_choice} == *"PYENV"* ]]; then
    echo "PYENV"
    bash "${UninstallDir}"/pyenv.sh "$@"
  fi

  if [[ ${menu_choice} == *"POETRY"* ]]; then
    echo "POETRY"
    bash "${UninstallDir}"/poetry.sh "$@"
  fi

  if [[ ${menu_choice} == *"RCLOCAL"* ]]; then
    echo "RCLOCAL"
    bash "${UninstallDir}"/rclocal.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUBY"* ]]; then
    echo "RUBY"
    bash "${UninstallDir}"/rbenv.sh "$@"
  fi

  if [[ ${menu_choice} == *"RUST"* ]]; then
    echo "RUST"
    bash "${UninstallDir}"/rust.sh "$@"
  fi

  if [[ ${menu_choice} == *"STARTMENU"* ]]; then
    echo "STARTMENU"
    bash "${UninstallDir}"/shortcut.sh "$@"
  fi

  if [[ ${menu_choice} == *"SSH"* ]]; then
    echo "SSH"
    bash "${UninstallDir}"/ssh.sh "$@"
  fi

  if [[ ${menu_choice} == *"SYSTEMD"* ]]; then
    echo "SYSTEMD"
    bash "${UninstallDir}"/systemd.sh "$@"
  fi

  if [[ ${menu_choice} == *"TERRAFORM"* ]]; then
    echo "TERRAFORM"
    bash "${UninstallDir}"/terraform.sh "$@"
  fi

  if [[ ${menu_choice} == *"VCXSRV"* ]]; then
    echo "VCXSRV"
    bash "${UninstallDir}"/vcxsrv.sh "$@"
  fi

  if [[ ${menu_choice} == *"VSCODE"* ]]; then
    echo "VSCODE"
    bash "${UninstallDir}"/vscode.sh "$@"
  fi

  if [[ ${menu_choice} == *"WINTHEME"* ]]; then
    echo "WINTHEME"
    bash "${UninstallDir}"/theme.sh "$@"
  fi

  if [[ ${menu_choice} == *"WSLTTY"* ]]; then
    echo "WSLTTY"
    bash "${UninstallDir}"/wsltty.sh "$@"
  fi

  if [[ ${menu_choice} == *"X410"* ]]; then
    echo "X410"
    bash "${UninstallDir}"/x410.sh "$@"
  fi

  if [[ ${menu_choice} == *"XFCE"* ]]; then
    echo "XFCE"
    bash "${UninstallDir}"/desktop.sh "$@"
  fi

}

main "$@"
