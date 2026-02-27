#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root: sudo $0 <install|uninstall>"
  exit 1
fi

ACTION="$1"

if [[ -z "$ACTION" ]]; then
  echo "Usage: sudo $0 <install|uninstall>"
  exit 1
fi

PACKAGE_NAME="iitdelhivpn"
DEPENDENCY="libgdbuspp-dev"
REPO_LIST="/etc/apt/sources.list.d/openvpn-packages.list"
KEYRING="/etc/apt/keyrings/openvpn.asc"

install_package() {
  echo "==> Adding OpenVPN repository..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.openvpn.net/packages-repo.gpg -o "$KEYRING"

  DISTRO=$(lsb_release -c -s)
  echo "deb [signed-by=$KEYRING] https://packages.openvpn.net/openvpn3/debian $DISTRO main" \
    > "$REPO_LIST"

  echo "==> Updating APT..."
  apt update

  echo "==> Installing dependency..."
  apt install -y "$DEPENDENCY"

  echo "==> Preparing temporary working directory..."
  WORKDIR=$(mktemp -d)
  trap "rm -rf $WORKDIR" EXIT  # ensures temp dir is deleted on exit

  VERSION="v1.0.0"
  UBUNTU_VERSION=$(lsb_release -rs)
  ARCH=$(dpkg --print-architecture)
  URL="https://github.com/AaryaTalgaonkar/openvpn3-dist/releases/download/$VERSION/${PACKAGE_NAME}_${ARCH}-${UBUNTU_VERSION}.deb"

  echo "==> Downloading Release into $WORKDIR..."
  wget -O "$WORKDIR/${PACKAGE_NAME}.deb" "$URL" || { echo "Failed to download $URL"; exit 1; }

  echo "==> Installing package..."
  apt install -y "$WORKDIR/${PACKAGE_NAME}.deb"

  echo "✅ Installation complete!"
}

uninstall_package() {
  echo "==> Removing installed package..."
  apt remove --purge -y "$PACKAGE_NAME"

  echo "==> Removing dependency..."
  apt remove --purge -y "$DEPENDENCY"

  echo "==> Removing OpenVPN repository..."
  rm -f "$REPO_LIST" "$KEYRING"

  echo "==> Updating APT..."
  apt update

  echo "==> Cleaning unused packages..."
  apt autoremove --purge -y

  echo "✅ Uninstallation complete!"
}

case "$ACTION" in
  install)
    install_package
    ;;
  uninstall)
    uninstall_package
    ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Usage: sudo $0 <install|uninstall>"
    exit 1
    ;;
esac
