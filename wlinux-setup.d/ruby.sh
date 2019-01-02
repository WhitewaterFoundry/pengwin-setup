#!/bin/bash

source "/etc/wlinux-setup.d/common.sh"

if (whiptail --title "RUBY" --yesno "Would you like to download and install Ruby using rbenv?" 8 65) then
    echo "Installing RUBY"
    echo "Installing Ruby dependencies"
    sudo apt -t testing install git-core curl zlib1g-dev build-essential libssl-dev libssl1.0-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev -y
    createtmp

    echo "Getting rbenv"
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv

    echo "Configuring rbenv"
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    source ~/.bashrc

    echo "Getting ruby-build"
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

    echo "Configuring ruby-build"
    export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc

    echo "Installing Ruby using rbenv"
    rbenv install 2.5.3 --verbose
    rbenv global 2.5.3
    echo "Checking ruby version"
    ruby -v
    echo "Installing bundler using gem"
    gem install bundler
    echo "Rehashing rbenv"
    rbenv rehash
    cleantmp
else
    echo "Skipping RUBY"
fi

if (whiptail --title "RAILS" --yesno "Would you like to download and install Rails from RubyGems?" 8 65) then
    echo "Installing RAILS"
    updateupgrade
    sudo apt -t testing install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev
    createtmp
    nodeinstall
    gem install rails -v 5.2.0
    rbenv rehash
    cleantmp
else
    echo "Skipping RAILS"
fi