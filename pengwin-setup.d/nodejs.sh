#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if [[ ! ${SkipConfirmations} ]]; then

  if (whiptail --title "NODE" --yesno "Would you like to download and install Node.js with npm using either the n or nvm version manager?" 8 88); then
    echo "Installing NODE"
  else
    echo "Skipping NODE"

    exit 1
  fi
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
  WIN_NPM_PATH="\$(dirname "\$(which npm)")"
  WIN_C_PATH="\$(wslpath 'C:\')"

  if [[ "\${WIN_NPM_PATH}" == "\${WIN_C_PATH}"* ]]; then
    PATH=\$(echo "\${PATH}" | sed -e "s#\${WIN_NPM_PATH}##")
  fi

  WIN_YARN_PATH="\$(dirname "\$(which yarn)")"
  if [[ "\${WIN_YARN_PATH}" == "\${WIN_C_PATH}"* ]]; then
    PATH=\$(echo "\${PATH}" | sed -e "s#\${WIN_YARN_PATH}##")
  fi
fi
EOF

  eval "$(cat "${NPM_WIN_PROFILE}")"

fi

echo "Offering user n / nvm version manager choice"
menu_choice=$(

  menu --title "nodejs" --radiolist "Choose Node.js version manager\n[SPACE to select, ENTER to confirm]:" 16 95 10 \
    "N" "'n' Node.js version manager" off \
    "NVM" "'nvm' Node.js version manager" off \

    3>&1 1>&2 2>&3)

if [[ ${menu_choice} == "CANCELLED" ]] ; then
  exit 1
elif [[ ${menu_choice} == "N" ]] ; then
  echo "Ensuring we have build-essential installed"
  sudo apt-get -y -q install build-essential

  echo "Installing n, Node.js version manager"
  curl -L https://git.io/n-install -o n-install.sh
  env SHELL="$(which bash)" bash  n-install.sh -y #Force the installation to bash

  N_PATH="$(cat ${HOME}/.bashrc | grep "^.*N_PREFIX.*$" | cut -d'#' -f 1)"

  echo "${N_PATH}" | sudo tee "${NPM_PROFILE}"
  eval "${N_PATH}"

  # Add the path for sudo
  SUDO_PATH="$(sudo cat /etc/sudoers | grep "secure_path" | sed "s/\(^.*secure_path=\"\)\(.*\)\(\"\)/\2/")"
  echo "Defaults secure_path=\"${SUDO_PATH}:${N_PREFIX}/bin\"" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/npm-path

  echo "Installing latest node.js release"
  n latest

  echo "Installing npm"
  curl -0 -L https://npmjs.com/install.sh -o install.sh
  sh install.sh

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

  # Add nvm to path, nvm to bash completion
  echo '$NVM_PATH' | sudo tee /etc/profile.d/nvm-prefix.sh
  echo '$NVM_SH' | sudo tee -a /etc/profile.d/nvm-prefix.sh
  sudo mkdir -p /etc/bash_completion.d
  echo '$NVM_COMP' | sudo tee /etc/bash_completion.d/nvm

  # Add the path for sudo
  #SUDO_PATH="$(sudo cat /etc/sudoers | grep "secure_path" | sed "s/\(^.*secure_path=\"\)\(.*\)\(\"\)/\2/")"
  #echo "Defaults secure_path=\"${SUDO_PATH}:${NVM_DIR}/bin\"" | sudo EDITOR='tee ' visudo --quiet --file=/etc/sudoers.d/npm-path

  echo "Installing latest Node.js release"
  nvm install $(nvm ls-remote | tail -1 | sed -e 's|^\s||g') --latest-npm

  # Add npm to bash completion
  npm completion | sudo tee /etc/bash_completion.d/npm
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
