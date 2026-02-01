#!/bin/bash

figlet -f smslant "Build ISO"

echo ":: Building the ML4W OS ISO..."
echo

# Install Flatpaks
./flatpaks.sh

# Install stable dotfiles
./dotfiles.sh

# 1. Clean up old build artifacts
echo ":: Cleaning up previous builds..."
sudo rm -rf /tmp/archiso-tmp
sudo rm -rf ./out

# 2. Ensure install-ml4w-os has the right permissions locally
echo ":: Ensure permissions..."
chmod +x airootfs/usr/local/bin/install-ml4w-os

# 3. Scrub trailing spaces from the package list just in case
echo ":: Scrub trailing spaces from the package list..."
sed -i 's/[[:space:]]*$//' packages.x86_64

# 4. Start the build
echo ":: Building ML4W Arch ISO..."
sudo mkarchiso -v -w /tmp/archiso-tmp -o ./out .

echo ":: Done! Check the ./out folder for your ISO."
echo 