#!/bin/bash

# shellcheck source=/usr/local/pengwin-setup.d/common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "HiDPI" --yesno "Would you like to configure Qt and GDK for HiDPI displays? (Experimental)" 8 85) then
	echo "Installing HiDPI"
	scale_factor=$(wslsys -S -s)
	QT_SCALE_FACTOR=${scale_factor}
	scale_factor_int=$(IFS='.' read -r -a splitted <<< "${scale_factor}"; echo -n "${splitted[0]}")
	GDK_SCALE=${scale_factor_int}

	sudo sh -c 'echo "#!/bin/bash" > /etc/profile.d/hidpi.sh'
	sudo sh -c "echo \"export QT_SCALE_FACTOR=${QT_SCALE_FACTOR}\" >> /etc/profile.d/hidpi.sh"
	sudo sh -c "echo \"export GDK_SCALE=${GDK_SCALE}\" >> /etc/profile.d/hidpi.sh"

	unset scale_factor
	unset QT_SCALE_FACTOR
	unset GDK_SCALE
else
	echo "Skipping HiDPI"
fi
