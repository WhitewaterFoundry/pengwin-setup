#!/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "HiDPI" --yesno "Would you like to configure Qt and GTK for HiDPI displays?" 8 85) then
  echo "Installing HiDPI"
  scale_factor=$(wslsys -S -s)

  sudo tee "/etc/profile.d/hidpi.sh" <<EOF
#!/bin/sh

scale_factor=${scale_factor}

if [ -z "\${VCXSRV}" ]; then
  #VCXSRV automatically sets the right dpi value and it conflicts with this
  export QT_SCALE_FACTOR=\${scale_factor}
fi

# shellcheck disable=SC2155
export GDK_SCALE=\$(echo "(\${scale_factor} + 0.49) / 1" | bc) #Round
# shellcheck disable=SC2155
export GDK_DPI_SCALE=\$(echo "\${scale_factor} / \${GDK_SCALE}" | bc -l)

if [ "\$(echo "\${scale_factor} >= 2" | bc -l)" -eq 1 ]; then
  export XCURSOR_SIZE=64
elif [ "\$(echo "\${scale_factor} >= 1.5" | bc -l)" -eq 1 ]; then
  export XCURSOR_SIZE=32
else
  export XCURSOR_SIZE=16
fi

unset scale_factor

EOF

  # add_fish_support 'hidpi' # not working with bass

  message --title "HiDPI" --msgbox "HiDPI has been adjusted to $(echo "${scale_factor} * 100 / 1" | bc)%. If you change your resolution run this option again to update your Linux applications." 10 80

  unset scale_factor
  touch "${HOME}"/.should-restart

else
  echo "Skipping HiDPI"
fi
