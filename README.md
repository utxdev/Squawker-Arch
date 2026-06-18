# 🦅 Squawker-Arch

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Arch%20Linux-blue?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux" />
  <img src="https://img.shields.io/badge/Client-TryHackMe%20Squawker%20VPN-red?style=for-the-badge" alt="TryHackMe" />
</p>

---

**Squawker-Arch** is a lightweight, reliable, and automated installer script to run the official **TryHackMe Squawker VPN client** natively on **Arch Linux**.

Normally, TryHackMe only packages and distributes the new Squawker VPN client (Beta) as a Debian (`.deb`) package. This repository bridges that gap, allowing Arch Linux power-users to seamlessly install and run the official client on their system.

---

## ⚡ Bypassing the 60-Minute AttackBox Limit

If you are a free TryHackMe user, you are probably familiar with this limit:

<p align="center">
  <img src="assets/attackbox_limit.png" alt="TryHackMe 60-minute limit" width="700"/>
</p>

> [!IMPORTANT]
> **Why use Squawker VPN?**
> Free users are restricted to **60 minutes per day** of in-browser **AttackBox** access. By installing Squawker VPN on your local Arch machine, you can connect directly to TryHackMe's network. This allows you to use your own local tools and environment for **unlimited hours** entirely for free!

---

## 🚀 Features

- **Automated Dependency Handling**: Checks and installs all required dependencies (`dpkg`, `libarchive`, `gtk3`, `webkit2gtk`) via `pacman`.
- **Clean File Extraction**: Unpacks the official deb package and structures it cleanly inside `/opt/squawker-vpn`.
- **System Integration**:
  - Adds `squawker-vpn` directly to your executable path (`/usr/local/bin/`).
  - Sets up a Desktop Entry (`.desktop` launcher) under `~/.local/share/applications/` so you can launch it via your preferred App Launcher (KDE Application Launcher, Rofi, dmenu, GNOME Shell, etc.).
  - Configures the desktop icon path dynamically based on your system user.
- **Zero Litter**: Cleans up all temporary installation folders automatically post-install.

---

## 📦 Installation Guide

Since the official `squawker-vpn_1.0.0_amd64.deb` package is already pre-included directly in this repository, installing it is extremely simple:

### 1. Clone the Repository
Clone this repository to your local machine and navigate into the folder:
```bash
git clone https://github.com/utxdev/Squawker-Arch.git
cd Squawker-Arch
```

### 2. Install Dependencies
Make the dependency script executable and run it. This safely ensures you have all required packages (`libarchive`, `gtk3`, `webkit2gtk`) without breaking your system:
```bash
chmod +x install-deps.sh
./install-deps.sh
```

### 3. Run the Installer
Make the main installer script executable and run it to install Squawker VPN:
```bash
chmod +x install.sh
./install.sh
```

---

## 🛠️ Usage

After a successful installation, you can launch Squawker VPN in two ways:

1. **Application Launcher**: Search for `Squawker VPN` in your desktop environment's app launcher.
2. **Terminal**: Run the command directly:
   ```bash
   squawker-vpn
   ```

---

## ⚙️ How It Works (Under the Hood)

The installation script performs the following tasks:
1. **Syncs Pacman** and ensures package compatibility.
2. **Creates a workspace** under `/tmp/squawker-install`.
3. **Extracts** the deb file payload (specifically the `data.tar.gz`).
4. **Copies** the core files to `/opt/squawker-vpn/`.
5. **Configures the launcher** desktop file with the absolute path to the app icon in your home directory (`~/.local/share/icons/`).
6. **Refreshes the application menu cache** so you don't need to log out and back in to see the app.

---

## 🛡️ License & Credits

- **Made by**: Artix ([utkarsh.xaenithra.com](https://utkarsh.xaenithra.com))
- **Disclaimer**: This is a community-driven installation helper. All rights to the Squawker VPN client belong to TryHackMe.
