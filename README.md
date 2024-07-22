<div align="center">
<img width="60px" src="https://pts-project.org/android-chrome-512x512.png">
<h1>PiRogue OS images</h1>
<p>
PiRogue OS is a slightly modified version of Debian you can flash on an SD card to quickly turn a Raspberry Pi into a PiRogue. Want to build one? Follow the guide "<a href="https://pts-project.org/guides/g1/" alt="How to setup a PiRogue">How to set up a PiRogue</a>".
</p>
<p>
License: GPLv3
</p>
<p>
<a href="https://pts-project.org">Website</a> | 
<a href="https://pts-project.org/docs/pirogue/overview/">Documentation</a> | 
<a href="https://discord.gg/qGX73GYNdp">Support</a>
</p>
</div>

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
