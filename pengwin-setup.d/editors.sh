#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

declare INSTALLED=false

#Imported from common.h
declare SetupDir

function neovim_install() {
  if (confirm --title "NEOVIM" --yesno "Would you like to download and install neovim?" 8 50); then
    echo "Installing neovim and building tools from Debian: $ sudo apt-get install neovim build-essential"
    install_packages neovim build-essential

    INSTALLED=true
  else
    echo "Skipping NEOVIM"
  fi
}

function emacs_install() {
  if (confirm --title "EMACS" --yesno "Would you like to download and install emacs?" 8 50); then
    echo "Installing emacs: $ sudo apt-get install emacs -y"
    install_packages emacs

    INSTALLED=true
  else
    echo "Skipping EMACS"
  fi
}

function code_install() {
  if (confirm --title "CODE" --yesno "Would you like to download and install Code from Microsoft?" 8 65); then
    echo "Installing CODE"
    createtmp
    echo "Downloading and unpacking Microsoft's apt repo key with curl and gpg"
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
    echo "Moving Microsoft's apt repo key into place with mv"
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    echo "Adding Microsoft apt repo to /etc/apt/sources.list.d/vscode.list with echo"
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    update_packages
    cleantmp

    echo "Installing code with dependencies: "
    local code_version=''

    # Limit the version with WSL1 due to an incompatibility
    if [[ -z "${WSL2}" ]]; then
      code_version='=1.42.1-1581432938'
    fi

    export NON_INTERACTIVE=1
    install_packages --allow-downgrades code${code_version} code-insiders libxss1 libasound2 libx11-xcb-dev mesa-utils libgbm1
    sudo tee "/etc/profile.d/code.sh" <<EOF
#!/bin/bash
export DONT_PROMPT_WSL_INSTALL=1
EOF

    INSTALLED=true
    touch "${HOME}"/.should-restart
  else
    echo "Skipping CODE"
  fi
}

function editor_menu() {
  # shellcheck disable=SC2155
  local editor_choice=$(

    menu --title "Editor Menu" --checklist --separate-output "Custom editors (nano and vi included)\n[SPACE to select, ENTER to confirm]:" 12 55 3 \
      "CODE" "Visual Studio Code (requires X)   " off \
      "EMACS" "Emacs" off \
      "NEOVIM" "Neovim" off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${editor_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${editor_choice} == *"NEOVIM"* ]]; then
    neovim_install
  fi

  if [[ ${editor_choice} == *"EMACS"* ]]; then
    emacs_install
  fi

  if [[ ${editor_choice} == *"CODE"* ]]; then
    code_install
  fi

  if [[ "${INSTALLED}" == true ]]; then
    bash "${SetupDir}"/shortcut.sh --yes "$@"
  fi
}

editor_menu "$@"
