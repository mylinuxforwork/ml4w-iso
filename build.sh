#!/bin/bash

# 1. Clean up old build artifacts
echo "🧹 Cleaning up previous builds..."
sudo rm -rf /tmp/archiso-tmp
sudo rm -rf ./out

# 2. Ensure the installer script has the right permissions locally
chmod +x airootfs/usr/local/bin/install-ml4w

# 3. Scrub trailing spaces from the package list just in case
sed -i 's/[[:space:]]*$//' packages.x86_64

# 4. Start the build
echo "🏗️ Building ML4W Arch ISO..."
sudo mkarchiso -v -w /tmp/archiso-tmp -o ./out .

echo "✅ Build complete! Check the ./out folder for your ISO."