#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# check if x410 exists
if [ -x "$(command -v x410.exe)" ]; then
  if (confirm --title "X410" --yesno "It seems that X410 is already installed on your machine. Would you like to start it every time that Pengwin launches?" 10 80) then
    echo "Configuring X410 to start on Pengwin launch"
    sudo bash -c 'cat > /etc/profile.d/02-x410.sh' << EOF
#!/bin/sh

(cmd-exe /c x410.exe /wm &> /dev/null &)

export X410=yes

EOF
    #add_fish_support '02-x410'

    #Make sure that DISPLAY points to the internal IP address
    mkdir -p "${HOME}/.config/pengwin"
    touch "${HOME}/.config/pengwin/display_ip_from_dns"

    # Avoid collision with the other XServer
    sudo rm -f /etc/profile.d/01-vcxsrv.sh
    sudo rm -f "${__fish_sysconf_dir:=/etc/fish/conf.d}/01-vcxsrv.fish"

    touch "${HOME}"/.should-restart

  else
    echo "Skipping X410"
  fi
else
  if (confirm --title "X410" --yesno "It seems that X410 is not installed on your machine. Would you like to view a link to X410 (recommended) on the Microsoft Store?" 10 80) then
    echo "Running $ wslview <link>"
    wslview 'ms-windows-store://pdp/?PRODUCTID=9nlp712zmn9q&cid=pengwin-setup'
  else
    echo "Skipping X410"
  fi
fi
