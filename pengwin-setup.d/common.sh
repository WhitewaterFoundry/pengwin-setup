#!/bin/bash

declare -a -x CMD_MENU_OPTIONS

export LANG=en_US.utf8
export NEWT_COLORS='
    root=default,default
    roottext=default,default
    shadow=default,default
    title=magenta,lightgray
    checkbox=lightgray,blue
    actcheckbox=lightgray,magenta
    emptyscale=lightgray,blue
    fullscale=lightgray,magenta
    button=lightgray,magenta
    actbutton=magenta,lightgray
    compactbutton=magenta,lightgray
    listbox=lightgray,blue
    actlistbox=lightgray,magenta
    sellistbox=lightgray,magenta
    actsellistbox=lightgray,magenta
'

readonly PENGWIN_SETUP_TITLE="Pengwin Setup"

declare WSL2
# shellcheck disable=SC2155
declare -i -r WSLG=3

if [[ ${WSL2} == "${WSLG}" ]]; then
  readonly REQUIRES_X="             "
else
  readonly REQUIRES_X=" (requires X)"
fi

declare -i -x PROGRESS_STATUS

readonly PENGWIN_CONFIG_DIR="${HOME}/.config/pengwin"

#######################################
# Process command line arguments and set corresponding environment variables.
# Handles debug mode, confirmation skipping, update skipping, non-interactive mode,
# dialog command selection, and menu options for installation/uninstallation.
# Globals:
#   CMD_MENU_OPTIONS
#   JUST_UPDATE
#   NON_INTERACTIVE
#   SKIP_CONFIMATIONS
#   SKIP_STARTMENU
#   SKIP_UPDATES
# Arguments:
#   Command line arguments passed to the script
# Returns:
#   None
#######################################
function process_arguments() {
  export DIALOG_COMMAND='dialog' # defaults to ncurses

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --debug | -d | --verbose | -v)
      echo "Running in debug/verbose mode"
      set -x
      shift
      ;;
    -y | --yes | --assume-yes)
      echo "Skipping confirmations"
      export SKIP_CONFIMATIONS=1
      shift
      ;;
    --noupdate)
      echo "Skipping updates"
      export SKIP_UPDATES=1
      shift
      ;;
    --norebuildicons)
      echo "Skipping rebuild start menu"
      export SKIP_STARTMENU=1
      shift
      ;;
    -q | --quiet | --noninteractive)
      echo "Skipping confirmations"
      export NON_INTERACTIVE=1
      shift
      ;;
    -c | --casdial)
      echo "Use casdial instead of dialog"
      if command -v casdial; then
        export DIALOG_COMMAND='casdial'
      fi
      shift
      ;;
    -w | --whiptail)
      echo "Use whiptail instead of dialog"
      export DIALOG_COMMAND='whiptail'
      shift
      ;;
    -n | --ncurses | --dialog)
      echo "Force use dialog"
      export DIALOG_COMMAND='dialog'
      shift
      ;;
    --gdialog)
      echo "Use gdialog instead of dialog"
      export DIALOG_COMMAND='gdialog'
      shift
      ;;
    --alt)
      export DIALOGRC="${SetupDir}/dialogrc_alt"
      shift
      ;;
    --multiple)
      export DIALOG_TYPE='--checklist'
      export OFF='off'
      shift
      ;;
    --help)
      export SHOW_HELP=1
      shift
      ;;
    update | upgrade)
      echo "Just update packages"
      export JUST_UPDATE=1
      export SKIP_CONFIMATIONS=1
      shift
      ;;
    autoinstall | install)
      echo "Automatically install without prompts or updates"
      export SKIP_UPDATES=1
      export NON_INTERACTIVE=1
      export SKIP_CONFIMATIONS=1
      export SKIP_STARTMENU=1
      expectMenuOptions=1
      shift
      ;;
    uninstall | remove)
      echo "Automatically uninstall without prompts or updates"
      export SKIP_UPDATES=1
      export NON_INTERACTIVE=1
      export SKIP_CONFIMATIONS=1
      export SKIP_STARTMENU=1
      expectMenuOptions=1
      CMD_MENU_OPTIONS+=("UNINSTALL")
      shift
      ;;
    startmenu)
      echo "Regenerates the start menu"
      export SKIP_UPDATES=1
      export NON_INTERACTIVE=1
      export SKIP_CONFIMATIONS=1
      CMD_MENU_OPTIONS+=("GUI")
      CMD_MENU_OPTIONS+=("STARTMENU")
      shift
      ;;
    *)
      if [[ ${expectMenuOptions} ]]; then
        CMD_MENU_OPTIONS+=("$1")
      fi
      shift
      ;;
    esac
  done

}

