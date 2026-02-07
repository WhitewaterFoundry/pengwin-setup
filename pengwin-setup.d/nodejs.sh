#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SKIP_CONFIMATIONS

NODEJS_LATEST_VERSION=25
NODEJS_LTS_VERSION=24
NODEJS_WSL1_MAX_VERSION=22

#######################################
# Install the packaged version of NodeJS from nodesource repos
# Arguments:
#   Major node version to install
#######################################
# shellcheck disable=SC2155
function install_nodejs_nodesource() {
  local major_vers=${1}
  local version_type="latest"
  
  if [[ "${major_vers}" == "${NODEJS_LTS_VERSION}" ]]; then
    version_type="LTS"
  fi
  
  echo "Installing ${version_type} node.js version from NodeSource repository"

  if ! curl -fsSL "https://deb.nodesource.com/setup_${major_vers}.x" | sudo -E bash -; then
    echo "Failed to setup NodeSource repository"
    return 1
  fi
  
  local version=$(apt-cache madison nodejs | grep 'nodesource' | head -1 | grep -E "^\s+nodejs\s+.*$major_vers" | cut -d'|' -f2 | sed 's|\s||g')
  
  if [[ -z "${version}" ]]; then
    echo "Failed to find Node.js version ${major_vers} in repository"
    return 1
  fi
  
  install_packages nodejs="${version}"
}

# Adjust versions for WSL1 compatibility - modifying these global constants before
# the menu is intentional so the user sees the correct version numbers in the menu
# and all installation methods (n, nvm, nodesource) use WSL1-compatible versions
if is_wsl1; then
  echo "WSL1 detected: Limiting Node.js versions to ${NODEJS_WSL1_MAX_VERSION}"
  if [[ ${NODEJS_LATEST_VERSION} -gt ${NODEJS_WSL1_MAX_VERSION} ]]; then
    NODEJS_LATEST_VERSION=${NODEJS_WSL1_MAX_VERSION}
  fi
  if [[ ${NODEJS_LTS_VERSION} -gt ${NODEJS_WSL1_MAX_VERSION} ]]; then
    NODEJS_LTS_VERSION=${NODEJS_WSL1_MAX_VERSION}
  fi
fi

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

  sudo tee "${NPM_WIN_PROFILE}" <<'EOF'
#!/bin/sh

# Check if we have Windows Path
if command -v cmd.exe >/dev/null 2>&1; then

  WIN_C_PATH="$(wslpath 'C:\')"

  while true; do

    WIN_YARN_PATH="$(dirname "$(command -v yarn)")"
    case "${WIN_YARN_PATH}" in
      "${WIN_C_PATH}"*)
        export PATH=$(echo "${PATH}" | sed -e "s#${WIN_YARN_PATH}##")
        ;;
    esac

    WIN_NPM_PATH="$(dirname "$(command -v npm)")"
    case "${WIN_NPM_PATH}" in
      "${WIN_C_PATH}"*)
        export PATH=$(echo "${PATH}" | sed -e "s#${WIN_NPM_PATH}##")
        ;;
      *)
        break
        ;;
    esac

  done
fi
EOF

  eval "$(cat "${NPM_WIN_PROFILE}")"
fi

exit_status=0

if [[ ${menu_choice} == *"NVERMAN"* ]]; then
  echo "Ensuring we have build-essential installed"
  sudo apt-get -y -q install build-essential

  echo "Installing n, Node.js version manager"
  curl -L https://git.io/n-install -o n-install.sh
  env SHELL="$(command -v bash)" bash n-install.sh -y "${NODEJS_LTS_VERSION}"
  exit_status=$?
  if [[ ${exit_status} != 0 ]]; then
    cleantmp
    exit "${exit_status}"
  fi

  N_PATH="$(cat "${HOME}"/.bashrc | grep "^.*N_PREFIX.*$" | cut -d'#' -f 1)"
  echo "${N_PATH}" | sudo tee "/etc/profile.d/n-prefix.sh"
  eval "${N_PATH}"

  # Clear N from .bashrc now not needed
  filecontents=$(cat "$HOME/.bashrc" | grep -v -e '^.*N_PREFIX.*$')
  printf '%s' "$filecontents" >"$HOME/.bashrc"

  # Add the path for sudo
  SUDO_PATH="$(sudo cat /etc/sudoers | grep "secure_path" | sed "s/\(^.*secure_path=\"\)\(.*\)\(\"\)/\2/")"
  echo "Defaults secure_path=\"${SUDO_PATH}:${N_PREFIX}/bin\"" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/npm-path

  exit_status=$?
  if [[ ${exit_status} != 0 ]]; then
    cleantmp
    exit "${exit_status}"
  fi

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

  enable_should_restart
elif [[ ${menu_choice} == *"NVM"* ]]; then
  echo "Installing nvm, Node.js version manager"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  exit_status=$?
  if [[ ${exit_status} != 0 ]]; then
    cleantmp
    exit "${exit_status}"
  fi

  install_packages libatomic1

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

  nvm install "${NODEJS_LTS_VERSION}" --latest-npm
  exit_status=$?
  if [[ ${exit_status} != 0 ]]; then
    cleantmp
    exit "${exit_status}"
  fi

  # Add npm to bash completion
  npm completion | sudo tee /etc/bash_completion.d/npm

  enable_should_restart
elif [[ ${menu_choice} == *"LATEST"* ]]; then
  install_nodejs_nodesource "${NODEJS_LATEST_VERSION}"
  exit_status=$?
elif [[ ${menu_choice} == *"LTS"* ]]; then
  install_nodejs_nodesource "${NODEJS_LTS_VERSION}"
  exit_status=$?
fi

cleantmp

if [[ ${exit_status} != 0 ]]; then
  exit "${exit_status}"
fi

if [[ -z ${SKIP_YARN} ]] && (confirm --title "YARN" --yesno "Would you like to download and install the Yarn package manager? (optional)" 8 80); then
  echo "Installing YARN"

  if command -v yarn; then
    sudo apt-get remove -y -q yarn --autoremove 2>/dev/null
    sudo rm -f /etc/apt/sources.list.d/yarn.list

    # shellcheck disable=SC2119
    update_packages
  fi

  if ! command -v corepack; then
    if ! npm i -g corepack; then
      sudo npm i -g corepack
      sudo chown -R "$(id -u)":"$(id -g)" "$HOME/.npm"
    fi
  fi

  if ! corepack enable; then
    sudo corepack enable
  fi

  corepack prepare yarn@stable --activate

else
  echo "Skipping YARN"
fi

