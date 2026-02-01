#!/bin/bash

figlet -f smslant "Dotfiles"

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
mkdir -p $SKEL_FOLDER/.mydotfiles
echo ":: $SKEL_FOLDER/.mydotfiles created"

mkdir -p $SKEL_FOLDER/.config
echo ":: $$SKEL_FOLDER/.config created"

# Copy current configuration
cp -rf $HOME/.mydotfiles/com.ml4w.dotfiles.stable $SKEL_FOLDER/.mydotfiles
echo ":: $HOME/.mydotfiles/com.ml4w.dotfiles.stable copied to $SKEL_FOLDER/.mydotfiles"

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