#######################################
# description
# Globals:
#   CURDIR
#   TMPDIR
# Arguments:
#  None
#######################################
function createtmp() {
  echo "Saving current directory as \$CURDIR"
  CURDIR=$(pwd)
  TMPDIR=$(mktemp -d)
  echo "Going to \$TMPDIR: $TMPDIR"
  # shellcheck disable=SC2164
  cd "$TMPDIR"
}

#######################################
# Cleans up temporary directory and returns to original directory
# Removes the temporary directory and its contents using sudo
# Globals:
#   CURDIR - The original directory to return to
#   TMPDIR - The temporary directory to clean up
# Arguments:
#   None
# Returns:
#   None
#######################################
function cleantmp() {
  echo "Returning to $CURDIR"
  # shellcheck disable=SC2164
  cd "$CURDIR"
  echo "Cleaning up $TMPDIR"
  sudo rm -r $TMPDIR # need to add sudo here because git clones leave behind write-protected files
}

#######################################
# description
# Arguments:
#  None
#######################################
function updateupgrade() {
  echo "Applying available package upgrades from repositories."
  sudo apt-get upgrade -y
  echo "Removing unnecessary packages."
  sudo apt-get autoremove -y
}

#######################################
# Checks if a command exists either in PATH or at specific location
# Attempts to execute the command to verify its existence
# Arguments:
#   1 - Expected path to the executable
#   2 - Optional arguments to pass to the executable
# Returns:
#   0 - If command exists in PATH
#   1 - If command not found
#   2 - If command exists at specific location
#######################################
function command_check() {
  # Usage: command_check <EXPECTED PATH> <ARGS (if any)>
  # shellcheck disable=SC2155
  # shellcheck disable=SC2001
  local exec_name=$(echo "$1" | sed -e "s|^.*\/||g")
  if ("${exec_name}" "$2") >/dev/null 2>&1; then
    echo "Executable ${exec_name} in PATH"
    return 0
  elif ("$1" "$2") >/dev/null 2>&1; then
    echo "Executable '${exec_name}' at: $1"
    return 2
  else
    echo "Executable '${exec_name}' not found"
    return 1
  fi
}

#function getexecname {
#user_path=$(cmd-exe /c "echo %HOMEDRIVE%%HOMEPATH%" | tr -d "\r")
#wslexec_dir=$(echo $PATH | sed -e 's/:/\n/g' | grep 'Program\ Files/WindowsApps')
#execname=$(ls "${wslexec_dir}" | grep '.exe')
#echo "${execname}"
#}

#######################################
# Shows a confirmation dialog unless confirmations are skipped
# Uses the configured dialog command to display the confirmation
# Globals:
#   SKIP_CONFIMATIONS - Flag to skip confirmation dialogs
# Arguments:
#   Dialog command arguments
# Returns:
#   0 - If confirmed or skipped
#   Dialog command exit code otherwise
#######################################
function confirm() {

  if [[ ! ${SKIP_CONFIMATIONS} ]]; then

    ${DIALOG_COMMAND} "$@"

    return $?
  else
    return 0
  fi
}

