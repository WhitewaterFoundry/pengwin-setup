#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (confirm --title "RUBY" --yesno "Would you like to download and install Ruby using rbenv?" 8 65); then
  echo "Installing RUBY"
  echo "Installing Ruby dependencies"

  install_packages git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
  createtmp

  echo "Getting rbenv"
  git clone --depth=1 https://github.com/rbenv/rbenv.git ~/.rbenv

  echo "Configuring rbenv"
  (
    cd ~/.rbenv && src/configure && make -j "$(nproc)" -C src
  )

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

  # shellcheck disable=SC1090
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
  env MAKE_OPTS="-j $(nproc)" rbenv install 4.0.1 --verbose
  rbenv global 4.0.1
  echo "Checking ruby version"
  ruby -v
  echo "Installing bundler using gem"
  gem install bundler -v 4.0.6
  echo "Rehashing rbenv"
  rbenv rehash

  unset conf_path
  unset conf_path_fish
  cleantmp

  enable_should_restart
else
  echo "Skipping RUBY"
fi

if (confirm --title "RAILS" --yesno "Would you like to download and install Rails from RubyGems?" 8 65); then
  echo "Installing RAILS"

  install_packages git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev slibffi-dev
  createtmp
  gem install rails -v 8.1.2
  rbenv rehash
  cleantmp

  enable_should_restart
else
  echo "Skipping RAILS"
fi
