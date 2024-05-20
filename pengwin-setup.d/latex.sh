#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir


latex_choice=$(

menu --title "LaTeX" --radiolist "Select the version you would like to install\n[SPACE to select, ENTER to confirm]:" 12 74 4 \
    "FULL" "Install all TexLive packages" on \
    "BASE" "Install essential TexLive packages " off \
    "RECOMMENDED" "Install recommended TexLive packages" off \
    "EXTRA" "Install a large collections of TexLive packages" off \


3>&1 1>&2 2>&3)

if [[ ${latex_choice} == "CANCELLED" ]] ; then
  echo "Skipping LaTeX"
fi

if [[ ${latex_choice} == *"FULL"* ]] ; then
  echo "Installing TexLive Full..."
  sudo apt-get install -y texlive-full
fi

if [[ ${latex_choice} == *"BASE"* ]] ; then
  echo "Installing TexLive Base..."
  sudo apt-get install -y texlive-latex-base
fi

if [[ ${latex_choice} == *"RECOMMENDED"* ]] ; then
  echo "Installing TexLive Recommended..."
  sudo apt-get install -y texlive-latex-base texlive-latex-recommended
fi

if [[ ${menu_choice} == *"EXTRA"* ]] ; then
  echo "Installing TexLive Extra..."
  sudo apt-get install -y texlive-latex-base texlive-latex-extra
fi

