#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.sh
declare HOME

readonly PENGWIN_SHELL_INTEGRATION_MARKER='### PENGWIN WINDOWS TERMINAL SHELL INTEGRATION'
readonly SHELL_INTEGRATION_DIR='/usr/local/share/pengwin'
readonly SHELL_INTEGRATION_SCRIPT="${SHELL_INTEGRATION_DIR}/wt-shell-integration.sh"

#######################################
# Install Windows Terminal shell integration
# Installs script to /usr/local/share/pengwin and adds source line to ~/.bashrc
# Globals:
#   HOME
#   PENGWIN_SHELL_INTEGRATION_MARKER
#   SHELL_INTEGRATION_DIR
#   SHELL_INTEGRATION_SCRIPT
# Arguments:
#   None
#######################################
function install_shell_integration() {
  echo "Installing Windows Terminal shell integration"

  local bashrc="${HOME}/.bashrc"

  if [[ ! -f "${bashrc}" ]]; then
    touch "${bashrc}"
  fi

  # Check if already installed
  if grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}" 2>/dev/null; then
    echo "Previous Pengwin Windows Terminal shell integration detected. Cancelling install..."
    message --title "Warning!" --msgbox "Previous install of Windows Terminal shell integration detected. To reinstall, please run the uninstaller first or manually edit \"${bashrc}\" and remove the lines between:\n${PENGWIN_SHELL_INTEGRATION_MARKER}" 10 95
    return 1
  fi

  # Create the directory if it doesn't exist
  sudo mkdir -p "${SHELL_INTEGRATION_DIR}"

  # Install shell integration script
  # Based on: https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration
  sudo tee "${SHELL_INTEGRATION_SCRIPT}" >/dev/null <<'SCRIPT_EOF'
#!/bin/bash
# Windows Terminal shell integration
# See: https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration
# Also supports WezTerm which implements the same OSC sequences

# Only run for bash in Windows Terminal or WezTerm
if [[ -z "${BASH_VERSION}" ]]; then
  return 0
fi

if [[ "${TERM_PROGRAM}" == "WezTerm" || -n "${WT_SESSION}" ]]; then
  __wt_osc() { printf '\e]%s\e\\' "$1"; }

  __wt_mark_prompt_start() { __wt_osc '133;A'; }
  __wt_mark_command_start() { __wt_osc '133;B'; }
  __wt_mark_command_executed() { __wt_osc '133;C'; }
  __wt_mark_command_finished() { __wt_osc "133;D;$1"; }
  __wt_set_cwd() { __wt_osc "9;9;${PWD}"; }

  __wt_update_prompt() {
    local last_exit_code="$?"
    __wt_mark_command_finished "${last_exit_code}"
    __wt_set_cwd
    __wt_mark_prompt_start
    PS1="${__wt_original_ps1}"
    return "${last_exit_code}"
  }

  if [[ -z "${__wt_original_ps1}" ]]; then
    __wt_original_ps1="${PS1}"
    PROMPT_COMMAND="__wt_update_prompt${PROMPT_COMMAND:+;}${PROMPT_COMMAND}"
    PS1="\[\$(__wt_mark_command_start)\]${PS1}"
    # PS0 is executed after reading a command but before executing it
    PS0='\[\$(__wt_mark_command_executed)\]'
  fi
fi
SCRIPT_EOF

  # Add minimal source line to .bashrc (since PS1 modifications need to happen after .bashrc sets PS1)
  cat >>"${bashrc}" <<EOF
${PENGWIN_SHELL_INTEGRATION_MARKER}
# Source Windows Terminal shell integration (needs to run after PS1 is set)
[[ -f "${SHELL_INTEGRATION_SCRIPT}" ]] && source "${SHELL_INTEGRATION_SCRIPT}"
${PENGWIN_SHELL_INTEGRATION_MARKER}
EOF

  echo "Windows Terminal shell integration installed successfully."
  enable_should_restart
  message --title "Shell Integration Installed" --msgbox "Windows Terminal shell integration has been installed.\n\nScript location: ${SHELL_INTEGRATION_SCRIPT}\nSource added to: ${bashrc}\n\nPlease close and re-open Pengwin to apply the changes.\n\nThis provides:\n- Command marks for scroll-to-command\n- Current working directory tracking\n- Command exit status reporting" 16 80
}

if (confirm --title "Windows Terminal Shell Integration" --yesno "Would you like to install Windows Terminal shell integration?\n\nThis adds special escape sequences to your bash prompt that enable:\n- Scroll to command feature in Windows Terminal\n- Current working directory tracking\n- Command exit status tracking\n\nThe changes will be added to ~/.bashrc with markers for easy removal." 15 80); then
  install_shell_integration
else
  echo "Skipping Windows Terminal shell integration"
fi
