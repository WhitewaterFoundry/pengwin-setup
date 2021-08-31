#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

function install_pyenv() {

  if (confirm --title "PYTHON" --yesno "Would you like to download and install Python 3.9 with pyenv?" 8 70); then
    echo "Installing PYENV"
    createtmp
    install_packages make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
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

    echo "Installing Python 3.9"
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    pyenv install -s 3.9.7
    pyenv global 3.9.7

    touch "${HOME}"/.should-restart

    cleantmp
  else
    echo "Skipping PYENV"
  fi
}

function install_pythonpip() {

  if (confirm --title "PYTHON" --yesno "Would you like to download and install Python 3.9, IDLE, and the pip package manager?" 8 90); then
    echo "Installing PYTHONPIP"
    createtmp
    install_packages build-essential python3.9 python3.9-distutils idle-python3.9 python3-pip python3-venv
    pip3 install -U pip

    touch "${HOME}"/.should-restart

    cleantmp
  else
    echo "Skipping PYTHONPIP"
  fi
}

function install_poetry() {

  if (confirm --title "PYTHON" --yesno "Would you like to download and install Python 3.9, IDLE, and the poetry package manager?" 9 90); then
    echo "Installing POETRY"
    createtmp
    install_packages build-essential python3.9 python3.9-distutils idle-python3.9 python3-venv
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3
    source $HOME/.poetry/env
    poetry self update
    poetry completions bash | sudo tee /usr/share/bash-completion/completions/poetry.bash-completion

    touch "${HOME}"/.should-restart

    cleantmp
  else
    echo "Skipping POETRY"
  fi
}

function main() {
  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "Python" --radiolist --separate-output "Python install options\n[SPACE to select, ENTER to confirm]:" 12 75 3 \
      "PYENV" 'Python 3.9 with pyenv   ' off \
      "PYTHONPIP" 'Python 3.9, IDLE, and the pip package manager ' off \
      "POETRY" 'Python 3.9, IDLE, and the poetry package manager ' off

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
