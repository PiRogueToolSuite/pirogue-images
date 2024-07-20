PiRogue images
==============

This repository contains the tools required to build “historical” PiRogue images,
targeting Raspberry Pi 3 and Raspberry Pi 4.

**Experimental** support for the Raspberry Pi 5 is provided as well. As of July
2024, it is brand new, and further upgrades of packages like `raspi-firmware`
(on the Debian side), or `linux-image-*` and `firmware-brcm80211` (on the
Raspberry OS side) might be problematic.

It operates by turning pristine
[Debian-provided images for Raspberry Pi](https://raspi.debian.net/) into
images ready to deploy PiRogue Tool Suite packages. In the future the same might
happen for [Debian-provided cloud images](https://cloud.debian.org/images/cloud/).
