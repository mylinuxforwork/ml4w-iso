#!/bin/bash

# Configuration
TAG="2.11.0"
# VERSION="stable"
VERSION="rolling"
DOTFILES_SOURCE="com.ml4w.dotfiles.stable"
GITHUB_DOTFILES="https://github.com/mylinuxforwork/dotfiles"
BUILD_FOLDER="$HOME/builds/ml4w-iso"
PROFILE_FOLDER="$BUILD_FOLDER/profile"
OUT_FOLDER="$HOME/builds/ml4w-iso/out"
SKEL_FOLDER="$PROFILE_FOLDER/airootfs/etc/skel"
ICON_DIR="$SKEL_FOLDER/.local/share/icons/"
DOTFILES="$SKEL_FOLDER/.mydotfiles/com.ml4w.dotfiles.stable"
CACHE_FOLDER="$HOME/.cache/ml4w-iso"

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

_install_icons() {
    figlet -f smslant "Icons"

    local temp_dir=$(mktemp -d -t ml4w-icons-XXXXXX)
    mkdir -p $ICON_DIR

    echo ":: Installing Kora Icons..."

    # clone icons
    git clone --depth 1 https://github.com/bikass/kora.git $temp_dir
    echo ":: kora icon theme cloned into $temp_dir"

    # copy icon folders
    cp -rf $temp_dir/kora $ICON_DIR
    cp -rf $temp_dir/kora-pgrey $ICON_DIR
    echo ":: kora icon theme installed in $ICON_DIR"

    # clean up
    rm -rf $temp_dir
}

_install_dotfiles_settings() {
    figlet -f smslant "ML4W Dotfiles Settings"

    local temp_dir=$(mktemp -d -t ml4w-dotfiles-settings-XXXXXX)

    echo ":: Installing ML4W Dotfiles Settings..."

    # Create folders
    mkdir -p $SKEL_FOLDER/.local/bin
    mkdir -p $SKEL_FOLDER/.local/share/ml4w-dotfiles-settings

    # clone repo
    git clone --depth 1 https://github.com/mylinuxforwork/ml4w-dotfiles-settings $temp_dir

    # copy files
    cp $temp_dir/bin/ml4w-dotfiles-settings $SKEL_FOLDER/.local/bin/
    cp -rf $temp_dir/lib/. $SKEL_FOLDER/.local/share/ml4w-dotfiles-settings
    echo ":: ML4W Dotfiles Settings installed in $SKEL_FOLDER/.local/bin/ and $SKEL_FOLDER/.local/share/ml4w-dotfiles-settings"

    # clean up
    rm -rf $temp_dir
}

_install_cursors() {
    figlet -f smslant "Cursors"

    local temp_dir=$(mktemp -d -t ml4w-cursors-XXXXXX)
    bibata_url="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/"
    mkdir -p $ICON_DIR

    echo ":: Installing Bibata Cursor Theme..."

    # download cursors
    wget -P $temp_dir $bibata_url/Bibata-Modern-Amber.tar.xz
    wget -P $temp_dir $bibata_url/Bibata-Modern-Classic.tar.xz
    wget -P $temp_dir $bibata_url/Bibata-Modern-Ice.tar.xz

    # extract cursor folders
    tar -xf $temp_dir/Bibata-Modern-Amber.tar.xz -C $ICON_DIR
    tar -xf $temp_dir/Bibata-Modern-Classic.tar.xz -C $ICON_DIR
    tar -xf $temp_dir/Bibata-Modern-Ice.tar.xz -C $ICON_DIR

    # clean up
    rm -rf $temp_dir

}

_install_binaries() {
    figlet -f smslant "Binaries"
    echo ":: Copying binaries into .local/bin"

    # Create folders
    mkdir -p $SKEL_FOLDER/.local/bin
    mkdir -p $SKEL_FOLDER/.local/share
    
    # Matugen
    cp $HOME/.local/bin/matugen $SKEL_FOLDER/.local/bin/
    echo ":: Matugen installed in $SKEL_FOLDER/.local/bin/"

    # oh-my-posh
    cp $HOME/.local/bin/oh-my-posh $SKEL_FOLDER/.local/bin/
    echo ":: Oh-My-Posh installed in $SKEL_FOLDER/.local/bin/"
}

