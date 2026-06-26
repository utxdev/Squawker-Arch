#!/bin/bash
set -Eeuo pipefail

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[+]${NC} $*"; }
ok()    { echo -e "${GREEN}[✓]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; }

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          Squawker-Arch Dependency Installer${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

if ! command -v pacman >/dev/null 2>&1; then
    error "This script requires pacman and is intended for Arch Linux."
    exit 1
fi

# TryHackMe Squawker VPN runtime & installation dependencies
DEPENDENCIES=(
    "libarchive"
    "gtk3"
    "libayatana-appindicator"
)

info "Checking for required dependencies..."

MISSING=()
for dep in "${DEPENDENCIES[@]}"; do
    if ! pacman -Qi "$dep" >/dev/null 2>&1; then
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    ok "All dependencies are already installed!"
    exit 0
fi

info "The following dependencies need to be installed:"
for dep in "${MISSING[@]}"; do
    echo -e "  ${YELLOW}•${NC} $dep"
done
echo

info "Requesting sudo privileges to install packages..."
sudo pacman -S --needed "${MISSING[@]}"

echo
ok "Dependencies installed successfully! You can now run ./install.sh"
