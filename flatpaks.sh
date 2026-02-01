#!/bin/bash

figlet -f smslant "Flatpaks"

if [ -d ./airootfs/var/lib/flatpak ]; then
    sudo rm -rf ./airootfs/var/lib/flatpak
fi

# 1. Configuration
# We use realpath to ensure these are absolute paths
PROFILE_DIR=$(realpath "./airootfs")
PUBLIC_KEY=$(realpath "$HOME/ml4w-apps-public-key.asc")

# 2. Backup current Flatpak environment variables
OLD_SYSTEM_DIR="$FLATPAK_SYSTEM_DIR"
OLD_CONFIG_DIR="$FLATPAK_CONFIG_DIR"
OLD_DBUS="$DBUS_SYSTEM_BUS_ADDRESS"

# 3. Redirect Flatpak and disable D-Bus (forces local file writing)
export FLATPAK_SYSTEM_DIR="$PROFILE_DIR/var/lib/flatpak"
export FLATPAK_CONFIG_DIR="$PROFILE_DIR/etc/flatpak"
export DBUS_SYSTEM_BUS_ADDRESS=""

echo ":: Staging Flatpaks in: $PROFILE_DIR"

# Ensure directories exist
mkdir -p "$FLATPAK_SYSTEM_DIR" "$FLATPAK_CONFIG_DIR"

# 4. Add Remotes
echo ":: Adding remotes..."

# Adding Flathub
sudo -E flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Adding ML4W Repo
if [ -f "$PUBLIC_KEY" ]; then
    sudo -E flatpak remote-add --system --if-not-exists ml4w-repo https://mylinuxforwork.github.io/ml4w-flatpak-repo/ml4w-apps.flatpakrepo --gpg-import="$PUBLIC_KEY"
else
    echo "Warning: GPG key not found. Adding repo without it..."
    sudo -E flatpak remote-add --system --if-not-exists ml4w-repo https://mylinuxforwork.github.io/ml4w-flatpak-repo/ml4w-apps.flatpakrepo
fi

# 5. Install the apps
ML4W_APPS=(
    "com.ml4w.welcome"
    "com.ml4w.settings"
    "com.ml4w.calendar"
    "com.ml4w.sidebar"
    "com.ml4w.hyprlandsettings"
)

echo ":: Installing ML4W Apps..."
for app in "${ML4W_APPS[@]}"; do
    echo "   --> Installing $app"
    # Note: We use --system to match our FLATPAK_SYSTEM_DIR
    sudo -E flatpak install --system ml4w-repo "$app" -y --noninteractive
done

APPS=(
    "com.ml4w.dotfilesinstaller"
)

echo ":: Installing ML4W Apps..."
for app in "${APPS[@]}"; do
    echo "   --> Installing $app"
    # Note: We use --system to match our FLATPAK_SYSTEM_DIR
    sudo -E flatpak install --system "$app" -y --noninteractive
done

# 6. Restore environment variables
echo ":: Cleaning up environment variables..."
export FLATPAK_SYSTEM_DIR="$OLD_SYSTEM_DIR"
export FLATPAK_CONFIG_DIR="$OLD_CONFIG_DIR"
export DBUS_SYSTEM_BUS_ADDRESS="$OLD_DBUS"

echo ":: Done! Flatpaks are now prepared in $PROFILE_DIR"
echo