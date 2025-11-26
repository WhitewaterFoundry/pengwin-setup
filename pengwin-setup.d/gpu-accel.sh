#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

#######################################
# Main function for GPU acceleration settings
# Arguments:
#  None
# Returns:
#   1 if cancelled
#######################################
function main() {

  # shellcheck disable=SC2155
  local menu_choice=$(

    menu --title "GPU Acceleration" --radiolist "GPU Hardware Acceleration Settings\n[SPACE to select, ENTER to confirm]:" 12 85 3 \
      "GPU_ACCEL_ENABLE" 'Enable hardware acceleration (D3D12) - default  ' off \
      "GPU_ACCEL_DISABLE" 'Disable hardware acceleration (helps with driver issues) ' off

    # shellcheck disable=SC2188
    3>&1 1>&2 2>&3
  )

  echo "Selected:" "${menu_choice}"

  if [[ ${menu_choice} == "CANCELLED" ]]; then
    return 1
  fi

  if [[ ${menu_choice} == *"GPU_ACCEL_ENABLE"* ]]; then
    enable_gpu_accel
  fi

  if [[ ${menu_choice} == *"GPU_ACCEL_DISABLE"* ]]; then
    disable_gpu_accel
  fi

}

#######################################
# Enable GPU hardware acceleration (remove the disable flag)
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function enable_gpu_accel() {
  echo "Enabling GPU hardware acceleration"
  sudo rm -f /etc/profile.d/disable-gpu-accel.sh
  sudo rm -f "${__fish_sysconf_dir:=/etc/fish/conf.d}/disable-gpu-accel.fish"

  message --title "GPU Acceleration" --msgbox "GPU hardware acceleration has been enabled.\n\nThe default D3D12 acceleration from pengwin-base will now be used.\n\nPlease restart your terminal for changes to take effect." 12 70

  enable_should_restart
}

#######################################
# Disable GPU hardware acceleration by unsetting the D3D12 variables
# Globals:
#   HOME
# Arguments:
#  None
#######################################
function disable_gpu_accel() {
  echo "Disabling GPU hardware acceleration"

  sudo tee "/etc/profile.d/disable-gpu-accel.sh" <<'EOF'
#!/bin/sh

# Disable D3D12 GPU hardware acceleration
# This helps with driver issues on some systems
unset VDPAU_DRIVER
unset LIBVA_DRIVER_NAME
unset GALLIUM_DRIVER

EOF

  # Add fish shell support
  sudo mkdir -p "${__fish_sysconf_dir:=/etc/fish/conf.d}"
  sudo tee "${__fish_sysconf_dir}/disable-gpu-accel.fish" <<'EOF'
#!/bin/fish

# Disable D3D12 GPU hardware acceleration
# This helps with driver issues on some systems
set -e VDPAU_DRIVER
set -e LIBVA_DRIVER_NAME
set -e GALLIUM_DRIVER

EOF

  message --title "GPU Acceleration" --msgbox "GPU hardware acceleration has been disabled.\n\nThis will stop using D3D12 acceleration and may help with driver issues.\n\nPlease restart your terminal for changes to take effect." 12 70

  enable_should_restart
}

main "$@"
