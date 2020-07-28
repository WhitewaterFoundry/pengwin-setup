#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "HiDPI" --yesno "Would you like to configure Qt and GDK for HiDPI displays? (Experimental)" 8 85) then
  echo "Installing HiDPI"
  scale_factor=$(wslsys -S -s)

  sudo tee "/etc/profile.d/hidpi.sh" <<EOF
#!/bin/bash
export QT_SCALE_FACTOR=${scale_factor}
export GDK_SCALE=\$(echo "(\${QT_SCALE_FACTOR} + 0.49) / 1" | bc) #Round
export GDK_DPI_SCALE=\$(echo "\${QT_SCALE_FACTOR} / \${GDK_SCALE}" | bc -l)

if [ "\$(echo "\${QT_SCALE_FACTOR} >= 1.5" | bc -l)" -eq 1 ]; then
  export XCURSOR_SIZE=32
else
  export XCURSOR_SIZE=16
fi

EOF

  unset scale_factor
  
else
	echo "Skipping HiDPI"
fi
