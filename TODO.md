# Experimental Pi 5 image

## Linux kernel packages

Until the Pi 5 is supported by Linux mainline and until suitable `linux-image-*`
packages are available in Debian, it makes sense to ship a specific image for
the Pi 5 that features `linux-image-*` packages (meta and regular) from
Raspberry OS.

It makes little to no sense to ship the Debian packages as well, as they are not
going to be useful, and might even make things complicated:

 - What happens when an update shows up in Debian? Could it be preferred over
   the Raspberry OS one for the following boot, effectively bricking the PiRogue
   running on Pi 5?
 - Additionally that means a slightly bigger image to download initially (~ 100
   MB), plus useless upgrades later on.

If we decide to get rid of them, we must make sure we're not losing any other
packages pulled via dependencies, or any kind of integration (e.g. initramfs
hooks).


## Firmware packages

A longstanding issue is that the `raspi-firmware` has been shipping Pi-related
things from a very long while, mainly bootloader files and integration to make
sure the Linux kernel image, the associated initramfs, and the DTBs are
available under `/boot/firmware`. But that also include some wireless firmware
files. It's been requested to move them to the existing `firmware-brcm80211`
package but that hasn't happened yet.

Unfortunately, Debian 12 doesn't ship firmware files making it possible to
support the Pi 5 wireless interface (symptom: no `wlan0` interface). That's why
we're pulling `firmware-brcm80211` from Raspberry OS in addition to Linux kernel
packages. Since that package and Debian's `raspi-firmware` package have files in
common, `dpkg` errors out when trying to install them side by side, that's why
the Pi 5 image build uses `--force-overwrite`.

Open questions:

 - What happens if and when Debian ships an updated `raspi-firmware` package?
   Will that trigger a new file conflict? Gut feeling: yes. An update during
   Debian 12's lifetime (either via the security team or the release team) seems
   *unlikely*.
 - What happens if and when Raspberry OS ships an updated `firmware-brcm80211`
   package? Will that trigger a new file conflict? Gut feeling: maybe not, if
   the initial overwrite triggered this package's being the registered owner of
   those files, we might be safe. An update during Debian 12's lifetime seems
   *possible* to *probable*, as the `firmware-nonfree` source package that
   builds this binary package might get updated to support newer hardware and/or
   to fix security and stability problems.

It would be good to test both cases to see what happens. If both break horribly
and we want to be safe, we could adjust the APT pinning (`pirogue.pref`) to
avoid upgrades for both packages, for example.
