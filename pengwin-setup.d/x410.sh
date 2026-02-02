#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# check if x410 exists
if [ -x "$(command -v x410.exe)" ]; then
  if (confirm --title "X410" --yesno "It seems that X410 is already installed on your machine. Would you like to start it every time that Pengwin launches?" 10 80) then
    echo "Configuring X410 to start on Pengwin launch"

    connection=

    for arg in "$@"; do
      case "$arg" in
        VSOCK)
          connection=VSOCK
          ;;
        TCP)
          connection=TCP
          ;;
      esac
    done

    if [[ -z ${connection} ]]; then
      connection=$(menu --title "X410" --radiolist "Select how Pengwin connects to X410" 10 60 2 \
        "TCP" "Use a TCP/IP connection" \
        "VSOCK" "Use a VSOCK connection" 3>&1 1>&2 2>&3)

      if [[ ${connection} == "${CANCELLED}" ]]; then
        echo "Skipping X410"
        exit 0
      fi
    fi

    if [[ ${connection} == VSOCK ]]; then
      sudo bash -c 'cat > /etc/profile.d/02-x410.sh' << EOP
#!/bin/sh

(cmd-exe /c x410.exe /wm /vsock &> /dev/null &)

export X410=yes

EOP
    else
      sudo bash -c 'cat > /etc/profile.d/02-x410.sh' << EOP
#!/bin/sh

if [ -n "\${WSL2}" ]; then
  (cmd-exe /c x410.exe /wm /public &> /dev/null &)
else
  (cmd-exe /c x410.exe /wm &> /dev/null &)
fi

export X410=yes

EOP
    fi

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
