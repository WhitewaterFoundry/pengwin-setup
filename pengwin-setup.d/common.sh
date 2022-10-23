#!/bin/bash

declare -a -x CMD_MENU_OPTIONS

export LANG=en_US.utf8
export NEWT_COLORS='
    root=lightgray,black
    roottext=lightgray,black
    shadow=black,gray
    title=magenta,lightgray
    actcheckbox=lightgray,magenta
    emptyscale=lightgray,blue
    fullscale=lightgray,magenta
    button=lightgray,magenta
    actbutton=magenta,lightgray
    compactbutton=magenta,lightgray
'

readonly PENGWIN_SETUP_TITLE="Pengwin Setup"

declare WSL2
# shellcheck disable=SC2155
declare -i -r WSLG=3

if [[ "${WSL2}" == "${WSLG}" ]]; then
  readonly REQUIRES_X="             "
else
  readonly REQUIRES_X=" (requires X)"
fi

declare -i -x PROGRESS_STATUS

#######################################
# description
# Globals:
#   CMD_MENU_OPTIONS
#   JUST_UPDATE
#   NON_INTERACTIVE
#   SKIP_CONFIMATIONS
#   SKIP_STARTMENU
#   SKIP_UPDATES
# Arguments:
#  None
#######################################
function process_arguments() {
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
        shift
        ;;
      uninstall | remove)
        echo "Automatically uninstall without prompts or updates"
        export SKIP_UPDATES=1
        export NON_INTERACTIVE=1
        export SKIP_CONFIMATIONS=1
        export SKIP_STARTMENU=1
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
        CMD_MENU_OPTIONS+=("$1")
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
  echo 'Saving current directory as $CURDIR'
  CURDIR=$(pwd)
  TMPDIR=$(mktemp -d)
  echo "Going to \$TMPDIR: $TMPDIR"
  # shellcheck disable=SC2164
  cd "$TMPDIR"
}

#######################################
# description
# Globals:
#   CURDIR
#   TMPDIR
# Arguments:
#  None
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
# description
# Arguments:
#   1
#   2
# Returns:
#   0 ...
#   1 ...
#   2 ...
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
# description
# Globals:
#   SKIP_CONFIMATIONS
# Arguments:
#  None
# Returns:
#   $? ...
#   0 ...
#######################################
function confirm() {

  if [[ ! ${SKIP_CONFIMATIONS} ]]; then

    whiptail --backtitle "${PENGWIN_SETUP_TITLE}" "$@"

    return $?
  else
    return 0
  fi
}

#######################################
# description
# Globals:
#   NON_INTERACTIVE
# Arguments:
#  None
# Returns:
#   $? ...
#   0 ...
#######################################
function message() {

  if [[ ! ${NON_INTERACTIVE} ]]; then

    whiptail --backtitle "${PENGWIN_SETUP_TITLE}" "$@"

    return $?
  else
    return 0
  fi
}

#######################################
# Display a menu using whiptail. Echo the option key or CANCELLED if the user has cancelled
# Globals:
#   CANCELLED
# Arguments:
#   None
# Returns:
#   None
#######################################
function menu() {

  local menu_choice #Splitted to preserve exit code

  if [[ ${#CMD_MENU_OPTIONS[*]} == 0 ]]; then
    menu_choice=$(whiptail --backtitle "${PENGWIN_SETUP_TITLE}" "$@" 3>&1 1>&2 2>&3)
  else
    menu_choice="${CMD_MENU_OPTIONS[*]}"
  fi

  local exit_status=$?

  if [[ ${exit_status} != 0 ]]; then
    echo "${CANCELLED}"
    return
  fi

  if [[ -z ${menu_choice} ]]; then

    if (whiptail --backtitle "${PENGWIN_SETUP_TITLE}" --title "None Selected" --yesno "No item selected. Would you like to return to the menu?" 8 60 3>&1 1>&2 2>&3); then
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
# description
# Globals:
#   CANCELLED
#   GOVERSION
#   SetupDir
#   WIN_CUR_VER
#   wHome
#   wHomeWinPath
# Arguments:
#  None
#######################################
function setup_env() {

  if (! command -v cmd.exe >/dev/null); then
    whiptail --backtitle "${PENGWIN_SETUP_TITLE}" --title "An environment problem was found" --msgbox "The Windows PATH is not available, and pengwin-setup requires it to run. Please check that: \n\n   pengwin-setup is not running with sudo.\n   pengwin-setup wasn't run with the root user.\n   appendWindowsPath is true in /etc/wsl.conf file or is not defined. \n\n\nIf you don't want to have Windows PATH in Pengwin, enable it temporally to run pengwin-setup" 15 100

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

  SetupDir="/usr/local/pengwin-setup.d"
  export SetupDir

  readonly GOVERSION="1.15.8"
  export GOVERSION

}

#######################################
# description
# Arguments:
#  None
#######################################
function install_packages() {

  sudo apt-get install -y -q "$@"
}

#######################################
# description
# Globals:
#   NON_INTERACTIVE
# Arguments:
#  None
#######################################
function update_packages() {

  if [[ ${NON_INTERACTIVE} ]]; then
    sudo apt-get update -y -q "$@"
  else
    sudo --preserve-env=NEWT_COLORS debconf-apt-progress -- apt-get update -y "$@"
  fi
}

#######################################
# description
# Arguments:
#  None
#######################################
function upgrade_packages() {

  sudo apt-get upgrade -y -q "$@"
}

#######################################
# description
# Globals:
#   __fish_sysconf_dir
# Arguments:
#   1
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
# description
# Globals:
#   PROGRESS_STATUS
# Arguments:
#  None
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

setup_env "$@"
