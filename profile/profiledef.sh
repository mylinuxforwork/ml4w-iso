#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="ml4w-os"
iso_label="ML4W_OS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="ML4W <https://mylinuxforwork.github.io/dotfiles>"
iso_application="ML4W Dotfiles for Hyprland"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d/"]="0:0:400"
  ["/etc/os-release"]="0:0:644"
  ["/etc/polkit-1"]="0:0:750"
  ["/etc/polkit-1/rules.d"]="0:0:750"
  ["/etc/polkit-1/rules.d/49-nopasswd_global.rules"]="0:0:644"

  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/install-ml4w-os"]="0:0:755"

  ["/etc/skel/"]="0:0:755"
  
  ["/var/"]="0:0:755"
)
