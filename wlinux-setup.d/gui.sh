#!/bin/bash

source $(dirname "$0")/common.sh "$@"

whiptail --title "Note about GUI Apps" --msgbox "Use of GUI applications on WLinux requires an X server running on Windows 10.\n\nExamples include:\n\nX410\nVcXsrv\nXming" 15 60

if (whiptail --title "X410" --yesno "Would you like to view a link to X410 (recommended) on the Microsoft Store?" 8 80) then
    echo "Running $ wslview <link>"
    wslview https://afflnk.microsoft.com/c/1291904/433017/7593?u=https%3A%2F%2Fwww.microsoft.com%2Fen-us%2Fp%2Fx410%2F9nlp712zmn9q%23activetab%3Dpivot%3Aoverviewtab
else
    echo "Skipping X410"
fi

if (whiptail --title "GUI Libraries" --yesno "Would you like to install a base set of libraries for GUI applications?" 8 75) then
    echo "Installing GUILIB"
    echo "$ apt-get install xclip gnome-themes-standard gtk2-engines-murrine dbus dbus-x11 -y"
    sudo apt-get install xclip gnome-themes-standard gtk2-engines-murrine dbus dbus-x11 -y
    echo "Configuring dbus if you already had it installed. If not, you might see some errors, and that is okay."
    #stretch
    sudo touch /etc/dbus-1/session.conf
    sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /etc/dbus-1/session.conf
    sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /etc/dbus-1/session.conf
    sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /etc/dbus-1/session.conf
    #sid
    sudo touch /usr/share/dbus-1/session.conf
    sudo sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /usr/share/dbus-1/session.conf
    sudo sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /usr/share/dbus-1/session.conf
else
    echo "Skipping GUILIB"
fi


if (whiptail --title "Windows 10 Theme" --yesno "Would you like to install a Windows 10 theme? (including lxappearance, a GUI application to set the theme)" 8 70) then
	echo "Installing Windows 10 theme"
    # Source files locations
    W10LIGHT_URL="https://github.com/B00merang-Project/Windows-10/archive/master.zip"
    W10DARK_URL="https://github.com/B00merang-Project/Windows-10-Dark/archive/master.zip"
    INSTALLDIR="/usr/share/themes"
    LIGHTDIR="windows-10-light"
    DARKDIR="windows-10-dark"

    echo "$ sudo apt-get install unzip -y"
    sudo apt-get install unzip -y

    # Download themes to temporary folder (sub folders for light & dark) then unzip
    echo "Downloading themes to temporary folder"
    createtmp

    wget ${W10LIGHT_URL} -O master-light.zip -q --show-progress
    echo "Unzipping master-light.zip..."
    unzip -qq master-light.zip

    wget ${W10DARK_URL} -O master-dark.zip -q --show-progress
    echo "Unzipping master-dark.zip..."
    unzip -qq master-dark.zip

    if [[ ! -d "${INSTALLDIR}" ]] ; then
    	echo "${INSTALLDIR} does not exist, creating"
    	sudo mkdir -p $INSTALLDIR
    fi

    if [[ -d "${INSTALLDIR}/${LIGHTDIR}" ]] ; then
    	echo "${INSTALLDIR}/${LIGHTDIR} already exists, removing old"
    	sudo rm -r $INSTALLDIR/$LIGHTDIR
    fi

    if [[ -d "${INSTALLDIR}/${DARKDIR}" ]] ; then
    	echo "${INSTALLDIR}/${DARKDIR} already exists, removing old"
    	sudo rm -r $INSTALLDIR/$DARKDIR
    fi

    # Move to themes folder
    echo "Moving themes to ${INSTALLDIR}"
    sudo mv Windows-10-master "${INSTALLDIR}/${LIGHTDIR}"
    sudo mv Windows-10-Dark-master "${INSTALLDIR}/${DARKDIR}"

    # Set correct permissions
    echo "Setting correct theme folder permissions"
    sudo chown -R root:root "${INSTALLDIR}/${LIGHTDIR}"
    sudo chown -R root:root "${INSTALLDIR}/${DARKDIR}"
    sudo chmod -R 0755 "${INSTALLDIR}/${LIGHTDIR}"
    sudo chmod -R 0755 "${INSTALLDIR}/${DARKDIR}"

    # Install lxappearance to let user set theme
    sudo apt-get install -q -y lxappearance

    # Cleanup
    cleantmp

    whiptail --title "How to set Windows 10 theme" --msgbox "To set the either of the Windows 10 light/dark themes:\nRun 'lxappearance', choose from the list of installed themes and click apply. You may change the theme in this way at anytime, including fonts and cursors." 9 90
else
    echo "Skipping Windows 10 theme install"
fi

