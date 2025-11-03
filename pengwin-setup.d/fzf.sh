#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (confirm --title "FZF" --yesno "Would you like to download and install command line finder fzf?" 8 80); then
  echo "Installing FZF"
  cd ~ || exit
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  cd ~/.fzf || exit
  ./install --all
else
  echo "Skipping FZF"
fi
