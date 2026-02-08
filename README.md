# ML4W Dotfiles ISO 

The Live ISO of the ML4W OS.

## Users

The Live ISO includes a user with sudo permissions:

liveuser/liveuser

## Installation script

The ISO includes an installation script to install the Live ISO to teh hard drive

Run sudo install-ml4w-iso in a terminal

The system will install a btrfs filesystem in a snapshot compatible layout and related subvolumes.
You can use Snapper or Timeshift to configure and create snapshots.

## Building the ISO

Run ./build.sh

Comment the _flatpaks function. This requires the ml4w-repo public key.
