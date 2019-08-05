#!/bin/bash

source $(dirname "$0")/common.sh "$@"

if (whiptail --title "HiDPI" --yesno "Would you like to configure Qt and GDK for HiDPI displays? (Experimental)" 8 85) then
	echo "Installing HiDPI"
	export QT_SCALE_FACTOR=2
	export GDK_SCALE=2
	export GDK_DPI_SCALE=0.5
	sudo sh -c 'echo "#!/bin/bash" >> /etc/profile.d/hidpi.sh'
	sudo sh -c 'echo "export QT_SCALE_FACTOR=2" >> /etc/profile.d/hidpi.sh'
	sudo sh -c 'echo "export GDK_SCALE=2" >> /etc/profile.d/hidpi.sh'
	sudo sh -c 'echo "export GDK_DPI_SCALE=0.5" >> /etc/profile.d/hidpi.sh'
else
	echo "Skipping HiDPI"
fi
