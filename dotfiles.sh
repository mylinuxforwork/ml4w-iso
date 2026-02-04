#!/bin/bash

figlet -f smslant "Dotfiles"

SOURCE_DOTFILES="com.ml4w.dotfiles.stable"
VERSION="2.10.0"
SKEL_FOLDER="./airootfs/etc/skel"
DOTFILES="$SKEL_FOLDER/.mydotfiles/com.ml4w.dotfiles.stable"

# Clean
if [ -d $SKEL_FOLDER/.mydotfiles ]; then
    rm -rf $SKEL_FOLDER/.mydotfiles
    echo ":: $SKEL_FOLDER/.mydotfiles removed"
fi
if [ -d $SKEL_FOLDER/.config ]; then
    rm -rf $SKEL_FOLDER/.config
    echo ":: $SKEL_FOLDER/.config removed"
fi

# Create Dotfiles Folder
mkdir -p $SKEL_FOLDER/.mydotfiles/$SOURCE_DOTFILES
echo ":: $SKEL_FOLDER/.mydotfiles/$SOURCE_DOTFILES created"

mkdir -p $SKEL_FOLDER/.config
echo ":: $$SKEL_FOLDER/.config created"

# Clone Latest Version
if [ -d ~/.cache/ml4w-iso ]; then
    rm -rf ~/.cache/ml4w-iso
fi
mkdir -p ~/.cache/ml4w-iso
git clone --depth 1 --branch $VERSION https://github.com/mylinuxforwork/dotfiles ~/.cache/ml4w-iso

# Copy current configuration
cp -rf ~/.cache/ml4w-iso/dotfiles/. $SKEL_FOLDER/.mydotfiles/$SOURCE_DOTFILES
echo ":: ~/.cache/ml4w-iso/dotfiles/. copied to $SKEL_FOLDER/.mydotfiles/$SOURCE_DOTFILES"

# Copy local dotinst
cp ~/.mydotfiles/$SOURCE_DOTFILES/config.dotinst $SKEL_FOLDER/.mydotfiles/$SOURCE_DOTFILES
echo ":: ~/.mydotfiles/$SOURCE_DOTFILES/config.dotinst copied to $SKEL_FOLDER/.mydotfiles/$SOURCE_DOTFILES"

# Check home
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
echo