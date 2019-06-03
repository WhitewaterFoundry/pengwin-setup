#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if [[ ! ${SkipConfirmations} ]]; then

  if (whiptail --title "NODE" --yesno "Would you like to download and install NodeJS using n and the npm package manager?" 8 88); then
    echo "Installing NODE"
  else
    echo "Skipping NODE"

    exit 1
  fi
fi

createtmp

echo "Ensuring we have build-essential installed"
sudo apt-get -y -q install build-essential

echo "Installing n, Node.js version manager"
curl -L https://git.io/n-install -o n-install.sh
env SHELL="$(which bash)" bash  n-install.sh -y #Force the installation to bash

N_PATH="$(cat ${HOME}/.bashrc | grep "^.*N_PREFIX.*$" | cut -d'#' -f 1)"

echo "${N_PATH}" | sudo tee "/etc/profile.d/n-prefix.sh"

eval "${N_PATH}"

echo "Installing latest node.js release"

n latest

echo "Installing npm"
curl -0 -L https://npmjs.com/install.sh -o install.sh
sh install.sh

sudo mkdir -p /etc/bash_completion.d
npm completion | sudo tee /etc/bash_completion.d/npm

cleantmp
if (whiptail --title "YARN" --yesno "Would you like to download and install the Yarn package manager? (optional)" 8 80) ; then
  echo "Installing YARN"
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update && sudo apt-get install yarn -y --no-install-recommends
else
  echo "Skipping YARN"
fi
