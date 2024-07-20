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
  # Force generate SSH host keys if they exist
  rm -f $MNT/etc/ssh/ssh_host_*
  # Change the hostname
  echo "127.0.1.1	pirogue.local pirogue" >> $MNT/etc/hosts
  echo "::1		pirogue.local pirogue" >> $MNT/etc/hosts
  echo "pirogue" > $MNT/etc/hostname
  # Add PTS PPA
  chroot $MNT wget -O /etc/apt/sources.list.d/pirogue.list https://pts-project.org/debian-12/pirogue.list
  chroot $MNT wget -O /etc/apt/trusted.gpg.d/pirogue.asc   https://pts-project.org/debian-12/Key.gpg
}
