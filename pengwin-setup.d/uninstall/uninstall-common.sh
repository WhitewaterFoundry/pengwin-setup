#!/bin/bash

# shellcheck source=../common.sh
source "$(dirname "$0")/../common.sh" "$@"

#Imported from common.h
declare SetupDir

#######################################
# Display warning dialog to confirm uninstallation of a component.
# Shows two consecutive confirmation dialogs to ensure user wants to proceed.
# If user cancels, returns to uninstall menu. Skipped if SKIP_CONFIMATIONS is set.
# 
# Use case examples:
#   # Confirm uninstallation of Docker
#   show_warning "Docker" "$@"
#   
#   # Confirm uninstallation of Python packages
#   show_warning "Python Development Tools" "$@"
#
# Globals:
#   SKIP_CONFIMATIONS - If set, skips confirmation dialogs
#   SetupDir - Directory containing pengwin-setup scripts
# Arguments:
#   1 - UNINSTALL_ITEM: Name of the item being uninstalled
#   ... - PREVIOUS_ARGS: Additional arguments to pass to uninstall menu
# Returns:
#   0 - User confirmed uninstallation
#   None - Redirects to uninstall menu if user cancels
#######################################
function show_warning() {

  if [[ -n "${SKIP_CONFIMATIONS}" ]]; then
    return
  fi

  # Usage: show_warning <UNINSTALL_ITEM> <PREVIOUS_ARGS>
  local uninstall_item="$1"
  shift 1

  echo "Offering user $uninstall_item uninstall"
  if confirm --title "!! $uninstall_item !!" --yesno "Are you sure you would like to uninstall $uninstall_item?\n\nWhile you can reinstall $uninstall_item from pengwin-setup, any of your own changes to install file(s)/directory(s) will be lost.\n\nSelect 'yes' if you would like to proceed" 14 85; then
    if confirm --title "!! $uninstall_item !!" --yesno "Are you absolutely sure you'd like to proceed in uninstalling $uninstall_item?" 8 85; then
      echo "User confirmed $uninstall_item uninstall"
      return
    fi
  fi

  echo "User cancelled $uninstall_item uninstall"
  bash "${SetupDir}"/uninstall.sh "$@"

}

#######################################
# Remove a regular file from the filesystem.
# Checks if file exists before attempting removal. Safe to call on non-existent files.
# 
# Use case examples:
#   # Remove a configuration file
#   rem_file "${HOME}/.config/myapp/config.json"
#   
#   # Remove a temporary script
#   rem_file "/tmp/install-script.sh"
#   
#   # Remove application data file
#   rem_file "${HOME}/.local/share/myapp/data.db"
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the file to remove
# Returns:
#   None
#######################################
function rem_file() {

  # Usage: remove_file <FILE>
  echo "Removing file: '$1'"
  if [[ -f "$1" ]]; then
    rm -f "$1"
  else
    echo "... not found!"
  fi

}

#######################################
# Remove a symbolic link from the filesystem.
# Checks if the path is a symbolic link before attempting removal.
# Safe to call on non-existent links.
# 
# Use case examples:
#   # Remove a symbolic link to an application
#   rem_link "/usr/local/bin/myapp"
#   
#   # Remove a configuration symlink
#   rem_link "${HOME}/.bashrc.custom"
#   
#   # Remove desktop entry link
#   rem_link "${HOME}/.local/share/applications/myapp.desktop"
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the symbolic link to remove
# Returns:
#   None
#######################################
function rem_link() {

  # Usage: remove_link <FILE>
  echo "Removing link: '$1'"
  if [[ -L "$1" ]]; then
    rm -f "$1"
  else
    echo "... not found!"
  fi

}