_install_dotfiles() {
    figlet -f smslant "Dotfiles"

    local temp_dir=$(mktemp -d -t ml4w-dotfiles-XXXXXX)

    # Clean up
    if [ -d $SKEL_FOLDER/.mydotfiles ]; then
        echo ":: Removing $SKEL_FOLDER/.mydotfiles"
        rm -rf $SKEL_FOLDER/.mydotfiles
    fi

    echo ":: Creating $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE"
    mkdir -p $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE

    echo ":: Removing $CACHE_FOLDER"
    if [ -d $CACHE_FOLDER ]; then
        rm -rf $CACHE_FOLDER
    fi
    echo ":: Creating $CACHE_FOLDER"
    mkdir -p $CACHE_FOLDER

    echo ":: Cloning $GITHUB_DOTFILES"
    if [ $VERSION == "stable" ]; then
        git clone --depth 1 --branch $TAG $GITHUB_DOTFILES $temp_dir
    else
        git clone --depth 1 $GITHUB_DOTFILES $temp_dir
    fi

    # Installing Fonts
    echo ":: Copying fonts into .local/bin"
    mkdir -p $SKEL_FOLDER/.local/share/fonts
    cp -rf $temp_dir/setup/fonts/* $SKEL_FOLDER/.local/share/fonts/

    # Create ml4w-dotfiles-installer folder in .config and set stable to active
    echo ":: Writing $DOTFILES_SOURCE to $SKEL_FOLDER/.config/ml4w-dotfiles-installer/active.json"
    mkdir -p $SKEL_FOLDER/.config/ml4w-dotfiles-installer
    touch $SKEL_FOLDER/.config/ml4w-dotfiles-installer/active.json
    echo "{\"active\":\"$DOTFILES_SOURCE\"}" > "$active_file"

    # Copy dotfiles
    echo ":: Copying $temp_dir/dotfiles/. to $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE"
    cp -rf $temp_dir/dotfiles/. $SKEL_FOLDER/.mydotfiles/$DOTFILES_SOURCE

    # Create symlinks for dotfiles root
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

    # Create symlinks for .config
    files=$(ls -a $DOTFILES/.config)
    for f in $files; do
        if [ ! "$f" == "." ] && [ ! "$f" == ".." ]; then
            ln -sr $DOTFILES/.config/$f $SKEL_FOLDER/.config
            echo ":: Symlink created $DOTFILES/.config/$f -> $SKEL_FOLDER/.config"
        fi
    done

    # clean up
    rm -rf $temp_dir

    echo ":: Done! Dotfiles are installed in $SKEL_FOLDER"
}

_install_sddm_theme() {
    figlet -f smslant "SDDM Theme"

    echo ":: Starting installation of the ML4W SDDM theme..."
    local temp_dir=$(mktemp -d -t ml4w-sddm-XXXXXX)
    
    echo ":: Cloning theme into temporary directory..."
    git clone --depth 1 https://github.com/mylinuxforwork/ml4w-sddm $temp_dir

    echo ":: Copy theme to sddm folder..."
    sudo mkdir -p $PROFILE_FOLDER/airootfs/usr/share/sddm/themes/ml4w/
    sudo cp -rf $temp_dir/. $PROFILE_FOLDER/airootfs/usr/share/sddm/themes/ml4w/

    echo ":: Copy sddm.conf..."
    sudo cp -rf $temp_dir/sddm.conf $PROFILE_FOLDER/airootfs/etc

    # clean up
    rm -rf $temp_dir

    echo ":: ML4W SDDM theme installed succesfully"
}

_install_ohmyzsh() {
    echo ":: Copying local .oh-my-zsh configuration to $SKEL_FOLDER..."
    cp -rf $HOME/.oh-my-zsh $SKEL_FOLDER
}

_build_iso() {
    figlet -f smslant "Build ISO"
    sudo mkarchiso -v -w /tmp/archiso-tmp -o $OUT_FOLDER $PROFILE_FOLDER
}

# Start
figlet -f smslant "ML4W OS ISO"
echo ":: Starting build process..."

_prepare
_permissions
_install_sddm_theme
_install_dotfiles
_install_binaries
_install_ohmyzsh
_install_cursors
_install_dotfiles_settings
_install_icons
_build_iso

echo ":: Done! Check the ./out folder for your ISO."