#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SKIP_CONFIMATIONS


#######################################
# Install the packaged version of NodeJS from nodesource repos
# Arguments:
#   Major node version to install
#######################################
# shellcheck disable=SC2155
function install_nodejs_nodesource() {
  echo "Installing latest node.js version from NodeSource repository"

  local major_vers=${1}

  curl -fsSL "https://deb.nodesource.com/setup_${major_vers}.x" | sudo -E bash - &&\
  local version=$(apt-cache madison nodejs | grep 'nodesource' | head -1 | grep -E "^\snodejs\s|\s$major_vers" | cut -d'|' -f2 | sed 's|\s||g')
  install_packages nodejs="${version}"
}

NODEJS_LATEST_VERSION=25
NODEJS_LTS_VERSION=22

echo "Offering user n / nvm version manager choice"
menu_choice=$(

  menu --title "nodejs" --radiolist "Choose Node.js install method\n[SPACE to select, ENTER to confirm]:" 12 80 4 \
    "NVERMAN" "Install with n version manager (RECOMMENDED)" off \
    "NVM" "Install with nvm version manager" off \
    "LATEST" "Install latest version (${NODEJS_LATEST_VERSION}) via APT package manager   " off \
    "LTS" "Install LTS version (${NODEJS_LTS_VERSION}) via APT package manager" off

  # shellcheck disable=SC2188
  3>&1 1>&2 2>&3
)

if [[ ${menu_choice} == "CANCELLED" ]]; then
  echo "Skipping NODE"
  exit 1
fi

createtmp
echo "Look for Windows version of npm"
NPM_WIN_PROFILE="/etc/profile.d/rm-win-npm-path.sh"

