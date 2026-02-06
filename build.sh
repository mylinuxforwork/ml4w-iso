#!/bin/bash

# Configuration
VERSION="2.10.0"
DOTFILES_SOURCE="com.ml4w.dotfiles.stable"
GITHUB_DOTFILES="https://github.com/mylinuxforwork/dotfiles"
BUILD_FOLDER="$HOME/builds/ml4w-iso"
PROFILE_FOLDER="$BUILD_FOLDER/profile"
OUT_FOLDER="$HOME/builds/ml4w-iso/out"
PUBLIC_KEY=$(realpath "$HOME/ml4w-apps-public-key.asc")
SKEL_FOLDER="$PROFILE_FOLDER/airootfs/etc/skel"
DOTFILES="$SKEL_FOLDER/.mydotfiles/com.ml4w.dotfiles.stable"
CACHE_FOLDER="$HOME/.cache/ml4w-iso"
TMP_FOLDER="$HOME/.cache/ml4w-tmp"

FLATPAKS_ML4W=(
    "com.ml4w.welcome"
    "com.ml4w.settings"
    "com.ml4w.calendar"
    "com.ml4w.sidebar"
    "com.ml4w.hyprlandsettings"
)

FLATPAKS_APPS=(
    "com.ml4w.dotfilesinstaller"
)

# Functions
_prepare() {
    figlet -f smslant "Prepare"

    echo ":: Remove existing build folder..."
    sudo rm -rf $BUILD_FOLDER

    echo ":: Creating build folder..."
    mkdir -p $BUILD_FOLDER

    echo ":: Creating out folder..."
    mkdir -p $OUT_FOLDER

    echo ":: Copy profile into build folder..."
    cp -rf ./profile $BUILD_FOLDER

    echo ":: Cleaning up previous builds..."
    sudo rm -rf /tmp/archiso-tmp

    echo ":: Cleaning up previous builds..."
    sudo rm -rf /tmp/archiso-tmp
    sudo rm -rf ./out

    echo ":: Scrub trailing spaces from the package list..."
    sed -i 's/[[:space:]]*$//' $PROFILE_FOLDER/packages.x86_64
}

_permissions() {
    figlet -f smslant "Permissions"

    echo ":: Ensure permissions..."
    chmod +x $PROFILE_FOLDER/airootfs/usr/local/bin/install-ml4w-os
}

_install_flatpaks() {
    figlet -f smslant "Flatpaks"

    # Clean up
    if [ -d $PROFILE_FOLDER/airootfs/var/lib/flatpak ]; then
        sudo rm -rf $PROFILE_FOLDER/airootfs/var/lib/flatpak
    fi    

    # Backup current Flatpak environment variables
    OLD_SYSTEM_DIR="$FLATPAK_SYSTEM_DIR"
    OLD_CONFIG_DIR="$FLATPAK_CONFIG_DIR"
    OLD_DBUS="$DBUS_SYSTEM_BUS_ADDRESS"

    # Redirect Flatpak and disable D-Bus (forces local file writing)
    export FLATPAK_SYSTEM_DIR="$PROFILE_FOLDER/airootfs/var/lib/flatpak"
    export FLATPAK_CONFIG_DIR="$PROFILE_FOLDER/airootfs/etc/flatpak"
    export DBUS_SYSTEM_BUS_ADDRESS=""

    echo ":: Staging Flatpaks in: $FLATPAK_SYSTEM_DIR..."
    mkdir -p "$FLATPAK_SYSTEM_DIR" "$FLATPAK_CONFIG_DIR"

    echo ":: Adding Remotes..."
    sudo -E flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    if [ -f "$PUBLIC_KEY" ]; then
        sudo -E flatpak remote-add --system --if-not-exists ml4w-repo https://mylinuxforwork.github.io/ml4w-flatpak-repo/ml4w-apps.flatpakrepo --gpg-import="$PUBLIC_KEY"
    else
        echo "Warning: GPG key not found. Adding repo without it..."
        sudo -E flatpak remote-add --system --if-not-exists ml4w-repo https://mylinuxforwork.github.io/ml4w-flatpak-repo/ml4w-apps.flatpakrepo
    fi

    echo ":: Installing ML4W Flatpak Apps..."
    for app in "${FLATPAKS_ML4W[@]}"; do
        echo "   --> Installing $app"
        sudo -E flatpak install --system ml4w-repo "$app" -y --noninteractive
    done

    echo ":: Installing Flatpak Apps..."
    for app in "${FLATPAKS_APPS[@]}"; do
        echo "   --> Installing $app"
        sudo -E flatpak install --system "$app" -y --noninteractive
    done

    echo ":: Cleaning up environment variables..."
    export FLATPAK_SYSTEM_DIR="$OLD_SYSTEM_DIR"
    export FLATPAK_CONFIG_DIR="$OLD_CONFIG_DIR"
    export DBUS_SYSTEM_BUS_ADDRESS="$OLD_DBUS"

    echo ":: Done! Flatpaks are now prepared in $FLATPAK_SYSTEM_DIR"
}

