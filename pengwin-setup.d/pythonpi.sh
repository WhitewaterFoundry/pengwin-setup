#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"
PYTHON_TARGET="3.14"
PYTHON_DEBIAN="3.13"

#######################################
# Install Python 3.14 with pyenv
# Globals:
#   HOME
#   PATH
#   PYENV_ROOT
# Arguments:
#  None
#######################################
function install_pyenv() {

  if (confirm --title "PYTHON" --yesno "Would you like to download and install Python ${PYTHON_TARGET} with pyenv?" 8 70); then
    echo "Installing PYENV"
    createtmp
    install_packages make build-essential libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev curl git \
      xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    wget https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer
    bash pyenv-installer

    echo "inserting default scripts"

    if [[ -f "${HOME}"/.bashrc && $(grep -c '^[^#]*\bPATH.*/.pyenv/bin' "${HOME}"/.bashrc) == 0 ]]; then
      echo "" >>"${HOME}"/.bashrc
      echo "export PYENV_ROOT=\"\${HOME}/.pyenv\"" >>"${HOME}"/.bashrc
      echo "export PATH=\"\${PYENV_ROOT}/bin:\${PATH}\"" >>"${HOME}"/.bashrc
      echo "eval \"\$(pyenv init --path)\"" >>"${HOME}"/.bashrc
      echo "eval \"\$(pyenv init -)\"" >>"${HOME}"/.bashrc
    fi

    if [[ -f "${HOME}"/.zshrc && $(grep -c '^[^#]*\bPATH.*/.pyenv/bin' "${HOME}"/.zshrc) == 0 ]]; then
      echo "" >>"${HOME}"/.zshrc
      echo "export PYENV_ROOT=\"\${HOME}/.pyenv\"" >>"${HOME}"/.zshrc
      echo "export PATH=\"\${PYENV_ROOT}/bin:\${PATH}\"" >>"${HOME}"/.zshrc
      echo "eval \"\$(pyenv init --path)\"" >>"${HOME}"/.zshrc
      echo "eval \"\$(pyenv init -)\"" >>"${HOME}"/.zshrc
    fi

    # shellcheck disable=SC2002
    if [[ -d "${HOME}"/.config/fish && $(cat "${HOME}"/.config/fish/config.fish 2>/dev/null | grep -c '^[^#]*\bPATH.*/.pyenv/bin') == 0 ]]; then
      echo "" >>"${HOME}"/.config/fish/config.fish
      echo "set -x PYENV_ROOT \"${HOME}/.pyenv\"" >>"${HOME}"/.config/fish/config.fish
      echo "set -x PATH \"${PYENV_ROOT}/bin\" \$PATH" >>"${HOME}"/.config/fish/config.fish
      echo 'status --is-interactive; and pyenv init --path| source' >>"${HOME}"/.config/fish/config.fish
      echo 'status --is-interactive; and pyenv init -| source' >>"${HOME}"/.config/fish/config.fish
    fi

    echo "Installing Python ${PYTHON_TARGET}"
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    pyenv install -s "$PYTHON_TARGET"
    pyenv global "$PYTHON_TARGET"

    touch "${HOME}"/.should-restart

    cleantmp
  else
    echo "Skipping PYENV"
  fi
}

#######################################
# Install Python 3.13, and the pip package manager from the Debian repos
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function install_pythonpip() {

  if (confirm --title "PYTHON" --yesno "Would you like to download and install Python ${PYTHON_DEBIAN}, IDLE, and the pip package manager?" 8 90); then
    echo "Installing PYTHONPIP"
    createtmp
    install_packages build-essential python3 python3-pip python3-venv

    touch "${HOME}"/.should-restart

    cleantmp
  else
    echo "Skipping PYTHONPIP"
  fi
}

#######################################
# Install Python 3.13, and the poetry package manager
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function install_poetry() {

  if (confirm --title "PYTHON" --yesno "Would you like to download and install Python ${PYTHON_DEBIAN}, IDLE, and the poetry package manager?" 9 90); then
    echo "Installing POETRY"
    createtmp
    install_packages build-essential python3 python3-venv
    curl -sSL https://install.python-poetry.org | python3 -

    source "${HOME}"/.poetry/env
    poetry self update

    poetry completions bash | sudo tee /usr/share/bash-completion/completions/poetry
    mkdir -p ~/.config/fish/completions && poetry completions fish > ~/.config/fish/completions/poetry.fish

    touch "${HOME}"/.should-restart

    cleantmp
  else
    echo "Skipping POETRY"
  fi
}

#######################################
# Main menu
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function main() {
  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Python" --radiolist "Python install options\n[SPACE to select, ENTER to confirm]:" 12 75 3 \
      "PYENV" "Python ${PYTHON_TARGET} with pyenv   " off \
      "PYTHONPIP" "Python ${PYTHON_DEBIAN}, and the pip package manager " off \
      "POETRY" "Python ${PYTHON_DEBIAN}, and the poetry package manager " off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  echo "Selected:" "${menu_choice}"

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"PYENV"* ]]; then
    install_pyenv
  fi

  if [[ ${menu_choice} == *"PYTHONPIP"* ]]; then
    install_pythonpip
  fi

  if [[ ${menu_choice} == *"POETRY"* ]]; then
    install_poetry
  fi
}

main
