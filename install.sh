#!/bin/bash

set -e

DEB_FILE="squawker-vpn_1.0.0_amd64.deb"

clear

echo "========================================================="
echo "              SQUAWKER VPN ARCH INSTALLER"
echo "========================================================="
echo
echo "                 Made by Artix"
echo "           https://utkarsh.xaenithra.com"
echo
echo "========================================================="
echo

# Verify package exists
if [ ! -f "$DEB_FILE" ]; then
    echo "[ERROR] $DEB_FILE not found."
    echo
    echo "Place the Squawker VPN .deb package in this folder."
    exit 1
fi

echo "[1/8] Installing dependencies..."

sudo pacman -Sy --needed \
    dpkg \
    libarchive \
    gtk3 \
    webkit2gtk

echo
echo "[2/8] Preparing workspace..."

rm -rf /tmp/squawker-install
mkdir -p /tmp/squawker-install

echo
echo "[3/8] Extracting package..."

bsdtar -xf "$DEB_FILE" -C /tmp/squawker-install

cd /tmp/squawker-install

if [ ! -f data.tar.gz ]; then
    echo
    echo "[ERROR] Invalid Squawker VPN package."
    exit 1
fi

tar -xzf data.tar.gz

echo
echo "[4/8] Installing application files..."

sudo rm -rf /opt/squawker-vpn
sudo mkdir -p /opt/squawker-vpn

sudo cp -r usr/lib/squawker-vpn/* /opt/squawker-vpn/

echo
echo "[5/8] Creating executable..."

sudo install -Dm755 \
    usr/bin/squawker-vpn \
    /usr/local/bin/squawker-vpn

echo
echo "[6/8] Creating application launcher..."

mkdir -p ~/.local/share/applications

cp usr/share/applications/squawker-vpn.desktop \
   ~/.local/share/applications/

echo
echo "[7/8] Installing icon..."

mkdir -p ~/.local/share/icons/hicolor/128x128/apps

cp usr/share/icons/hicolor/128x128/apps/squawker-vpn.png \
   ~/.local/share/icons/hicolor/128x128/apps/

sed -i \
's|^Icon=.*|Icon=/home/'"$USER"'/.local/share/icons/hicolor/128x128/apps/squawker-vpn.png|' \
~/.local/share/applications/squawker-vpn.desktop

echo
echo "[8/8] Refreshing desktop cache..."

kbuildsycoca6 >/dev/null 2>&1 || true

echo
echo "[+] Cleaning temporary files..."

rm -rf /tmp/squawker-install

echo
echo "========================================================="
echo "                  INSTALLATION SUCCESSFUL"
echo "========================================================="
echo
echo "You can now launch Squawker VPN using:"
echo
echo "  • KDE Application Launcher"
echo "  • Command: squawker-vpn"
echo
echo "Need help?"
echo "Visit: https://utkarsh.xaenithra.com"
echo
echo "Made by Artix"
echo "========================================================="
