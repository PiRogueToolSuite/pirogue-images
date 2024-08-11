# This recipe is sourced by the toaster, don't try to run it!

# shellcheck disable=SC2086
toast_me() {
  echo "nameserver 1.1.1.1" > $MNT/etc/resolv.conf

  # Install minimal tools
  chroot $MNT apt-get update
  chroot $MNT apt-get install -y wget sudo avahi-daemon
  chroot $MNT apt-get clean

  # Ensure we have the pi user
  chroot $MNT adduser --disabled-password --gecos '' pi
  chroot $MNT adduser pi sudo
  chroot $MNT adduser pi plugdev
  echo "pi:raspberry" | chroot $MNT chpasswd

  # Let's make sure we don't ship any SSH host keys. Also work around upstream
  # bug leading ssh.service to try and start before SSH host keys have been
  # generated (https://salsa.debian.org/raspi-team/image-specs/-/issues/72):
  # disable ssh.service here, and let the rpi-generate-ssh-host-keys.service
  # enable+start it when everything is ready.
  rm -f $MNT/etc/ssh/ssh_host_*
  chroot $MNT systemctl disable ssh.service
  sed '/^ExecStart=/a ExecStart=/usr/bin/systemctl enable --now ssh.service' \
      -i $MNT/etc/systemd/system/rpi-generate-ssh-host-keys.service

  # Change the hostname
  echo "127.0.1.1	pirogue.local pirogue" >> $MNT/etc/hosts
  echo "::1		pirogue.local pirogue" >> $MNT/etc/hosts
  echo "pirogue" > $MNT/etc/hostname

  # Add PTS PPA
  chroot $MNT wget -O /etc/apt/sources.list.d/pirogue.list https://pts-project.org/debian-12/pirogue.list
  chroot $MNT wget -O /etc/apt/trusted.gpg.d/pirogue.gpg   https://pts-project.org/debian-12/pirogue.gpg

  ### BEGIN: Pi 5 section

  # Preconfigure raspi-firmware to disable the default cma= setting on the
  # kernel command line. Don't run the hook manually, the linux-image install
  # below will take care of it.
  sed '/^#CMA=/a CMA=0' -i $MNT/etc/default/raspi-firmware

  # Make sure the resize happens during the first boot: the image-specs build
  # deletes the hooks after deploying them in the initramfs (for the Debian
  # kernel), and we need them back to include everything we need for the new
  # initramfs (for the Raspberry Pi kernel).
  install -m 755 -o root -g root files/rpi-resizerootfs.hook \
      $MNT/etc/initramfs-tools/hooks/rpi-resizerootfs
  install -m 755 -o root -g root files/rpi-resizerootfs.script \
      $MNT/etc/initramfs-tools/scripts/local-bottom/rpi-resizerootfs

  # Configure Raspberry Pi repository
  cat > $MNT/etc/apt/sources.list.d/raspberrypi.list <<EOF
# Only some specific packages are installed from there (see pirogue.pref):

deb http://archive.raspberrypi.com/debian/ bookworm main
EOF
  cat > $MNT/etc/apt/preferences.d/pirogue.pref <<EOF
# Make sure to only install specific packages from there (see raspberrypi.list):

Package: *
Pin: origin archive.raspberrypi.com
Pin-Priority: -1

Package: linux-image-* firmware-brcm80211
Pin: origin archive.raspberrypi.com
Pin-Priority: 500
EOF
  cp files/raspberrypi-archive-stable.gpg $MNT/etc/apt/trusted.gpg.d

  # Install required packages. The firmware-brcm80211 package ships some files
  # already owned by raspi-firmware, hence the dpkg option.
  chroot $MNT apt-get update
  chroot $MNT apt-get install -y -o Dpkg::Options::='--force-overwrite' linux-image-rpi-2712 firmware-brcm80211
  chroot $MNT apt-get clean

  # Make sure the resize doesn't happen past the first boot
  rm -f $MNT/etc/initramfs-tools/hooks/rpi-resizerootfs
  rm -f $MNT/etc/initramfs-tools/scripts/local-bottom/rpi-resizerootfs

  ### END: Pi 5 section
}
