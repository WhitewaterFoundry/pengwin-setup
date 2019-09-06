#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if [[ ! ${SkipConfirmations} ]]; then

  if (whiptail --title "NODE" --yesno "Would you like to download and install Node.js (with npm)?" 8 65); then
    echo "Installing NODE"
  else
    echo "Skipping NODE"
    exit 1
  fi
fi

echo "Offering user n / nvm version manager choice"
menu_choice=$(

  menu --title "nodejs" --radiolist "Choose Node.js install method\n[SPACE to select, ENTER to confirm]:" 12 90 4 \
    "N" "Install with n version manager (fish shell compat. EXPERIMENTAL)" off \
    "NVM" "Install with nvm version manager (fish shell compat. EXPERIMENTAL)" off \
    "LATEST" "Install latest version via APT package manager" off \
    "LTS" "Install LTS version via APT package manager" off \

    3>&1 1>&2 2>&3)

if [[ ${menu_choice} == "CANCELLED" ]] ; then
  echo "Skipping NODE"
  exit 1
fi

createtmp
echo "Look for Windows version of npm"
NPM_WIN_PROFILE="/etc/profile.d/rm-win-npm-path.sh"
NPM_PROFILE="/etc/profile.d/n-prefix.sh"

if [[ "$(which npm)" == $(wslpath 'C:\')* ]]; then

  if ! (confirm --title "npm in Windows" --yesno "npm is already installed in Windows in \"$(wslpath -m "$(which npm)")\".\n\nWould you still want to install the Linux version? This will hide the Windows version inside Pengwin." 12 80); then
    echo "Skipping NODE"
    exit 1
  fi

  sudo tee "${NPM_WIN_PROFILE}" << EOF

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  WIN_C_PATH="\$(wslpath 'C:\')"

  while [[ true ]]; do

    WIN_YARN_PATH="\$(dirname "\$(which yarn)")"
    if [[ "\${WIN_YARN_PATH}" == "\${WIN_C_PATH}"* ]]; then
      export PATH=\$(echo "\${PATH}" | sed -e "s#\${WIN_YARN_PATH}##")
    fi

    WIN_NPM_PATH="\$(dirname "\$(which npm)")"
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

if [[ ${menu_choice} == "N" ]] ; then
  echo "Ensuring we have build-essential installed"
  sudo apt-get -y -q install build-essential

  echo "Installing n, Node.js version manager"
  curl -L https://git.io/n-install -o n-install.sh
  env SHELL="$(which bash)" bash  n-install.sh -y #Force the installation to bash

  N_PATH="$(cat ${HOME}/.bashrc | grep "^.*N_PREFIX.*$" | cut -d'#' -f 1)"
  echo "${N_PATH}" | sudo tee "${NPM_PROFILE}"
  eval "${N_PATH}"

  # Clear N from .bashrc now not needed
  filecontents=$(cat "$HOME/.bashrc" | grep -v -e '^.*N_PREFIX.*$')
  printf '%s' "$filecontents" > "$HOME/.bashrc"

  # Add the path for sudo
  SUDO_PATH="$(sudo cat /etc/sudoers | grep "secure_path" | sed "s/\(^.*secure_path=\"\)\(.*\)\(\"\)/\2/")"
  echo "Defaults secure_path=\"${SUDO_PATH}:${N_PREFIX}/bin\"" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/npm-path

  echo "Installing latest node.js release"
  n latest

  echo "Installing npm"
  curl -0 -L https://npmjs.com/install.sh -o install.sh
  sh install.sh

  # Add n to fish shell
  FISH_DIR="$HOME/.config/fish/conf.d"
  FISH_CONF="$FISH_DIR/n-prefix.fish"

  mkdir -p "$FISH_DIR"
  sh -c "cat > $FISH_CONF" << EOF
#!/bin/fish

set -x N_PREFIX $HOME/n

if not contains -- $N_PREFIX/bin $PATH
  set PATH $N_PREFIX/bin $PATH
end
EOF

  # Add npm to bash completion
  sudo mkdir -p /etc/bash_completion.d
  npm completion | sudo tee /etc/bash_completion.d/npm
elif [[ ${menu_choice} == "NVM" ]] ; then
  echo "Installing nvm, Node.js version manager"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

  # Set NVM_DIR variable and load nvm
  NVM_PATH="$(cat ${HOME}/.bashrc | grep '^export NVM_DIR=')"
  NVM_SH="$(cat ${HOME}/.bashrc | grep '^.*$NVM_DIR/nvm.sh.*$')"
  NVM_COMP="$(cat ${HOME}/.bashrc | grep '^.*$NVM_DIR/bash_completion.*$')"
  eval "$NVM_PATH"
  eval "$NVM_SH"

  # Clear nvm from .bashrc now not needed
  filecontents=$(cat "$HOME/.bashrc" | grep -v -e '^.*NVM_DIR.*$')
  printf '%s' "$filecontents" > "$HOME/.bashrc"

  # Add nvm to path, nvm to bash completion
  echo "$NVM_PATH" | sudo tee /etc/profile.d/nvm-prefix.sh
  echo "$NVM_SH" | sudo tee -a /etc/profile.d/nvm-prefix.sh
  sudo mkdir -p /etc/bash_completion.d
  echo "$NVM_COMP" | sudo tee /etc/bash_completion.d/nvm

  # Add nvm to fish shell
  FISH_DIR="$HOME/.config/fish/conf.d"
  FISH_CONF="$FISH_DIR/nvm-prefix.fish"

  mkdir -p "$FISH_DIR"
  sh -c "cat > $FISH_CONF" << EOF
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
  nvm install $(nvm ls-remote | tail -1 | sed -e 's|^\s||g') --latest-npm

  # Add npm to bash completion
  npm completion | sudo tee /etc/bash_completion.d/npm
elif [[ ${menu_choice} == "LATEST" ]] ; then
  echo "Installing latest node.js version from NodeSource repository"

  major_vers=12
  nodesrc_url="https://deb.nodesource.com/setup_$major_vers.x"
  curl -sL "$nodesrc_url" -o repo-install.sh
  sudo bash repo-install.sh

  version=$(apt-cache madison nodejs | grep 'nodesource' | grep -E "^\snodejs\s|\s$major_vers" | cut -d'|' -f2 | sed 's|\s||g')
  sudo apt-get install -y -q nodejs=$version
elif [[ ${menu_choice} == "LTS" ]] ; then
  echo "Installing LTS node.js version from NodeSource repository"

  major_vers=10
  nodesrc_url="https://deb.nodesource.com/setup_$major_vers.x"
  curl -sL "$nodesrc_url" -o repo-install.sh
  sudo bash repo-install.sh

  version=$(apt-cache madison nodejs | grep 'nodesource' | grep -E "^\snodejs\s|\s$major_vers" | cut -d'|' -f2 | sed 's|\s||g')
  sudo apt-get install -y -q nodejs=$version
fi
cleantmp

if (whiptail --title "YARN" --yesno "Would you like to download and install the Yarn package manager? (optional)" 8 80) ; then
  echo "Installing YARN"
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update && sudo apt-get install yarn -y --no-install-recommends
else
  echo "Skipping YARN"
fi