if (whiptail --title "fcitx" --yesno "Would you like to install fcitx for improved non-Latin input?" 8 65) then
    echo "Installing fcitx"

    echo "sudo apt-get install fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11 -y"
    sudo apt-get install fcitx fonts-noto-cjk fonts-noto-color-emoji dbus-x11 -y

    FCCHOICE=$(whiptail --title "fcitx engines" --checklist --separate-output "Select fcitx engine:" 15 65 8 \
    "sunpinyin" "Chinese sunpinyin" off \
    "libpinyin" "Chinese libpinyin" off \
    "rime" "Chinese rime" off \
    "googlepinyin" "Chinese googlepinyin" off \
    "chewing" "Chinese chewing" off \
    "mozc" "Japanese mozc" on \
    "kkc" "Japanese kkc" off \
    "hangul" "Korean hangul" off \
    "unikey" "Vietnamese unikey" off \
    "sayura" "Sinhalese sayura" off \
    "table" "Tables (Includes all available tables)" off 3>&1 1>&2 2>&3
)

    if [[ $FCCHOICE == *"sunpinyin"* ]] ; then
        sudo apt-get install fcitx-sunpinyin -y
    fi

    if [[ $FCCHOICE == *"libpinyin"* ]] ; then
        sudo apt-get install fcitx-libpinyin -y
    fi

    if [[ $FCCHOICE == *"rime"* ]] ; then
        sudo apt-get install fcitx-rime -y
    fi

    if [[ $FCCHOICE == *"googlepinyin"* ]] ; then
        sudo apt-get install fcitx-googlepinyin -y
    fi

    if [[ $FCCHOICE == *"chewing"* ]] ; then
        sudo apt-get install fcitx-chewing -y
    fi

    if [[ $FCCHOICE == *"mozc"* ]] ; then
        sudo apt-get install fcitx-mozc -y
    fi

    if [[ $FCCHOICE == *"kkc"* ]] ; then
        sudo apt-get install fcitx-kkc fcitx-kkc-dev -y
    fi

    if [[ $FCCHOICE == *"hangul"* ]] ; then
        sudo apt-get install fcitx-hangul -y
    fi

    if [[ $FCCHOICE == *"unikey"* ]] ; then
        sudo apt-get install fcitx-unikey -y
    fi

    if [[ $FCCHOICE == *"sayura"* ]] ; then
        sudo apt-get install fcitx-sayura -y
    fi

    if [[ $FCCHOICE == *"tables"* ]] ; then
        sudo apt-get install fcitx-table fcitx-table-all -y
    fi

    echo "Setting environmental variables"
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    export DefaultIMModule=fcitx

    echo "Saving environmental variables to /etc/profile.d/fcitx.sh"
    sudo sh -c 'echo "#!/bin/bash" >> /etc/profile.d/fcitx.sh'
    sudo sh -c 'echo "export QT_IM_MODULE=fcitx" >> /etc/profile.d/fcitx.sh'
    sudo sh -c 'echo "export GTK_IM_MODULE=fcitx" >> /etc/profile.d/fcitx.sh'
    sudo sh -c 'echo "export XMODIFIERS=@im=fcitx" >> /etc/profile.d/fcitx.sh'
    sudo sh -c 'echo "export DefaultIMModule=fcitx" >> /etc/profile.d/fcitx.sh'

    if (whiptail --title "fcitx-autostart" --yesno "Would you like fcitx-autostart to run each time you open WLinux? WARNING: Requires an X server to be running or it will generate errors." 8 70) then
        echo "Placing fcitx-autostart in /etc/profile.d/fcitx"
        sudo sh -c 'echo "fcitx-autostart &>/dev/null" >> /etc/profile.d/fcitx'
    else
        echo "Skipping fcitx-autostart"
        whiptail --title "Note about fcitx-autostart" --msgbox "You will need to run $ fcitx-autostart to enable fcitx before running GUI apps." 8 85
    fi

    echo "Configuring dbus machine id"
    sudo sh -c "dbus-uuidgen > /var/lib/dbus/machine-id"

    if (whiptail --title "fcitx-autostart" --yesno "Would you like to run fcitx-autostart now? Requires an X server to be running." 8 85) then
        echo "Starting fcitx-autostart"
        fcitx-autostart
    else
        echo "Skipping fcitx-config-gtk3"
    fi
   
    if (whiptail --title "fcitx-config-gtk3" --yesno "Would you like to configure fcitx now? Requires an X server to be running." 8 80) then
        echo "Running fcitx-config-gtk3"
        fcitx-config-gtk3
    else
        echo "Skipping fcitx-config-gtk3"
    fi

    whiptail --title "Note about fcitx-config-gtk3" --msgbox "You can configure fcitx later by running $ fcitx-config-gtk3" 8 70

else
    echo "Skipping fcitx"
fi

if (whiptail --title "HiDPI" --yesno "Would you like to configure Qt and GDK for HiDPI displays? (Experimental)" 8 85) then
    echo "Installing HiDPI"
    export QT_SCALE_FACTOR=2
    export GDK_SCALE=2
    sudo sh -c 'echo "#!/bin/bash" >> /etc/profile.d/hidpi.sh'
    sudo sh -c 'echo "export QT_SCALE_FACTOR=2" >> /etc/profile.d/hidpi.sh'
    sudo sh -c 'echo "export GDK_SCALE=2" >> /etc/profile.d/hidpi.sh'
else
    echo "Skipping HiDPI"
fi
