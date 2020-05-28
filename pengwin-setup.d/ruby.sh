#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (whiptail --title "RUBY" --yesno "Would you like to download and install Ruby using rbenv?" 8 65); then
  echo "Installing RUBY"
  echo "Installing Ruby dependencies"

  sudo apt-get -y -q install git-core curl zlib1g-dev build-essential libssl-dev libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev
  createtmp

  echo "Getting rbenv"
  git clone --depth=1 https://github.com/rbenv/rbenv.git ~/.rbenv

  echo "Configuring rbenv"

  conf_path='/etc/profile.d/ruby.sh'

  # shellcheck disable=SC2016
  echo 'export PATH="${HOME}/.rbenv/bin:${PATH}"' | sudo tee "${conf_path}"
  # shellcheck disable=SC2016
  echo 'eval "$(rbenv init -)"' | sudo tee -a "${conf_path}"

  echo "Getting ruby-build"
  git clone --depth=1 https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

  echo "Configuring ruby-build"
  # shellcheck disable=SC2016
  echo 'export PATH="${HOME}/.rbenv/plugins/ruby-build/bin:${PATH}"' | sudo tee -a "${conf_path}"
  source "${conf_path}"

  #Copy configuration to  fish
  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"
  conf_path_fish="${__fish_sysconf_dir}/ruby.fish"

  # shellcheck disable=SC2016
  echo 'set PATH $HOME/.rbenv/bin $PATH' | sudo tee "${conf_path_fish}"
  # shellcheck disable=SC2016
  echo 'set PATH $HOME/.rbenv/shims $PATH' | sudo tee -a "${conf_path_fish}"
  echo 'rbenv rehash >/dev/null ^&1' | sudo tee -a "${conf_path_fish}"

  echo "Installing Ruby using rbenv"
  rbenv install 2.5.3 --verbose
  rbenv global 2.5.3
  echo "Checking ruby version"
  ruby -v
  echo "Installing bundler using gem"
  gem install bundler -v 1.17.3
  echo "Rehashing rbenv"
  rbenv rehash
  cleantmp
else
  echo "Skipping RUBY"
fi

if (whiptail --title "RAILS" --yesno "Would you like to download and install Rails from RubyGems?" 8 65); then
  echo "Installing RAILS"

  echo "Checking for node"
  command_check "$HOME/n/bin/node" "-v"
  node_check=$?
  if [ $node_check -eq 1 ]; then # double checks if our local nodejs install was just performed but PATH not yet updated
    echo "node not installed. Offering user nodejs install"
    if (whiptail --title "NODE" --yesno "Ruby on Rails framework requires JavaScript Runtime Environment (Node.js) to manage the features of Rails.\n\nWould you like to download and install NodeJS using n and the npm package manager?" 12 65); then
      bash "${SetupDir}"/nodejs.sh -y "$@"
    else
      echo "Skipping RAILS"
      exit 1
    fi
  fi
  echo "node installed"

  sudo apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev
  createtmp
  gem install rails -v 5.2.0
  rbenv rehash
  cleantmp
  
  touch "${HOME}"/.should-restart
else
  echo "Skipping RAILS"
fi
