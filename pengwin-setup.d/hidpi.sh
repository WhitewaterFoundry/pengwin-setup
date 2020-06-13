#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "HiDPI" --yesno "Would you like to configure Qt and GDK for HiDPI displays? (Experimental)" 8 85) then
	echo "Installing HiDPI"
	scale_factor=$(wslsys -S -s)
	scale_factor_int=$(IFS='.' read -r -a splitted <<< "${scale_factor}"; echo -n "${splitted[0]}")

	sudo sh -c 'echo "#!/bin/bash" > /etc/profile.d/hidpi.sh'
	sudo sh -c "echo \"export QT_SCALE_FACTOR=${scale_factor}\" >> /etc/profile.d/hidpi.sh"

	if [[ "${scale_factor}" == "${scale_factor_int}" ]]; then
  	sudo sh -c "echo \"export GDK_SCALE=${scale_factor_int}\" >> /etc/profile.d/hidpi.sh"
	else
  	sudo sh -c "echo \"export GDK_SCALE=1\" >> /etc/profile.d/hidpi.sh"
  	sudo sh -c "echo \"export GDK_DPI_SCALE=${scale_factor}\" >> /etc/profile.d/hidpi.sh"
	fi

	unset scale_factor
	unset scale_factor_int
else
	echo "Skipping HiDPI"
fi