#######################################
# Shows a message dialog unless in non-interactive mode
# Uses the configured dialog command to display the message
# Globals:
#   NON_INTERACTIVE - Flag for non-interactive mode
# Arguments:
#   Dialog command arguments
# Returns:
#   0 - If in non-interactive mode
#   Dialog command exit code otherwise
#######################################
function message() {

  if [[ ! ${NON_INTERACTIVE} ]]; then

    ${DIALOG_COMMAND} "$@"

    return $?
  else
    return 0
  fi
}

#######################################
# Displays a menu using the configured dialog command
# Handles menu selection, cancellation, and empty selections
# Globals:
#   CANCELLED - Value returned on menu cancellation
#   CMD_MENU_OPTIONS - Predefined menu options if any
# Arguments:
#   Dialog command arguments for menu display
# Returns:
#   Selected menu choice or CANCELLED value
#######################################
function menu() {

  local menu_choice #Split to preserve exit code

  if [[ ${#CMD_MENU_OPTIONS[*]} == 0 ]]; then
    menu_choice=$(${DIALOG_COMMAND} "$@" 3>&1 1>&2 2>&3)
  else
    menu_choice="${CMD_MENU_OPTIONS[*]}"
  fi

  local exit_status=$?

  if [[ ${exit_status} == 1 || ${exit_status} == 255 ]]; then
    echo "${CANCELLED}"
    return
  fi

  if [[ -z ${menu_choice} ]]; then

    if (${DIALOG_COMMAND} --title "None Selected" --yesno "No item selected. Would you like to return to the menu?" 8 60 3>&1 1>&2 2>&3); then
      menu "$@"

      return
    else
      local exit_status=$?
      echo ${CANCELLED}
      return
    fi
  fi

  echo "${menu_choice}"
}

#######################################
# Sets up the environment for Pengwin setup by initializing required variables and paths.
# Processes command line arguments, configures dialog settings, and validates the
# Windows environment. Also sets up various path-related variables and version information.
# Globals:
#   DIALOGOPTS
#   DIALOGRC
#   DIALOG_COMMAND
#   SetupDir
#   wHomeWinPath
#   wHome
#   CANCELLED
#   WIN_CUR_VER
#   SHORTCUTS_FOLDER
#   GOVERSION
# Arguments:
#   Command line arguments passed to the script
# Returns:
#   0 if environment setup succeeds, non-zero on failure
#######################################
function setup_env() {
  SetupDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  export SetupDir

  # bashsupport disable=BP2001
  export DIALOGOPTS="--keep-tite --erase-on-exit --ignore --backtitle \"${PENGWIN_SETUP_TITLE}\""
  export DIALOGRC="${SetupDir}/dialogrc"

  export DIALOG_COMMAND="whiptail"

  export DIALOG_TYPE='--menu'
  export OFF=''

  if (! command -v cmd.exe >/dev/null); then
    ${DIALOG_COMMAND} --title "An environment problem was found" --msgbox "The Windows PATH is not available, and pengwin-setup requires it to run. Please check that: \n\n   pengwin-setup is not running with sudo.\n   pengwin-setup wasn't run with the root user.\n   appendWindowsPath is true in /etc/wsl.conf file or is not defined. \n\n\nIf you don't want to have Windows PATH in Pengwin, enable it temporally to run pengwin-setup" 15 100

    exit 0
  fi

  process_arguments "$@"

  # shellcheck disable=SC1003,SC2262
  if (! wslpath 'C:\' >/dev/null 2>&1); then
    shopt -s expand_aliases
    alias wslpath=legacy_wslupath
  fi

  # shellcheck disable=SC2155
  readonly wHomeWinPath=$(cmd-exe /c 'echo %HOMEDRIVE%%HOMEPATH%' | tr -d '\r')
  export wHomeWinPath

  # shellcheck disable=SC2263,SC2155
  readonly wHome=$(wslpath -u "${wHomeWinPath}")
  export wHome

  readonly CANCELLED="CANCELLED"
  export CANCELLED

  # shellcheck disable=SC2155
  readonly WIN_CUR_VER="$(reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" 2>&1 | grep -E -o '([0-9]{5})' | cut -d ' ' -f 2)"
  export WIN_CUR_VER

  # bashsupport disable=BP2001
  readonly SHORTCUTS_FOLDER="Pengwin Applications"
  export SHORTCUTS_FOLDER

  readonly GOVERSION="1.19.4"
  export GOVERSION

}

#######################################
# Starts the APT package installation progress dialog.
# Initializes debconf-apt-progress to display a visual progress indicator
# for package installation operations in interactive mode. This should be
# called before a series of install_packages calls to show a unified progress
# display. Has no effect in non-interactive mode.
# Globals:
#   APT_PROGRESS_STARTED - Flag indicating if progress dialog is active
#   NON_INTERACTIVE - Flag for non-interactive mode
#   NEWT_COLORS - Terminal color configuration preserved in sudo
# Arguments:
#   None
# Returns:
#   None
#######################################
function start_apt_progress() {
  if [[ ! ${APT_PROGRESS_STARTED} ]]; then
    if [[ ! ${NON_INTERACTIVE} ]]; then
      echo sudo --preserve-env=NEWT_COLORS debconf-apt-progress --start
      echo APT_PROGRESS_STARTED=1
    fi
  fi
}

#######################################
# Installs APT packages with progress display.
# Uses apt-get to install specified packages with different progress display
# modes based on interactive/non-interactive mode. In interactive mode, uses
# debconf-apt-progress to show visual feedback. Supports custom progress ranges
# when APT_PROGRESS_FROM and APT_PROGRESS_TO environment variables are set.
# Globals:
#   NON_INTERACTIVE - Flag for non-interactive mode
#   APT_PROGRESS_FROM - Optional progress range start percentage
#   APT_PROGRESS_TO - Optional progress range end percentage
#   NEWT_COLORS - Terminal color configuration preserved in sudo
# Arguments:
#   Package names to install
# Returns:
#   None
#######################################
function install_packages() {
  if [[ ${NON_INTERACTIVE} ]]; then
    sudo --preserve-env=NEWT_COLORS apt-get install -y -q "$@"

  elif [[ ${APT_PROGRESS_STARTED} ]]; then
    if [[ -n "${APT_PROGRESS_FROM}" && -n "${APT_PROGRESS_TO}" ]]; then
      sudo --preserve-env=NEWT_COLORS debconf-apt-progress --from "${APT_PROGRESS_FROM}" --to "${APT_PROGRESS_TO}" -- apt-get install -y -q "$@"
    else
      sudo --preserve-env=NEWT_COLORS debconf-apt-progress -- apt-get install -y -q "$@"
    fi

  else
    sudo --preserve-env=NEWT_COLORS apt-get install -y -q "$@"
  fi
}

#######################################
# Ends the APT package installation progress dialog.
# Closes the debconf-apt-progress dialog if it was previously started by
# start_apt_progress. This should be called after completing a series of
# install_packages operations to properly clean up the progress display.
# Has no effect in non-interactive mode or if progress was never started.
# Globals:
#   APT_PROGRESS_STARTED - Flag indicating if progress dialog is active
#   NON_INTERACTIVE - Flag for non-interactive mode
#   NEWT_COLORS - Terminal color configuration preserved in sudo
# Arguments:
#   None
# Returns:
#   None
#######################################
function end_apt_progress() {
  if [[ ${APT_PROGRESS_STARTED} ]]; then
    if [[ ! ${NON_INTERACTIVE} ]]; then
      echo sudo --preserve-env=NEWT_COLORS debconf-apt-progress --end
      echo APT_PROGRESS_STARTED=0
    fi
  fi
}

#######################################
# Updates package lists using apt-get update
# Uses different progress display based on interactive mode
# Globals:
#   NON_INTERACTIVE - Flag for non-interactive mode
# Arguments:
#   None
# Returns:
#   None
#######################################
function update_packages() {
  if [[ ${NON_INTERACTIVE} ]]; then
    sudo apt-get update -y -q
  else
    if [[ -n "${APT_PROGRESS_FROM}" && -n "${APT_PROGRESS_TO}" ]]; then
      sudo --preserve-env=NEWT_COLORS debconf-apt-progress --from "${APT_PROGRESS_FROM}" --to "${APT_PROGRESS_TO}" -- apt-get update -y
    else
      sudo --preserve-env=NEWT_COLORS debconf-apt-progress -- apt-get update -y
    fi
  fi
}

#######################################
# Upgrades installed packages
# Runs apt-get upgrade with specified arguments
# Arguments:
#   Additional arguments for apt-get upgrade
# Returns:
#   None
#######################################
function upgrade_packages() {

  sudo apt-get upgrade -y -q "$@"
}

#######################################
# Adds fish shell support for a configuration
# Creates fish configuration file that sources bash configuration
# Globals:
#   __fish_sysconf_dir - Fish configuration directory
# Arguments:
#   1 - Name of the configuration file
# Returns:
#   None
#######################################
function add_fish_support() {
  echo "Also for fish."
  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"

  sudo tee "${__fish_sysconf_dir}/$1.fish" <<EOF
#!/bin/fish

bass source /etc/profile.d/$1.sh

EOF
}

#######################################
# Stops the indeterminate progress indicator
# Resets terminal escape sequence for progress display
# Globals:
#   PROGRESS_STATUS - Current progress indicator state
# Arguments:
#   None
# Returns:
#   None
#######################################
function start_indeterminate_progress() {

  if [[ ${PROGRESS_STATUS} == 0 || ! ${PROGRESS_STATUS} ]]; then
    echo -n -e '\033]9;4;3;100\033\\'

    PROGRESS_STATUS=3
  fi

}

#######################################
# description
# Globals:
#   PROGRESS_STATUS
# Arguments:
#  None
#######################################
function stop_indeterminate_progress() {

  if [[ ${PROGRESS_STATUS} != 0 ]]; then
    echo -n -e '\033]9;4;0;100\033\\'

    PROGRESS_STATUS=0
  fi

}

#######################################
# Creates a flag file to indicate Pengwin should restart
# Creates .should-restart file in user's home directory
# Globals:
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   None
#######################################
function enable_should_restart() {
  touch "${HOME}"/.should-restart
}

#######################################
# Creates the Pengwin configuration directory
# Creates directory structure for Pengwin configuration files
# Globals:
#   PENGWIN_CONFIG_DIR - Path to Pengwin configuration directory
# Arguments:
#   None
# Returns:
#   None
#######################################
function setup_pengwin_config() {
  mkdir -p "${PENGWIN_CONFIG_DIR}"
}

#######################################
# Check if N version manager is installed
# Checks for N_PREFIX environment variable and n binary
# Globals:
#   N_PREFIX - N version manager prefix directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 if N is installed, 1 otherwise
#######################################
function is_n_installed() {
  # Source the profile script if it exists but N_PREFIX is not set
  if [[ -z "${N_PREFIX}" ]] && [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/n-prefix.sh"
  fi

  # Check if N_PREFIX is set and n binary exists
  if [[ -n "${N_PREFIX}" ]] && [[ -x "${N_PREFIX}/bin/n" ]]; then
    return 0
  fi

  # Also check default location
  if [[ -x "${HOME}/n/bin/n" ]]; then
    return 0
  fi

  return 1
}

#######################################
# Check if NVM (Node Version Manager) is installed
# Checks for NVM_DIR environment variable and nvm function/script
# Globals:
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 if NVM is installed, 1 otherwise
#######################################
function is_nvm_installed() {
  # Source the profile script if it exists but NVM_DIR is not set
  if [[ -z "${NVM_DIR}" ]] && [[ -f "/etc/profile.d/nvm-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/nvm-prefix.sh"
  fi

  # Check if NVM_DIR is set and nvm.sh exists
  if [[ -n "${NVM_DIR}" ]] && [[ -s "${NVM_DIR}/nvm.sh" ]]; then
    return 0
  fi

  # Also check default location
  if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
    return 0
  fi

  return 1
}

#######################################
# Install or upgrade Node.js using N version manager
# Installs N version manager and latest Node.js version
# Globals:
#   SetupDir - Directory containing setup scripts
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_nodejs_via_n() {
  export SKIP_YARN=1
  bash "${SetupDir}"/nodejs.sh install PROGRAMMING NODEJS NVERMAN
  local status=$?
  unset SKIP_YARN

  if [[ ${status} != 0 ]]; then
    return "${status}"
  fi

  # Refresh the command hash table to recognize newly installed binaries
  hash -r

  # Source the N profile to get the updated PATH
  if [[ -f "/etc/profile.d/n-prefix.sh" ]]; then
    # shellcheck source=/dev/null
    source "/etc/profile.d/n-prefix.sh"
  fi

  return 0
}

#######################################
# Install or upgrade Node.js using NVM version manager (requires NVM preinstalled)
# Installs latest Node.js version via NVM (using 'node' alias which points to latest)
# In NVM, 'nvm install node' installs/upgrades to the latest available version
# Note: This function assumes NVM is already installed and available in ${NVM_DIR}
#   or ${HOME}/.nvm; it does not install NVM itself.
# Globals:
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function install_nodejs_via_nvm() {
  # Ensure NVM is loaded
  local nvm_dir="${NVM_DIR:-${HOME}/.nvm}"

  if [[ -s "${nvm_dir}/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    source "${nvm_dir}/nvm.sh"
  else
    echo "NVM not found at ${nvm_dir}"
    return 1
  fi

  # 'node' is an NVM alias for the latest Node.js version
  echo "Installing latest Node.js via NVM..."
  if ! nvm install node --latest-npm; then
    echo "Failed to install Node.js via NVM"
    return 1
  fi

  # Refresh the command hash table to recognize newly installed binaries
  hash -r

  return 0
}

#######################################
# Upgrade Node.js using the installed version manager
# Detects which version manager is installed (N or NVM) and uses it to upgrade
# Globals:
#   N_PREFIX - N version manager prefix directory
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on failure
#######################################
function upgrade_nodejs_via_version_manager() {
  # Check which version manager is installed and use it
  if is_n_installed; then
    echo "Upgrading Node.js via N version manager..."
    install_nodejs_via_n
    return $?
  elif is_nvm_installed; then
    echo "Upgrading Node.js via NVM..."
    install_nodejs_via_nvm
    return $?
  else
    echo "No version manager detected"
    return 1
  fi
}

#######################################
# Ensure Node.js meets minimum version requirement
# Checks if Node.js is installed via a version manager (N or NVM) and meets
# minimum version. If Node.js is installed via package manager but no version
# manager, installs N version manager to avoid npm permission issues.
# Globals:
#   N_PREFIX - N version manager prefix directory
#   NVM_DIR - NVM installation directory
#   HOME - User's home directory
# Arguments:
#   $1: minimum required version (e.g., 18)
#   $2: product name for error messages (e.g., "GitHub Copilot")
# Returns:
#   0 on success, non-zero on failure
#######################################
function ensure_nodejs_version() {
  local min_version="$1"
  local product_name="$2"
  local has_version_manager=false
  local node_version

  # Check if a version manager is installed (N or NVM)
  if is_n_installed || is_nvm_installed; then
    has_version_manager=true
    echo "Node.js version manager detected."
  fi

  # Check if Node.js is available
  if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js via N version manager..."
    if ! install_nodejs_via_n; then
      echo "Failed to install Node.js. Cannot proceed with ${product_name} installation."
      return 1
    fi
    return 0
  fi

  # Node.js exists - extract and validate version
  node_version=$(node --version 2>/dev/null | sed 's/^v//' | cut -d'.' -f1)

  # Validate that node_version is a valid integer
  if ! [[ "${node_version}" =~ ^[0-9]+$ ]]; then
    echo "Error: Unable to determine Node.js version. Got: '${node_version}'"
    echo "Please check your Node.js installation."
    return 1
  fi

  # Check version first to avoid prompting about version manager if version is already sufficient
  if [[ ${node_version} -ge ${min_version} ]]; then
    # Version is sufficient
    if [[ "${has_version_manager}" == false ]]; then
      # Node.js is installed via package manager but version is sufficient
      # Offer to install version manager to avoid potential npm permission issues
      echo "Node.js version ${node_version} meets requirements, but no version manager detected."
      echo "Installing via package manager can cause npm permission issues."

      if (confirm --title "Install Node.js Version Manager" --yesno "Node.js is installed via package manager, which can cause npm permission issues for plugins like ${product_name}.\n\nWould you like to install the N version manager to manage Node.js properly?\n\nNote: This will install Node.js in your home directory." 14 80); then
        echo "Installing N version manager..."
        if ! install_nodejs_via_n; then
          echo "Failed to install N version manager. Continuing with system Node.js."
        fi
      else
        echo "Continuing with system Node.js installation."
      fi
    fi
    return 0
  fi

  # Version is insufficient - need to upgrade
  echo "Node.js version ${node_version} is below required version ${min_version}."

  if [[ "${has_version_manager}" == true ]]; then
    # Version manager installed, offer to upgrade via it
    if (confirm --title "Node.js Upgrade" --yesno "Your Node.js version (${node_version}) is below the required version (${min_version}).\n\nWould you like to upgrade Node.js using the version manager?" 10 80); then
      echo "Upgrading Node.js..."
      if ! upgrade_nodejs_via_version_manager; then
        echo "Failed to upgrade Node.js. Cannot proceed with ${product_name} installation."
        return 1
      fi
    else
      echo "Skipping ${product_name} installation due to incompatible Node.js version."
      return 1
    fi
  else
    # No version manager, offer to install N version manager
    if (confirm --title "Node.js Upgrade" --yesno "Your Node.js version (${node_version}) is below the required version (${min_version}).\n\nWould you like to install the N version manager and upgrade Node.js?\n\nNote: This is recommended to avoid npm permission issues." 12 80); then
      echo "Installing N version manager and upgrading Node.js..."
      if ! install_nodejs_via_n; then
        echo "Failed to upgrade Node.js. Cannot proceed with ${product_name} installation."
        return 1
      fi
    else
      echo "Skipping ${product_name} installation due to incompatible Node.js version."
      return 1
    fi
  fi

  return 0
}

#######################################
# Check if systemd is running as PID 1
# Detects if the system was booted with systemd by checking if PID 1 is systemd
# This function is used by installer scripts to determine whether to use systemctl
# or traditional service commands.
#
# Note: Startup scripts in /etc/profile.d cannot source common.sh (requires WSL environment),
# so they use inline detection: [ "$(ps -p 1 -o comm= 2>/dev/null)" = "systemd" ]
#
# Arguments:
#   None
# Returns:
#   0 if systemd is running as PID 1, 1 otherwise
#######################################
function is_systemd_running() {
  local init_process
  init_process=$(ps -p 1 -o comm= 2>/dev/null || echo "")

  if [[ "${init_process}" == "systemd" ]]; then
    return 0
  else
    return 1
  fi
}

setup_env "$@"
