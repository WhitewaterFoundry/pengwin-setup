#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

# check if x410 exists
if [ -x "$(command -v x410.exe)" ]; then
  if (confirm --title "X410" --yesno "It seems that X410 is already installed on your machine. Would you like to start it every time that Pengwin launches?" 10 80) then
    echo "Configuring X410 to start on Pengwin launch"
    sudo bash -c 'cat > /etc/profile.d/02-x410.sh' << EOF
#!/bin/bash

if [ -n "\${WSL2}" ]; then
  (cmd-exe /c x410.exe /wm /public &> /dev/null &)
else
  (cmd-exe /c x410.exe /wm &> /dev/null &)
fi

EOF
    # Avoid collision with the other XServer
    sudo rm -f /etc/profile.d/01-vcxsrv.sh
    touch "${HOME}"/.should-restart

  else
    echo "Skipping X410"
  fi
else
  if (confirm --title "X410" --yesno "It seems that X410 is not installed on your machine. Would you like to view a link to X410 (recommended) on the Microsoft Store?" 10 80) then
    echo "Running $ wslview <link>"
    wslview https://afflnk.microsoft.com/c/1291904/433017/7593?u=https%3A%2F%2Fwww.microsoft.com%2Fen-us%2Fp%2Fx410%2F9nlp712zmn9q%23activetab%3Dpivot%3Aoverviewtab
  else
    echo "Skipping X410"
  fi
fi
