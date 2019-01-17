#!/bin/bash

source "/usr/local/wlinux-setup.d/common.sh"

function InputRc {
WLINUX_STRING="### WLINUX OPTIMISED DEFAULTS"

echo "Installing optimised inputrc commands to /etc/inputrc"

if [[ ! -f "/etc/inputrc" ]] ; then
	sudo touch /etc/inputrc
fi

cat /etc/inputrc | while read line
do
	if [[ $line == *WLINUX_STRING ]] ; then
		echo "Previous wlinux inputrc customizations detected. Cancelling install..."
		whiptail --title "Warning!" --msgbox "Previous install of wlinux inputrc customizations detected. To reinstall, please edit \"/etc/inputrc\" with your favourite text editor and remove all of the text between (and including) the lines $WLINUX_STRING" 15 95
		return
	fi
done

# Write Carlos' custom inputrc to global inputrc (see: https://github.com/crramirez/shellprefs/blob/master/.inputrc)
echo ${WLINUX_STRING}								| sudo tee -a /etc/inputrc
echo "# Don't ring bell on completion" 				| sudo tee -a /etc/inputrc
echo "set bell-style none" 							| sudo tee -a /etc/inputrc
echo "" 											| sudo tee -a /etc/inputrc
echo "# Filename completion/expansion" 				| sudo tee -a /etc/inputrc
echo "set completion-ignore-case on" 				| sudo tee -a /etc/inputrc
echo "set show-all-if-ambiguous on" 				| sudo tee -a /etc/inputrc
echo "set show-all-if-unmodified on" 				| sudo tee -a /etc/inputrc
echo "" 											| sudo tee -a /etc/inputrc
echo "# Append "/" to all dirnames" 				| sudo tee -a /etc/inputrc
echo "set mark-directories on" 						| sudo tee -a /etc/inputrc
echo ""												| sudo tee -a /etc/inputrc
echo "# Mark symlinked directories"					| sudo tee -a /etc/inputrc
echo "set mark-symlinked-directories On"			| sudo tee -a /etc/inputrc
echo ""												| sudo tee -a /etc/inputrc
echo "# Do not match hidden files"					| sudo tee -a /etc/inputrc
echo "set match-hidden-files off"					| sudo tee -a /etc/inputrc
echo ""												| sudo tee -a /etc/inputrc
echo "# Color files by type"						| sudo tee -a /etc/inputrc
echo "set colored-stats On"							| sudo tee -a /etc/inputrc
echo "# Append char to indicate type"				| sudo tee -a /etc/inputrc
echo "set visible-stats On"							| sudo tee -a /etc/inputrc
echo "# Color the common prefix"					| sudo tee -a /etc/inputrc
echo "set colored-completion-prefix On"				| sudo tee -a /etc/inputrc
echo "# Color the common prefix in menu-complete"	| sudo tee -a /etc/inputrc
echo "set menu-complete-display-prefix On"			| sudo tee -a /etc/inputrc
echo ""												| sudo tee -a /etc/inputrc
echo "\"\e[A\": history-search-backward"			| sudo tee -a /etc/inputrc
echo "\"\e[B\": history-search-forward"				| sudo tee -a /etc/inputrc
echo ""												| sudo tee -a /etc/inputrc
echo "$if Bash"										| sudo tee -a /etc/inputrc
echo "  # 'Magic Space'"							| sudo tee -a /etc/inputrc
echo "  # Insert a space character then performs"	| sudo tee -a /etc/inputrc
echo "  # a history expansion in the line"			| sudo tee -a /etc/inputrc
echo "  Space: magic-space"							| sudo tee -a /etc/inputrc
echo "$endif"										| sudo tee -a /etc/inputrc
echo ${WLINUX_STRING}								| sudo tee -a /etc/inputrc

whiptail --title "Further customizations" --msgbox "To make further customizations you may either edit the global inputrc preferences under \"/etc/inputrc\", or for user-specific preferences edit \"~/.inputrc\" with the text editor of your choice." 16 95
}

if (whiptail --title "Inputrc Customizations" --yesno "Would you like to install input optimizations to the global inputrc (\"/etc/inputrc\")? Please bear in mind that while bash reads this script on start, other shells like zsh and fish do not." 15 95) ; then
	Inputrc
fi
