#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#Imported from common.sh
declare HOME

readonly PENGWIN_SHELL_INTEGRATION_MARKER='### PENGWIN WINDOWS TERMINAL SHELL INTEGRATION'

#######################################
# Install Windows Terminal shell integration to ~/.bashrc
# Adds shell integration sequences for better terminal experience
# with marks for easy uninstallation
# Globals:
#   HOME
#   PENGWIN_SHELL_INTEGRATION_MARKER
# Arguments:
#   None
#######################################
function install_shell_integration() {
  echo "Installing Windows Terminal shell integration to ~/.bashrc"

  local bashrc="${HOME}/.bashrc"

  if [[ ! -f "${bashrc}" ]]; then
    touch "${bashrc}"
  fi

  # Check if already installed
  if grep -q "${PENGWIN_SHELL_INTEGRATION_MARKER}" "${bashrc}" 2>/dev/null; then
    echo "Previous Pengwin Windows Terminal shell integration detected. Cancelling install..."
    message --title "Warning!" --msgbox "Previous install of Windows Terminal shell integration detected. To reinstall, please run the uninstaller first or manually edit \"${bashrc}\" and remove all text between (and including) the lines:\n${PENGWIN_SHELL_INTEGRATION_MARKER}" 10 95
    return 1
  fi

  # Add shell integration to .bashrc
  # Based on: https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration
  # and https://github.com/WhitewaterFoundry/pengwin-enterprise-rootfs-builds/blob/main/linux_files/bash-prompt-wsl.sh
  cat >>"${bashrc}" <<EOF
${PENGWIN_SHELL_INTEGRATION_MARKER}
# Windows Terminal shell integration
# See: https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration
# Also supports WezTerm which implements the same OSC sequences
if [[ "\${TERM_PROGRAM}" == "WezTerm" || -n "\${WT_SESSION}" ]]; then
  __wt_osc() { printf '\e]%s\e\\' "\$1"; }

  __wt_mark_prompt_start() { __wt_osc '133;A'; }
  __wt_mark_command_start() { __wt_osc '133;B'; }
  __wt_mark_command_executed() { __wt_osc "133;C;\$1"; }
  __wt_mark_command_finished() { __wt_osc "133;D;\$1"; }
  __wt_set_cwd() { __wt_osc "9;9;\${PWD}"; }

  __wt_update_prompt() {
    local last_exit_code="\$?"
    __wt_mark_command_finished "\${last_exit_code}"
    __wt_set_cwd
    __wt_mark_prompt_start
    PS1="\${__wt_original_ps1}"
    return "\${last_exit_code}"
  }

  if [[ -z "\${__wt_original_ps1}" ]]; then
    __wt_original_ps1="\${PS1}"
    PROMPT_COMMAND="__wt_update_prompt\${PROMPT_COMMAND:+;}\${PROMPT_COMMAND}"
    PS1="\[\$(__wt_mark_command_start)\]\${PS1}"
    # PS0 is executed after reading a command but before executing it
    PS0='\[\$(__wt_mark_command_executed)\]'
  fi
fi
${PENGWIN_SHELL_INTEGRATION_MARKER}

EOF

  echo "Windows Terminal shell integration installed successfully."
  message --title "Shell Integration Installed" --msgbox "Windows Terminal shell integration has been installed to ${bashrc}.\n\nPlease close and re-open your terminal or run 'source ~/.bashrc' to apply the changes.\n\nThis provides:\n- Command marks for scroll-to-command\n- Current working directory tracking\n- Command exit status reporting" 14 80
}

if (confirm --title "Windows Terminal Shell Integration" --yesno "Would you like to install Windows Terminal shell integration?\n\nThis adds special escape sequences to your bash prompt that enable:\n- Scroll to command feature in Windows Terminal\n- Current working directory tracking\n- Command exit status tracking\n\nThe changes will be added to ~/.bashrc with markers for easy removal." 15 80); then
  install_shell_integration
else
  echo "Skipping Windows Terminal shell integration"
fi