#######################################
# Remove a directory and all its contents recursively.
# Checks if directory exists before attempting removal.
# Safe to call on non-existent directories.
# WARNING: This recursively deletes all contents without confirmation.
# 
# Use case examples:
#   # Remove application data directory
#   rem_dir "${HOME}/.config/myapp"
#   
#   # Remove temporary build directory
#   rem_dir "/tmp/build-artifacts"
#   
#   # Remove cached files
#   rem_dir "${HOME}/.cache/myapp"
#
# Globals:
#   None
# Arguments:
#   1 - DIR: Full path to the directory to remove
# Returns:
#   None
#######################################
function rem_dir() {

  # Usage: remove_dir <DIR>
  echo "Removing directory: '$1'"
  if [[ -d "$1" ]]; then
    rm -rf "$1"
  else
    echo "... not found!"
  fi

}

#######################################
# Remove a regular file from the filesystem with administrative privileges.
# Same as rem_file but uses sudo for files requiring elevated permissions.
# Checks if file exists before attempting removal. Safe to call on non-existent files.
# 
# Use case examples:
#   # Remove system configuration file
#   sudo_rem_file "/etc/apt/sources.list.d/myapp.list"
#   
#   # Remove systemd service file
#   sudo_rem_file "/etc/systemd/system/myapp.service"
#   
#   # Remove global application configuration
#   sudo_rem_file "/etc/myapp/config.conf"
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the file to remove
# Returns:
#   None
#######################################
function sudo_rem_file() {

  # Same as above, just with administrative privileges
  echo "Removing file: '$1'"
  if [[ -f "$1" ]]; then
    sudo rm -f "$1"
  else
    echo "... not found!"
  fi

}

#######################################
# Remove a symbolic link from the filesystem with administrative privileges.
# Same as rem_link but uses sudo for links requiring elevated permissions.
# Checks if the path is a symbolic link before attempting removal.
# Safe to call on non-existent links.
# 
# Use case examples:
#   # Remove system-wide binary symlink
#   sudo_rem_link "/usr/local/bin/myapp"
#   
#   # Remove system library link
#   sudo_rem_link "/usr/lib/libmyapp.so"
#   
#   # Remove system configuration symlink
#   sudo_rem_link "/etc/alternatives/editor"
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the symbolic link to remove
# Returns:
#   None
#######################################
function sudo_rem_link() {

  # Same as above, just with administrative privileges
  echo "Removing link: '$1'"
  if [[ -L "$1" ]]; then
    sudo rm -f "$1"
  else
    echo "... not found!"
  fi

}

#######################################
# Remove a directory and all its contents recursively with administrative privileges.
# Same as rem_dir but uses sudo for directories requiring elevated permissions.
# Checks if directory exists before attempting removal.
# Safe to call on non-existent directories.
# WARNING: This recursively deletes all contents without confirmation.
# 
# Use case examples:
#   # Remove system-wide application directory
#   sudo_rem_dir "/opt/myapp"
#   
#   # Remove system cache directory
#   sudo_rem_dir "/var/cache/myapp"
#   
#   # Remove system configuration directory
#   sudo_rem_dir "/etc/myapp"
#
# Globals:
#   None
# Arguments:
#   1 - DIR: Full path to the directory to remove
# Returns:
#   None
#######################################
function sudo_rem_dir() {

  # Same as above, just with administrative privileges
  echo "Removing directory: '$1'"
  if [[ -d "$1" ]]; then
    sudo rm -rf "$1"
  else
    echo "... not found!"
  fi

}

#######################################
# Remove lines matching a regex pattern from a file.
# Reads the file, filters out matching lines, and writes back to the same file.
# Uses grep -Ev for extended regex pattern matching.
# Following the pattern from nvm (node version manager) install script.
# 
# Use case examples:
#   # Remove lines containing specific text from bashrc
#   clean_file "${HOME}/.bashrc" "# Added by myapp"
#   
#   # Remove export statements from profile
#   clean_file "${HOME}/.profile" "^export MYAPP_"
#   
#   # Remove sourcing lines from shell config
#   clean_file "${HOME}/.zshrc" "source.*myapp"
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the file to clean
#   2 - REGEX: Extended regular expression pattern to match lines for removal
# Returns:
#   None
#######################################
function clean_file() {

  # Usage: clean_file <FILE> <REGEX>

  # Following n (node version manager) install script,
  # best to clean file by writing to memory then
  # writing back to file
  local fileContents
  fileContents=$(grep -Ev "$2" "$1")
  printf '%s\n' "$fileContents" >"$1"

}

