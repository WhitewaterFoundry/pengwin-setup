#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/../common.sh" "$@"
#Imported from common.h
declare SetupDir

function show_warning() {

  if [[ -n "${SkipConfirmations}" ]]; then
    return
  fi

  # Usage: show_warning <UNINSTALL_ITEM> <PREVIOUS_ARGS>
  local uninstall_item="$1"
  shift 1

  echo "Offering user $uninstall_item uninstall"
  if whiptail --title "!! $uninstall_item !!" --yesno "Are you sure you would like to uninstall $uninstall_item?\n\nWhile you can reinstall $uninstall_item from pengwin-setup, any of your own changes to install file(s)/directory(s) will be lost.\n\nSelect 'yes' if you would like to proceed" 14 85; then
    if whiptail --title "!! $uninstall_item !!" --yesno "Are you absolutely sure you'd like to proceed in uninstalling $uninstall_item?" 8 85; then
      echo "User confirmed $uninstall_item uninstall"
      return
    fi
  fi

  echo "User cancelled $uninstall_item uninstall"
  bash ${SetupDir}/uninstall.sh "$@"

}

function rem_file() {

  # Usage: remove_file <FILE>
  echo "Removing file: '$1'"
  if [[ -f "$1" ]]; then
    rm -f "$1"
  else
    echo "... not found!"
  fi

}

function rem_dir() {

  # Usage: remove_dir <DIR>
  echo "Removing directory: '$1'"
  if [[ -d "$1" ]]; then
    rm -rf "$1"
  else
    echo "... not found!"
  fi

}

function sudo_rem_file() {

  # Same as above, just with administrative privileges
  echo "Removing file: '$1'"
  if [[ -f "$1" ]]; then
    sudo rm -f "$1"
  else
    echo "... not found!"
  fi

}

function sudo_rem_dir() {

  # Same as above, just with administrative privileges
  echo "Removing directory: '$1'"
  if [[ -d "$1" ]]; then
    sudo rm -rf "$1"
  else
    echo "... not found!"
  fi

}

function clean_file() {

  # Usage: clean_file <FILE> <REGEX>

  # Following n (node version manager) install script,
  # best to clean file by writing to memory then
  # writing back to file
  local fileContents
  fileContents=$(grep -Ev "$2" "$1")
  printf '%s\n' "$fileContents" >"$1"

}

function sudo_clean_file() {

  # Same as above, just with administrative privileges
  local fileContents
  fileContents=$(sudo grep -Ev "$2" "$1")
  sudo bash -c "printf '%s\\n' '$fileContents' > '$1'"

}

function inclusive_file_clean() {

  # Usage: inclusive_file_clean <FILE> <SEARCHSTRING>
  local fileContents
  fileContents=$(sed -e ':a' -e 'N' -e '$!ba' -e "s|$2\\n.*\\n$2||g" "$1")
  cat >"$1" <<EOF
$fileContents
EOF

}

function sudo_inclusive_file_clean() {

  # Same as above
  local fileContents
  fileContents=$(sudo sed -e ':a' -e 'N' -e '$!ba' -e "s|$2\\n.*\\n$2||g" "$1")
  sudo bash -c "cat > '$1'" <<EOF
$fileContents
EOF

}

function remove_package() {

  # Usage: remove_package <PACKAGES...>
  echo "Removing APT packages:" "$@"
  local installed

  installed=""
  for i in "$@"; do
    if (dpkg-query -s "$i" | grep 'installed') >/dev/null 2>&1; then
      installed="$i $installed"
    else
      echo "... $i not installed!"
    fi
  done

  if [[ $installed != "" ]]; then
    echo "Uninstalling: $installed"
    sudo apt-get remove -y -q $installed --autoremove
  fi

}

function pip_uninstall() {

  # Usage: pip_uninstall <2/3> <PACKAGES>
  local installed=''
  local pip=''

  case "$1" in
  2)
    pip='pip2'
    ;;
  3)
    pip='pip3'
    ;;
  esac
  shift 1

  echo "Removing pip packages: $installed"
  if $pip --version >/dev/null 2>&1; then
    for i in "$@"; do
      if ($pip list | grep "$i ") >/dev/null 2>&1; then
        installed="$i $installed"
      else
        echo "... $i not installed!"
      fi
    done

    $pip uninstall $installed -y
    return
  fi

  echo "... not installed!"

}

function sudo_pip_uninstall() {

  # Usage: sudo_pip_uninstall <2/3> <PACKAGES>
  local installed=''
  local pip=''

  case "$1" in
  2)
    pip='pip2'
    ;;
  3)
    pip='pip3'
    ;;
  esac
  shift 1

  echo "Removing pip packages: $installed"
  if $pip --version >/dev/null 2>&1; then
    for i in "$@"; do
      if (sudo $pip list | grep "$i ") >/dev/null 2>&1; then
        installed="$i $installed"
      else
        echo "... $i not installed!"
      fi
    done

    sudo $pip uninstall $installed -y
    return
  fi

  echo "... not installed!"

}

function safe_rem_microsoftgpg() {

  # Usage: safe_rem_microsoftgpg
  # (no arguments necessary)
  local pkg_list='azure-cli code dotnet powershell'

  for i in $pkg_list; do
    if (dpkg-query -s "$i" | grep 'installed') >/dev/null 2>&1; then
      echo "$i installed, not safe to remove Microsoft APT key"
      return
    fi
  done

  # safe to remove!
  sudo_rem_file "/etc/apt/trusted.gpg.d/microsoft.gpg"

}

function safe_rem_microsoftsrc() {

  # Usage: safe_rem_microsoftsrc
  # (no arguments necessary)
  local pkg_list='dotnet powershell'

  # check packages not installed
  for i in $pkg_list; do
    if (dpkg-query -s "$i" | grep 'installed') >/dev/null 2>&1; then
      echo "$i installed, not safe to remove Microsoft APT source"
      return
    fi
  done

  # safe to remove!
  sudo_rem_file "/etc/apt/sources.list.d/microsoft.list"

}

function safe_rem_debianstablesrc() {

  # Usage: safe_rem_debianstablesrc
  # (no arguments necessary)
  local pkg_list='code dotnet powershell'

  # check packages not installed
  for i in $pkg_list; do
    if (dpkg-query -s "$i" | grep 'installed') >/dev/null 2>&1; then
      echo "$i installed, not safe to remove Debian stable APT source"
      return
    fi
  done

  # safe to remove!
  sudo_rem_file "/etc/apt/sources.list.d/stable.list"

}
