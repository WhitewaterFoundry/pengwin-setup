#!/bin/bash

source $(dirname "$0")/uninstall-common.sh

function main()
{

echo "Uninstall fcitx non-latin input modifications"

echo "Removing fcitx environment variable modifications..."
sudo_rem_file "/etc/profile.d/fcitx"
sudo_rem_file "/etc/profile.d/fcitx.sh"

echo "Removing fcitx packages..."
remove_package "fcitx-sunpinyin" "fcitx-libpinyin" "fcitx-rime" "fcitx-googlepinyin" "fcitx-chewing" "fcitx-mozc" "fcitx-kkc" "fcitx-kkc-dev" "fcitx-hangul" "fcitx-unikey" "fcitx-sayura" "fcitx-table" "fcitx-table-all"

}

if show_warning "fcitx improved non-latin input" "$@" ; then
	main "$@"
fi