#######################################
# Remove lines matching a regex pattern from a file with administrative privileges.
# Same as clean_file but uses sudo for files requiring elevated permissions.
# Reads the file, filters out matching lines, and writes back to the same file.
# Uses grep -Ev for extended regex pattern matching.
# 
# Use case examples:
#   # Remove lines from system-wide bashrc
#   sudo_clean_file "/etc/bash.bashrc" "# Added by myapp"
#   
#   # Clean system environment file
#   sudo_clean_file "/etc/environment" "^MYAPP_"
#   
#   # Remove entries from system profile
#   sudo_clean_file "/etc/profile" "source.*myapp"
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the file to clean
#   2 - REGEX: Extended regular expression pattern to match lines for removal
# Returns:
#   None
#######################################
function sudo_clean_file() {

  # Same as above, just with administrative privileges
  local fileContents
  fileContents=$(sudo grep -Ev "$2" "$1")
  sudo bash -c "printf '%s\\n' '$fileContents' > '$1'"

}

#######################################
# Remove a block of lines between two identical marker strings (inclusive).
# Removes the marker lines and everything between them from a file.
# Useful for removing entire code blocks that are wrapped with identical markers.
# 
# Use case examples:
#   # Remove block between comment markers in bashrc
#   inclusive_file_clean "${HOME}/.bashrc" "# BEGIN MYAPP BLOCK"
#   
#   # Remove configuration section from profile
#   inclusive_file_clean "${HOME}/.profile" "### MYAPP CONFIG ###"
#   
#   # Remove bracketed section from any config file
#   inclusive_file_clean "/path/to/config" "=== SECTION ==="
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the file to clean
#   2 - SEARCHSTRING: Marker string that appears at both start and end of block
# Returns:
#   None
#######################################
function inclusive_file_clean() {

  # Usage: inclusive_file_clean <FILE> <SEARCHSTRING>
  local fileContents
  fileContents=$(sed -e ':a' -e 'N' -e '$!ba' -e "s|$2\\n.*\\n$2||g" "$1")
  cat >"$1" <<EOF
$fileContents
EOF

}

#######################################
# Remove a block of lines between two identical marker strings with administrative privileges.
# Same as inclusive_file_clean but uses sudo for files requiring elevated permissions.
# Removes the marker lines and everything between them from a file.
# Useful for removing entire code blocks that are wrapped with identical markers.
# 
# Use case examples:
#   # Remove block from system-wide bashrc
#   sudo_inclusive_file_clean "/etc/bash.bashrc" "# BEGIN MYAPP BLOCK"
#   
#   # Remove configuration section from system profile
#   sudo_inclusive_file_clean "/etc/profile" "### MYAPP CONFIG ###"
#   
#   # Remove bracketed section from system config
#   sudo_inclusive_file_clean "/etc/environment" "=== SECTION ==="
#
# Globals:
#   None
# Arguments:
#   1 - FILE: Full path to the file to clean
#   2 - SEARCHSTRING: Marker string that appears at both start and end of block
# Returns:
#   None
#######################################
function sudo_inclusive_file_clean() {

  # Same as above
  local fileContents
  fileContents=$(sudo sed -e ':a' -e 'N' -e '$!ba' -e "s|$2\\n.*\\n$2||g" "$1")
  sudo bash -c "cat > '$1'" <<EOF
$fileContents
EOF

}

#######################################
# Uninstall one or more APT packages and remove unused dependencies.
# Checks which packages are actually installed before attempting removal.
# Only removes packages that are currently installed on the system.
# Automatically removes unused dependencies with --autoremove.
# 
# Use case examples:
#   # Remove a single package
#   remove_package "nginx"
#   
#   # Remove multiple packages at once
#   remove_package "build-essential" "cmake" "git"
#   
#   # Remove development tools
#   remove_package "gcc" "g++" "make" "autoconf" "automake"
#
# Globals:
#   None
# Arguments:
#   ... - PACKAGES: One or more APT package names to remove
# Returns:
#   None
#######################################
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
    # shellcheck disable=SC2086
    sudo apt-get remove -y -q $installed --autoremove
  fi

}

