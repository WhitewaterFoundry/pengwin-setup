#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# Imported from common.sh
declare SetupDir

function main() {

  # shellcheck disable=SC2155,SC2086
  local menu_choice=$(

    menu --title "AI Menu" "${DIALOG_TYPE}" "Install AI tools and assistants\n[ENTER to confirm]:" 14 87 2 \
      "COPILOT-CLI" "Install GitHub Copilot CLI" ${OFF} \
      "COPILOT-VIM" "Install GitHub Copilot for Vim/Neovim (requires Node.js 18+)" ${OFF}

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  local exit_status=0

  if [[ ${menu_choice} == *"COPILOT-CLI"* ]]; then
    echo "COPILOT-CLI"
    bash "${SetupDir}"/copilot-cli.sh "$@"
    exit_status=$?
  fi

  if [[ ${menu_choice} == *"COPILOT-VIM"* ]]; then
    echo "COPILOT-VIM"
    bash "${SetupDir}"/copilot-vim.sh "$@"
    exit_status=$?
  fi

  if [[ ${exit_status} != 0 && ! ${NON_INTERACTIVE} ]]; then
    local status
    main "$@"
    status=$?
    return ${status}
  fi
}

main "$@"
