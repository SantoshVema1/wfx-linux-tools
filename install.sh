#!/bin/bash
# Copyright (c) 2018, Silicon Laboratories
# See license terms contained in COPYING file

# This script performs actions needed to install public tools
# It is typically ran by tools_install.sh after an update

set -e
# Always run as root
[ $(id -u) = 0 ] || exec sudo $0 "$@"

! [ -e install.sh ] && echo "This script must be run from wfx-linux-tools" && exit 1 || true

rm -f /usr/local/bin/wfx_*
rm -f /usr/local/bin/pds_compress

# Create a link under /usr/local/bin for all files matching wfx_ (ignore files with extension and backup files)
find ! -path '*/\.*' -type f \( -name 'wfx_*' -o -name pds_compress \) ! -name '*~' ! -name '*.*' -execdir bash -c 'ln -vs $(realpath {}) /usr/local/bin/$(basename {})' \;

dtc -@ -W no-unit_address_vs_reg overlays/wfx-spi-overlay.dts -o /boot/overlays/wfx-spi.dtbo
dtc -@ -W no-unit_address_vs_reg overlays/wfx-sdio-overlay.dts -o /boot/overlays/wfx-sdio.dtbo
dtc -@ -W no-unit_address_vs_reg overlays/spidev-overlay.dts -o /boot/overlays/spidev.dtbo

echo "Success"