#######################################
# Uninstall one or more Python packages using pip2 or pip3.
# Checks which packages are actually installed before attempting removal.
# Only removes packages that are currently installed.
# Automatically confirms uninstallation with -y flag.
# 
# Use case examples:
#   # Remove Python 3 packages
#   pip_uninstall 3 "requests" "flask" "django"
#   
#   # Remove Python 2 packages (if pip2 is available)
#   pip_uninstall 2 "virtualenv" "setuptools"
#   
#   # Remove a single Python 3 package
#   pip_uninstall 3 "numpy"
#
# Globals:
#   None
# Arguments:
#   1 - VERSION: Python version (2 for pip2, 3 for pip3)
#   ... - PACKAGES: One or more pip package names to remove
# Returns:
#   None
#######################################
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

    # shellcheck disable=SC2086
    $pip uninstall $installed -y
    return
  fi

  echo "... not installed!"

}

#######################################
# Uninstall one or more Python packages using pip2 or pip3 with administrative privileges.
# Same as pip_uninstall but uses sudo for packages installed system-wide.
# Checks which packages are actually installed before attempting removal.
# Only removes packages that are currently installed.
# Automatically confirms uninstallation with -y flag.
# 
# Use case examples:
#   # Remove system-wide Python 3 packages
#   sudo_pip_uninstall 3 "ansible" "awscli"
#   
#   # Remove system-wide Python 2 packages
#   sudo_pip_uninstall 2 "virtualenv"
#   
#   # Remove globally installed development tools
#   sudo_pip_uninstall 3 "pytest" "pylint" "black"
#
# Globals:
#   None
# Arguments:
#   1 - VERSION: Python version (2 for pip2, 3 for pip3)
#   ... - PACKAGES: One or more pip package names to remove
# Returns:
#   None
#######################################
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

    # shellcheck disable=SC2086
    sudo $pip uninstall $installed -y
    return
  fi

  echo "... not installed!"

}

#######################################
# Safely remove Microsoft GPG key from APT trusted keys if no Microsoft packages are installed.
# Checks if any Microsoft packages (azure-cli, code, dotnet, powershell) are still installed.
# Only removes the GPG key if none of these packages are present.
# Prevents breaking package verification for remaining Microsoft packages.
# 
# Use case examples:
#   # After uninstalling VS Code
#   safe_rem_microsoftgpg
#   
#   # After uninstalling all Microsoft tools
#   safe_rem_microsoftgpg
#   
#   # Called as part of Microsoft package uninstallation scripts
#   safe_rem_microsoftgpg
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
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

#######################################
# Safely remove Microsoft APT source list if no Microsoft packages requiring it are installed.
# Checks if any packages from Microsoft repo (dotnet, powershell) are still installed.
# Only removes the source list if none of these packages are present.
# Prevents breaking package updates for remaining Microsoft packages.
# 
# Use case examples:
#   # After uninstalling PowerShell
#   safe_rem_microsoftsrc
#   
#   # After uninstalling .NET SDK
#   safe_rem_microsoftsrc
#   
#   # Called as part of Microsoft package uninstallation scripts
#   safe_rem_microsoftsrc
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
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

#######################################
# Safely remove Debian stable APT source list if no packages requiring it are installed.
# Checks if any packages from Debian stable repo (code, dotnet, powershell) are still installed.
# Only removes the source list if none of these packages are present.
# Prevents breaking package updates for remaining packages from Debian stable.
# 
# Use case examples:
#   # After uninstalling VS Code installed from Debian stable
#   safe_rem_debianstablesrc
#   
#   # After uninstalling all packages from Debian stable
#   safe_rem_debianstablesrc
#   
#   # Called as part of package uninstallation scripts
#   safe_rem_debianstablesrc
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
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
