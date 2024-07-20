# This recipe is sourced by the toaster, don't try to run it!

# shellcheck disable=SC2086
toast_me() {
  echo "nameserver 1.1.1.1" > $MNT/etc/resolv.conf
  # Install minimal tools
  chroot $MNT apt-get update
  chroot $MNT apt-get install -y wget sudo avahi-daemon
  chroot $MNT apt-get clean
  # Ensure we have the pi user
  chroot $MNT useradd -s /bin/bash -Gsudo -m pi
  chroot $MNT usermod -aG plugdev pi
  echo "pi:raspberry" | chroot $MNT chpasswd
  # Disable root login on SSH
  mkdir -p $MNT/etc/ssh/sshd_config.d/
  echo "PermitEmptyPasswords no" > $MNT/etc/ssh/sshd_config.d/pirogue-ssh.conf
  echo "PermitRootLogin no" >> $MNT/etc/ssh/sshd_config.d/pirogue-ssh.conf
  # Force generate SSH host keys if they exist and enable SSH
  rm -f $MNT/etc/ssh/ssh_host_*
  chroot $MNT systemctl enable ssh
  # Change the hostname
  echo "127.0.0.1 pirogue"               >> $MNT/etc/hosts
  echo "127.0.0.1 pirogue.local pirogue" >> $MNT/etc/hosts
  echo "::1 pirogue"                     >> $MNT/etc/hosts
  echo "::1 pirogue.local pirogue"       >> $MNT/etc/hosts
  echo "pirogue" > $MNT/etc/hostname
  # Add PTS PPA
  chroot $MNT wget -O /etc/apt/sources.list.d/pirogue.list https://pts-project.org/debian-12/pirogue.list
  chroot $MNT wget -O /etc/apt/trusted.gpg.d/pirogue.asc   https://pts-project.org/debian-12/Key.gpg
}
