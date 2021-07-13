#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "Java" --yesno "Would you like to Install SDKMan to manage and install Java SDKs?" 8 52); then

  sudo apt-get install -y -q zip curl

  curl -s "https://get.sdkman.io?rcupdate=false" | bash

  sudo tee "/etc/profile.d/sdkman.sh" <<EOF
#!/bin/sh

export SDKMAN_DIR="\${HOME}/.sdkman"
if [ -s "\${HOME}/.sdkman/bin/sdkman-init.sh" ]; then

  if [ "\${SHELL}" != "/bin/sh" ]; then
    # shellcheck disable=SC1090
    . "\${HOME}/.sdkman/bin/sdkman-init.sh"
  else
    # Basic support for sh
    # shellcheck disable=SC1091
    . "/usr/local/bin/sdkman-init-sh.sh"
  fi
fi

EOF

  add_fish_support 'sdkman'

  # shellcheck disable=SC1090
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  sdk version

  curl https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/sdkman.completion.bash | sudo tee /etc/bash_completion.d/sdkman.bash

  message --title "SDKMan" --msgbox "To install Java use: \n\nsdk list java\n\nThen: \n\nsdk install java 'version'" 15 60

  touch "${HOME}"/.should-restart
else
  echo "Skipping Java"
fi
