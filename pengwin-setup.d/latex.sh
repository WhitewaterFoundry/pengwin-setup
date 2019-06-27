#!/bin/bash

source $(dirname "$0")/common.sh "$@"


latex_choice=$(

menu --title "LaTeX" --radiolist --separate-output "Select the version you would like to install\n[SPACE to select, ENTER to confirm]:" 16 95 8 \
    "FULL" "Install all TexLive packages" on \
    "BASE" "Install essential TexLive packages " off \
    "RECOMMENDED" "Install recommended TexLive packages" off \
    "EXTRAS" "Install a large collections of TexLive packages" off \


3>&1 1>&2 2>&3)

if [[ ${latex_choice} == "CANCELLED" ]] ; then
  echo "Skipping LaTeX"
fi

if [[ ${latex_choice} == *"FULL"* ]] ; then
  echo "Installing TexLive Full..."
fi

if [[ ${latex_choice} == *"BASE"* ]] ; then
  echo "Installing TexLive Base..."
fi

if [[ ${latex_choice} == *"RECOMMENDED"* ]] ; then
  echo "Installing TexLive Recommended..."
fi

if [[ ${menu_choice} == *"EXTRAS"* ]] ; then
  echo "Installing TexLive Extras..."
fi

