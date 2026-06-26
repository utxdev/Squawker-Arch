#!/bin/bash
set -Eeuo pipefail

VERSION="1.3"
PACKAGE_VERSION="1.0.0"
DEB_FILE="squawker-vpn_${PACKAGE_VERSION}_amd64.deb"
DEB_URL="https://squawker-vpn.vm.tryhackme.com/latest/${DEB_FILE}"
APP_NAME="Squawker-Arch"
APP_BIN="squawker-vpn"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

need_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        error "sudo is required to install dependencies and application files."
        echo
        warn "Run this installer as root or install sudo first: sudo ./install.sh"
        exit 1
    fi

    if ! sudo -v >/dev/null 2>&1; then
        error "Unable to obtain sudo privileges."
        echo
        warn "Run this installer with sudo or as root: sudo ./install.sh"
        exit 1
    fi
}

banner

detect_platform() {
    if command -v pacman >/dev/null 2>&1; then
        PKG_BACKEND="arch"
    elif command -v apt-get >/dev/null 2>&1 || command -v apt >/dev/null 2>&1 || command -v dpkg >/dev/null 2>&1; then
        PKG_BACKEND="deb"
    else
        error "Unsupported distribution: could not detect a supported package manager."
        exit 1
    fi
}

detect_platform
if [ "$PKG_BACKEND" = "arch" ]; then
    info "Detected Arch-based distribution."
else
    info "Detected Debian-based distribution."
fi

# Package download
if [ ! -f "$DEB_FILE" ]; then
    info "Downloading $DEB_FILE from $DEB_URL..."
    if ! command -v curl >/dev/null 2>&1; then
        error "curl is not installed."
        exit 1
    fi
    curl -L -o "$DEB_FILE" "$DEB_URL"
fi

# Install package dependencies
if [ "$PKG_BACKEND" = "arch" ]; then
    if [ -x "$SCRIPT_DIR/install-deps.sh" ]; then
        echo
        info "Checking sudo privileges before installing dependencies..."
        need_sudo
        info "Installing package dependencies..."
        sudo "$SCRIPT_DIR/install-deps.sh"
    else
        warn "Dependency installer not found: $SCRIPT_DIR/install-deps.sh"
        warn "Install dependencies manually or place install-deps.sh in the same folder."
    fi
fi

# Sudo upfront
if [ "$PKG_BACKEND" = "arch" ]; then
    info "Checking sudo access..."
    sudo -v
fi

echo
info "Checking required tools..."

required_tools=()
if [ "$PKG_BACKEND" = "arch" ]; then
    required_tools=(bsdtar tar)
else
    required_tools=(dpkg)
fi

for cmd in "${required_tools[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error "$cmd is not installed."
        exit 1
    fi
done

ok "Required tools found."

if [ "$PKG_BACKEND" = "deb" ]; then
    echo
    info "Installing Debian package directly..."
    need_sudo
    sudo dpkg -i "$DEB_FILE" || true

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -f -y
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install -f -y
    fi

    echo
    info "Refreshing desktop cache..."
    kbuildsycoca6 >/dev/null 2>&1 || true
    gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

    echo
    ok "Squawker VPN installed successfully."

    echo
    echo -e "${WHITE}Launch:${NC}"
    echo "  • Application menu"
    echo "  • Command: squawker-vpn"

    echo
    echo -e "${GREEN}Developer:${NC} Utkarsh (Artix)"
    echo -e "${BLUE}Website:${NC} utkarsh.xaenithra.com"

    echo
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}                Thanks for using Squawker-Arch${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
fi

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

if [ -f "$WORKDIR/control.tar.gz" ]; then
    info "Extracting control metadata..."
    mkdir -p "$WORKDIR/control"
    tar -xzf "$WORKDIR/control.tar.gz" -C "$WORKDIR/control"
fi

echo
info "Installing Squawker files..."
sudo rm -rf /usr/lib/squawker-vpn
sudo cp -r "$WORKDIR/usr/lib/" /usr/lib/

if [ -d "$WORKDIR/lib" ]; then
    info "Installing system files..."
    sudo cp -r "$WORKDIR/lib/" /lib/
fi

echo
info "Installing executable..."
sudo install -Dm755 "$WORKDIR/usr/bin/$APP_BIN" "/usr/bin/$APP_BIN"

echo
info "Installing desktop launcher and icons..."
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/share/icons/hicolor"

desktop_file="$HOME/.local/share/applications/squawker-vpn.desktop"
cp "$WORKDIR/usr/share/applications/squawker-vpn.desktop" "$desktop_file"

cp -r "$WORKDIR/usr/share/icons/hicolor/." "$HOME/.local/share/icons/hicolor/"

sed -i 's|^Icon=.*|Icon=squawker-vpn|' "$desktop_file"
if grep -q '^Terminal=' "$desktop_file"; then
    sed -i 's|^Terminal=.*|Terminal=false|' "$desktop_file"
else
    printf 'Terminal=false\n' >> "$desktop_file"
fi

if ! grep -q '^Categories=' "$desktop_file"; then
    printf 'Categories=Network;VPN;Application;\n' >> "$desktop_file"
fi

if command -v xdg-desktop-menu >/dev/null 2>&1; then
    info "Registering the application in the desktop menu..."
    xdg-desktop-menu install --mode user "$desktop_file" >/dev/null 2>&1 || true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

echo
info "Refreshing desktop cache..."
kbuildsycoca6 >/dev/null 2>&1 || true
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

if [ -x "$WORKDIR/control/postinst" ]; then
    echo
    info "Running post-install script..."
    sudo sh "$WORKDIR/control/postinst"
fi

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
