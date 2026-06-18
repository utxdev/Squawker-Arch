#!/bin/bash
set -Eeuo pipefail

VERSION="1.3"
DEB_FILE="squawker-vpn_1.0.0_amd64.deb"
APP_NAME="Squawker-Arch"
APP_BIN="squawker-vpn"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

WORKDIR="$(mktemp -d /tmp/squawker-install.XXXXXX)"

cleanup() {
    rm -rf "$WORKDIR"
}
trap cleanup EXIT

banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
   _____                      __                 
  / ___/____  ____ _____  ____/ /___  _________ _
  \__ \/ __ \/ __ `/ __ \/ __  / __ \/ ___/ __ `/
 ___/ / /_/ / /_/ / / / / /_/ / /_/ / /  / /_/ / 
/____/\____/\__,_/_/ /_/\__,_/\____/_/   \__,_/  
EOF
    echo -e "${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}                 ${APP_NAME} Installer${NC}"
    echo -e "${YELLOW}                      Version ${VERSION}${NC}"
    echo -e "${GREEN}                Made by Artix${NC}"
    echo -e "${BLUE}             utkarsh.xaenithra.com${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

info()  { echo -e "${CYAN}[+]${NC} $*"; }
ok()    { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; }

banner

# Arch check
if ! command -v pacman >/dev/null 2>&1; then
    error "This installer only supports Arch-based distributions."
    exit 1
fi

# Package check
if [ ! -f "$DEB_FILE" ]; then
    error "$DEB_FILE not found in this folder."
    echo
    warn "Place the Squawker VPN .deb file next to this script and run it again."
    exit 1
fi

# Sudo upfront
info "Checking sudo access..."
sudo -v

echo
info "Checking required tools..."

for cmd in bsdtar tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error "$cmd is not installed."
        exit 1
    fi
done

ok "Required tools found."

echo
info "Preparing workspace..."
mkdir -p "$WORKDIR"

echo
info "Extracting .deb package..."
bsdtar -xf "$DEB_FILE" -C "$WORKDIR"

if [ ! -f "$WORKDIR/data.tar.gz" ]; then
    error "Invalid package: data.tar.gz not found."
    exit 1
fi

info "Unpacking application payload..."
tar -xzf "$WORKDIR/data.tar.gz" -C "$WORKDIR"

echo
info "Installing Squawker files..."
sudo rm -rf /usr/lib/squawker-vpn
sudo mkdir -p /usr/lib/squawker-vpn
sudo cp -a "$WORKDIR/usr/lib/squawker-vpn/." /usr/lib/squawker-vpn/

echo
info "Installing executable..."
sudo install -Dm755 "$WORKDIR/usr/bin/$APP_BIN" "/usr/local/bin/$APP_BIN"

echo
info "Installing desktop launcher..."
mkdir -p "$HOME/.local/share/applications"

cp "$WORKDIR/usr/share/applications/squawker-vpn.desktop" \
   "$HOME/.local/share/applications/squawker-vpn.desktop"

echo
info "Installing icon..."
mkdir -p "$HOME/.local/share/icons/hicolor/128x128/apps"

cp "$WORKDIR/usr/share/icons/hicolor/128x128/apps/squawker-vpn.png" \
   "$HOME/.local/share/icons/hicolor/128x128/apps/squawker-vpn.png"

sed -i 's|^Icon=.*|Icon=squawker-vpn|' \
    "$HOME/.local/share/applications/squawker-vpn.desktop"

echo
info "Refreshing desktop cache..."
kbuildsycoca6 >/dev/null 2>&1 || true
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

echo
ok "Squawker VPN installed successfully."

echo
echo -e "${WHITE}Launch:${NC}"
echo "  • KDE Application Launcher"
echo "  • Command: squawker-vpn"

echo
echo -e "${GREEN}Developer:${NC} Utkarsh (Artix)"
echo -e "${BLUE}Website:${NC} utkarsh.xaenithra.com"

echo
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}                Thanks for using Squawker-Arch${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
