#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

declare SetupDir
declare INSTALL_HISTORY_FILE

#######################################
# Batch install from history.
# Reads the install history file and presents a checkbox list of all
# previously installed options. The user can select which ones to reinstall.
# Each selected option is reinstalled in order. A summary of successes
# and failures is shown at the end, then the WSL instance is terminated.
# Globals:
#   INSTALL_HISTORY_FILE
#   WSL_DISTRO_NAME
#   NON_INTERACTIVE
# Arguments:
#   None
# Returns:
#   1 if no history or cancelled
#######################################
function main() {

  if [[ ! -f "${INSTALL_HISTORY_FILE}" ]] || [[ ! -s "${INSTALL_HISTORY_FILE}" ]]; then
    message --title "Batch Install" --msgbox "No install history found.\n\nInstall some packages first using pengwin-setup, and the commands will be recorded for future batch reinstallation." 10 70
    return 1
  fi

  # Read unique entries from history file
  local -a entries
  mapfile -t entries < <(awk '!seen[$0]++' "${INSTALL_HISTORY_FILE}")

  if [[ ${#entries[@]} -eq 0 ]]; then
    message --title "Batch Install" --msgbox "No install history entries found." 8 50
    return 1
  fi

  # Build dialog checklist arguments
  local -a dialog_args
  local i=1
  for entry in "${entries[@]}"; do
    dialog_args+=("${i}" "${entry}" "on")
    ((i++))
  done

  if [[ ${NON_INTERACTIVE} ]]; then
    # In non-interactive mode, install all entries
    local -a selected_indices
    for ((j = 1; j <= ${#entries[@]}; j++)); do
      selected_indices+=("${j}")
    done
  else
    # Show checklist dialog
    # shellcheck disable=SC2155
    local selection=$(
      ${DIALOG_COMMAND} --title "Batch Install from History" \
        --checklist "Select installations to replay.\nAll previously installed options are checked by default.\n[SPACE to toggle, ENTER to confirm]:" \
        0 0 0 \
        "${dialog_args[@]}" \
        3>&1 1>&2 2>&3
    )

    local exit_status=$?
    if [[ ${exit_status} -ne 0 ]] || [[ -z "${selection}" ]]; then
      return 1
    fi

    # Parse selected indices
    local -a selected_indices
    # shellcheck disable=SC2086
    read -r -a selected_indices <<< ${selection}
  fi

  # Run pengwin-setup update first
  echo "Running pengwin-setup update..."
  bash "$(dirname "$0")/../pengwin-setup" update
  local update_status=$?

  local -a succeeded
  local -a failed

  if [[ ${update_status} -ne 0 ]]; then
    echo "Warning: update returned status ${update_status}"
  fi

  # Install each selected entry
  for idx in "${selected_indices[@]}"; do
    # Remove quotes that dialog may add
    idx="${idx//\"/}"
    local entry_index=$((idx - 1))

    if [[ ${entry_index} -lt 0 ]] || [[ ${entry_index} -ge ${#entries[@]} ]]; then
      continue
    fi

    local entry="${entries[${entry_index}]}"
    echo "Installing: ${entry}"

    # shellcheck disable=SC2086
    bash "$(dirname "$0")/../pengwin-setup" install ${entry}
    local install_status=$?

    if [[ ${install_status} -eq 0 ]]; then
      succeeded+=("${entry}")
    else
      failed+=("${entry}")
    fi
  done

  # Build summary message
  local summary="Batch Install Complete\n\n"

  if [[ ${#succeeded[@]} -gt 0 ]]; then
    summary+="Succeeded:\n"
    for entry in "${succeeded[@]}"; do
      summary+="  [OK] ${entry}\n"
    done
  fi

  if [[ ${#failed[@]} -gt 0 ]]; then
    summary+="\nFailed:\n"
    for entry in "${failed[@]}"; do
      summary+="  [FAIL] ${entry}\n"
    done
  fi

  message --title "Batch Install Summary" --msgbox "${summary}" 0 0

  # Terminate WSL instance
  if [[ -n "${WSL_DISTRO_NAME}" ]]; then
    wsl.exe --terminate "${WSL_DISTRO_NAME}"
  fi
}

main "$@"