if [[ "$(command -v npm)" == $(wslpath 'C:\')* ]]; then

  if ! (confirm --title "npm in Windows" --yesno "npm is already installed in Windows in \"$(wslpath -m "$(command -v npm)")\".\n\nWould you still want to install the Linux version? This will hide the Windows version inside Pengwin." 12 80); then
    echo "Skipping NODE"
    exit 1
  fi

  sudo tee "${NPM_WIN_PROFILE}" <<EOF
#!/bin/bash

# Check if we have Windows Path
if ( command -v cmd.exe >/dev/null ); then

  WIN_C_PATH="\$(wslpath 'C:\')"

  while [[ true ]]; do

    WIN_YARN_PATH="\$(dirname "\$(command -v yarn)")"
    if [[ "\${WIN_YARN_PATH}" == "\${WIN_C_PATH}"* ]]; then
      export PATH=\$(echo "\${PATH}" | sed -e "s#\${WIN_YARN_PATH}##")
    fi

    WIN_NPM_PATH="\$(dirname "\$(command -v npm)")"
    if [[ "\${WIN_NPM_PATH}" == "\${WIN_C_PATH}"* ]]; then
      export PATH=\$(echo "\${PATH}" | sed -e "s#\${WIN_NPM_PATH}##")
    else
      break
    fi

  done
fi
EOF

  eval "$(cat "${NPM_WIN_PROFILE}")"
fi

if [[ ${menu_choice} == *"NVERMAN"* ]]; then
  echo "Ensuring we have build-essential installed"
  sudo apt-get -y -q install build-essential

  echo "Installing n, Node.js version manager"
  curl -L https://git.io/n-install -o n-install.sh
  env SHELL="$(command -v bash)" bash n-install.sh -y #Force the installation to bash

  N_PATH="$(cat "${HOME}"/.bashrc | grep "^.*N_PREFIX.*$" | cut -d'#' -f 1)"
  echo "${N_PATH}" | sudo tee "/etc/profile.d/n-prefix.sh"
  eval "${N_PATH}"

  # Clear N from .bashrc now not needed
  filecontents=$(cat "$HOME/.bashrc" | grep -v -e '^.*N_PREFIX.*$')
  printf '%s' "$filecontents" >"$HOME/.bashrc"

  # Add the path for sudo
  SUDO_PATH="$(sudo cat /etc/sudoers | grep "secure_path" | sed "s/\(^.*secure_path=\"\)\(.*\)\(\"\)/\2/")"
  echo "Defaults secure_path=\"${SUDO_PATH}:${N_PREFIX}/bin\"" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/npm-path

  echo "Installing latest node.js release"
  n latest

  # Add n to fish shell
  FISH_DIR="$HOME/.config/fish/conf.d"
  FISH_CONF="$FISH_DIR/n-prefix.fish"

  mkdir -p "$FISH_DIR"
  sh -c "cat > $FISH_CONF" <<EOF
#!/bin/fish

set -x N_PREFIX "\$HOME/n"

if not contains -- \$N_PREFIX/bin "\$PATH"
  set PATH "\$N_PREFIX/bin:\$PATH"
end
EOF

  # Add npm to bash completion
  sudo mkdir -p /etc/bash_completion.d
  npm completion | sudo tee /etc/bash_completion.d/npm

  touch "${HOME}"/.should-restart
elif [[ ${menu_choice} == *"NVM"* ]]; then
  echo "Installing nvm, Node.js version manager"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

  # Set NVM_DIR variable and load nvm
  NVM_PATH="$(cat "${HOME}"/.bashrc | grep '^export NVM_DIR=')"
  NVM_SH="$(cat "${HOME}"/.bashrc | grep '^.*$NVM_DIR/nvm.sh.*$')"
  NVM_COMP="$(cat "${HOME}"/.bashrc | grep '^.*$NVM_DIR/bash_completion.*$')"
  eval "$NVM_PATH"
  eval "$NVM_SH"

  # Clear nvm from .bashrc now not needed
  filecontents=$(cat "$HOME/.bashrc" | grep -v -e '^.*NVM_DIR.*$')
  printf '%s' "$filecontents" >"$HOME/.bashrc"

  # Add nvm to path, nvm to bash completion
  echo "$NVM_PATH" | sudo tee /etc/profile.d/nvm-prefix.sh
  echo "$NVM_SH" | sudo tee -a /etc/profile.d/nvm-prefix.sh
  sudo mkdir -p /etc/bash_completion.d
  echo "$NVM_COMP" | sudo tee /etc/bash_completion.d/nvm

  # Add nvm to fish shell
  FISH_DIR="$HOME/.config/fish/conf.d"
  FISH_CONF="$FISH_DIR/nvm-prefix.fish"

  mkdir -p "$FISH_DIR"
  sh -c "cat > $FISH_CONF" <<EOF
#!/bin/fish

set -x NVM_DIR $HOME/.nvm

function nvm
  bass . "$NVM_DIR/nvm.sh" ';' nvm $argv
end

function npm
  bass . "$NVM_DIR/nvm.sh" ';' npm $argv
end

function node
  bass . "$NVM_DIR/nvm.sh" ';' node $argv
end
EOF

  # Add the path for sudo
  #SUDO_PATH="$(sudo cat /etc/sudoers | grep "secure_path" | sed "s/\(^.*secure_path=\"\)\(.*\)\(\"\)/\2/")"
  #echo "Defaults secure_path=\"${SUDO_PATH}:${NVM_DIR}/bin\"" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/npm-path

  echo "Installing latest Node.js release"
  nvm install node --latest-npm

  # Add npm to bash completion
  npm completion | sudo tee /etc/bash_completion.d/npm

  touch "${HOME}"/.should-restart
elif [[ ${menu_choice} == *"LATEST"* ]]; then
  install_nodejs_nodesource "${NODEJS_LATEST_VERSION}"
elif [[ ${menu_choice} == *"LTS"* ]]; then
  install_nodejs_nodesource "${NODEJS_LTS_VERSION}"
fi

exit_status=$?
cleantmp

if [[ ${exit_status} != 0 ]]; then
  exit "${exit_status}"
fi

if (confirm --title "YARN" --yesno "Would you like to download and install the Yarn package manager? (optional)" 8 80); then
  echo "Installing YARN"

  if command -v yarn; then
    sudo apt-get remove -y -q yarn --autoremove 2>/dev/null
    sudo rm -f /etc/apt/sources.list.d/yarn.list

    # shellcheck disable=SC2119
    update_packages
  fi

  if ! corepack enable; then
    sudo corepack enable
  fi

  corepack prepare yarn@stable --activate

else
  echo "Skipping YARN"
fi

