#!/bin/bash

source "/usr/local/wlinux-setup.d/common.sh"

function Inputrc {
echo "Installing optimised inputrc commands to /etc/inputrc"

if [[ ! -f "/etc/inputrc" ]] ; then
	sudo touch /etc/inputrc
fi

cat /etc/inputrc | while read line
do
	if [[ $line == *"### WLINUX OPTIMISED DEFAULTS"* ]] ; then
		return 1
	fi
done

if [[ $? == 1 ]] ; then
    # While loop found previous customizations
    echo "Previous wlinux inputrc customizations detected. Cancelling install..."
    whiptail --title "Warning!" --msgbox "Previous install of wlinux inputrc customizations detected. To reinstall, please edit \"/etc/inputrc\" with your favourite text editor and remove all of the text between (and including) the lines $WLINUX_STRING" 15 95
    return
fi

# Write Carlos' custom inputrc to global inputrc (see: https://github.com/crramirez/shellprefs/blob/master/.inputrc)
sudo tee -a /etc/inputrc << EOF
### WLINUX OPTIMISED DEFAULTS
# Don't ring bell on completion
set bell-style none

# Filename completion/expansion
set completion-ignore-case on
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Append / to all dirnames
set mark-directories on

# Mark symlinked directories
set mark-symlinked-directories On

# Do not match hidden files
set match-hidden-files off

# Color files by type
set colored-stats On
# Append char to indicate type
set visible-stats On
# Color the common prefix
set colored-completion-prefix On
# Color the common prefix in menu-complete
set menu-complete-display-prefix On

\"\e[A\": history-search-backward
\"\e[B\": history-search-forward

\$if Bash
  # Magic Space
  # Insert a space character then performs
  # a history expansion in the line
  Space: magic-space
\$endif
### WLINUX OPTIMISED DEFAULTS
EOF

whiptail --title "Further customizations" --msgbox "To make further customizations you may either edit the global inputrc preferences under \"/etc/inputrc\", or for user-specific preferences edit \"~/.inputrc\" with the text editor of your choice." 16 95
}

if (whiptail --title "Inputrc Customizations" --yesno "Would you like to install input optimizations to the global inputrc (\"/etc/inputrc\")? Please bear in mind that while bash reads this script on start, other shells like zsh and fish do not." 15 95) ; then
	Inputrc
fi
