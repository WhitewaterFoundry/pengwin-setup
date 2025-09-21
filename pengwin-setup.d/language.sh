#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.h
declare SetupDir

if (confirm --title "Language" --yesno "Would you like to configure default keyboard input/language?" 8 65); then
  echo "Running $ dpkg-reconfigure locales"
  sudo dpkg-reconfigure locales
else
  return 1
fi
