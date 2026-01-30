#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

readonly EDIT_GITHUB_API_URL="https://api.github.com/repos/microsoft/edit/releases/latest"
readonly EDIT_INSTALL_DEST="/usr/local/bin/edit"

function msedit_install() {
  if (confirm --title "Microsoft Edit" --yesno "Would you like to download and install Microsoft Edit?" 8 70); then
    echo "Installing Microsoft Edit"
    install_packages jq zstd libicu-dev

    createtmp

    local arch
    case "$(dpkg --print-architecture)" in
      amd64) arch="x86_64" ;;
      arm64) arch="aarch64" ;;
      *) echo "Unsupported architecture"; cleantmp; return 1 ;;
    esac

    echo "Fetching latest release information"
    local asset_url
    asset_url=$(curl -sSL "${EDIT_GITHUB_API_URL}" | \
      jq -r --arg arch "$arch" '.assets[] | select(.name | test("^edit-.*-" + $arch + "-linux-gnu\\.tar\\.zst$")) | .browser_download_url' | head -n 1)

    if [[ -z "${asset_url}" ]]; then
      echo "No suitable asset found for ${arch}"
      cleantmp
      return 1
    fi

    echo "Downloading asset"
    curl -L "${asset_url}" -o edit.tar.zst

    echo "Extracting archive"
    unzstd -c edit.tar.zst | tar -xf -

    local edit_path
    edit_path=$(find . -type f -name edit -perm -111 | head -n 1)
    if [[ -z "${edit_path}" ]]; then
      echo "edit binary not found inside archive."
      cleantmp
      return 1
    fi

    echo "Installing to ${EDIT_INSTALL_DEST}"
    sudo install -Dm755 "${edit_path}" "${EDIT_INSTALL_DEST}"

    echo "Registering with update-alternatives"
    sudo update-alternatives --install /usr/bin/editor editor "${EDIT_INSTALL_DEST}" 30

    cleantmp
  else
    echo "Skipping Microsoft Edit"
  fi
}

msedit_install "$@"