_install_dotfiles() {
    figlet -f smslant "Dotfiles"

    # Clean up
    if [ -d $SKEL_FOLDER/.mydotfiles ]; then
        echo ":: Removing $SKEL_FOLDER/.mydotfiles"
        rm -rf $SKEL_FOLDER/.mydotfiles
    fi
    if [ -d $SKEL_FOLDER/.config ]; then
        echo ":: Removing $SKEL_FOLDER/.config"
        rm -rf $SKEL_FOLDER/.config
    fi

    echo ":: Creating $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE"
    mkdir -p $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE

    echo ":: Creating $SKEL_FOLDER/.config"
    mkdir -p $SKEL_FOLDER/.config

    echo ":: Removing $CACHE_FOLDER"
    if [ -d $CACHE_FOLDER ]; then
        rm -rf $CACHE_FOLDER
    fi
    echo ":: Creating $CACHE_FOLDER"
    mkdir -p $CACHE_FOLDER

    echo ":: Cloning $GITHUB_DOTFILES"
    git clone --depth 1 --branch $VERSION $GITHUB_DOTFILES $CACHE_FOLDER

    echo ":: Copying $CACHE_FOLDER/dotfiles/. to $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE"
    cp -rf $CACHE_FOLDER/dotfiles/. $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE

    echo ":: Copying local ~/.mydotfiles/$DOTFILES_SOURCE/config.dotinst to $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE"
    cp ~/.mydotfiles/$DOTFILES_SOURCE/config.dotinst $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE

    # Check dotfiles root
    echo ":: Creating symlinks..."
    files=$(ls -a $DOTFILES)
    for f in $files; do
        if [ ! "$f" == "." ] && [ ! "$f" == ".." ] && [ ! "$f" == ".config" ] && [ ! "$f" == "config.dotinst" ]; then
            if [ -f $SKEL_FOLDER/$f ]; then
                rm $SKEL_FOLDER/$f
            fi
            if [ -f $DOTFILES/$f ]; then
                ln -sr $DOTFILES/$f $SKEL_FOLDER
                echo ":: Symlink created $DOTFILES/$f -> $SKEL_FOLDER"
            fi
        fi
    done

    # Check .config
    files=$(ls -a $DOTFILES/.config)
    for f in $files; do
        if [ ! "$f" == "." ] && [ ! "$f" == ".." ]; then
            ln -sr $DOTFILES/.config/$f $SKEL_FOLDER/.config
            echo ":: Symlink created $DOTFILES/.config/$f -> $SKEL_FOLDER/.config"
        fi
    done

    echo ":: Done! Dotfiles are installed in $SKEL_FOLDER"
}

_install_sddm_theme() {
    echo ":: Starting installation of the ML4W SDDM theme..."
    
    echo ":: Creating temporary directory..."
    rm -rf $TMP_FOLDER
    mkdir -p $TMP_FOLDER
    
    echo ":: Cloning theme into temporary directory..."
    git clone --depth 1 https://github.com/mylinuxforwork/ml4w-sddm $TMP_FOLDER/ml4w-sddm

    echo ":: Copy theme to sddm folder..."
    sudo mkdir -p $PROFILE_FOLDER/airootfs/usr/share/sddm/themes/ml4w/
    sudo cp -rf $TMP_FOLDER/ml4w-sddm/. $PROFILE_FOLDER/airootfs/usr/share/sddm/themes/ml4w/

    echo ":: Copy sddm.conf..."
    sudo cp -rf $TMP_FOLDER/ml4w-sddm/sddm.conf $PROFILE_FOLDER/airootfs/etc

    echo ":: Cleaning up..."
    rm -rf $TMP_FOLDER

    echo ":: ML4W SDDM theme installed succesfully"
    
}

_build_iso() {
    figlet -f smslant "Build ISO"
    sudo mkarchiso -v -w /tmp/archiso-tmp -o $OUT_FOLDER $PROFILE_FOLDER
}

# Start
figlet -f smslant "ML4W OS ISO"
echo ":: Starting ML4W OS ISO build..."

_prepare
_permissions
_install_flatpaks
_install_sddm_theme
_install_dotfiles
_build_iso

echo ":: Done! Check the ./out folder for your ISO."