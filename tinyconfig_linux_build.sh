#!/bin/bash

# tinyconfig_linux_build.sh : Build a minimal linux kernel + busybox
#
# Copyright (C) 2020 Charles Suresh <charles.suresh@gmail.com>
# SPDX-License-Identifier: AGPL-3.0-only
# Please see the LICENSE file for the Affero GPL 3.0 license details

# This script is meant to be copy pasted, a command at a time, rather than run
# in one shot. The comments are meant as a sanity check to guide you along.

set -ex

# begin: these configuration variables may be modified as appropriate: {

# set depth to the empty string if you want to pull in the whole kernel git tree
# depth=''
# otherwise, just get only the files without all of git's historical baggage
depth='--depth=1'

# pick where you want to clone the kernel from
g='git.kernel.org/pub/scm/linux/kernel/git/stable'

# set this to a place with sufficient disk space
k=$HOME/git/$g
# the kernel sources will be under 'linux' and binaries under 'build'

# set this to a directory where the busybox sources and binaries will be stored
d=$HOME/git/git.busybox.net

# end: these configuration variables may be modified as appropriate: }

# The code below here shouldn't need any additional modifications:

kb=$k/build

if [ -d $k ] ; then
	cd $k
else
	mkdir -p $k
	cd $k
fi

if [ -d linux ] ; then
	cd linux
	git pull
else
	git clone $depth "git://$g/linux.git"
	cd linux
fi

# gcc, flex and bison are needed for the next step
make O=$kb tinyconfig

# bc is required for the next step
make O=$kb

# test whether the tinyconfig kernel that was built works:
qemu-system-x86_64 -kernel $kb/arch/x86/boot/bzImage # works?
# maybe, but there are no console messages to tell what happened

# so we enable console messages (and the tty device): (ncurses is needed)
make O=$kb menuconfig # This needs to be automated to do the following:
#        Device Drivers
#          > Character devices
#            [*] Enable TTY
#        General Setup
#          > Configure standard kernel features (expert users)
#            [*] Enable support for printk

make O=$kb

# test whether the kernel that was built shows console messages:
qemu-system-x86_64 -kernel $kb/arch/x86/boot/bzImage # console messages?
# probably ends in "Kernel panic - not syncing: No working init found."

# Next we try using only the serial console:
qemu-system-x86_64 -kernel $kb/arch/x86/boot/bzImage -nographic -append "console=ttyS0" # no console messages on the serial console

# so we next enable the serial drivers and using it for the console
make O=$kb menuconfig # This needs to be automated to do the following:
#       Device Drivers
#          > Character devices
#            > Serial drivers
#              [*] 8250/16550 and compatible serial support
#              [*] Console on 8250/16550 and compatible serial port

make O=$kb

# Try using the serial console again:
qemu-system-x86_64 -kernel $kb/arch/x86/boot/bzImage -nographic  -append "console=ttyS0" # you should see the kernel messages directly on your terminal
# probably ends in "Kernel panic - not syncing: No working init found."

# Now that the kernel can display progress on the serial console, it's time to
# go ahead and build the initramfs using busybox

u=$d/busybox
bb=$d/build

[ -d $d ] || mkdir -p $d
cd $d

if [ -d $u ] ; then
	cd $u
	git pull
else
	git clone $depth git://git.busybox.net/busybox
	cd $u
fi

[ -d $bb ] || mkdir -p $bb

make O=$bb defconfig # out of tree build

make O=$bb menuconfig # This needs to be automated to do the following:
# Settings
#   [*] Build static binary (no shared libs)
# CONFIG_STATIC=y

make O=$bb

make O=$bb install
(cd $bb/_install ; find . | cpio -R root:root -H newc -o | gzip > $bb/rootfs.gz)

qemu-system-x86_64 --initrd $bb/rootfs.gz --kernel $kb/arch/x86/boot/bzImage --nographic  --append "console=ttyS0 init=/bin/sh"
# Kernel panic - not syncing: Requested init /bin/sh failed (error -2)

# Looks like we need to rebuild the kernel with even more config changes
cd $k/linux

# Redo the kernel build enabling initramfs and support for ELF binaries

make O=$kb menuconfig # This needs to be automated to do the following:
#        General Setup
#          [*] Initial RAM filesystem and RAM disk (initramfs/initrd) support
#          [*] Support initial ramdisk/ramfs compressed using gzip
#        Executable file formats
#          [*] Kernel support for ELF binaries

make O=$kb

qemu-system-x86_64 -initrd $bb/rootfs.gz -kernel $kb/arch/x86/boot/bzImage -nographic -append "console=ttyS0 init=/bin/sh"
# Kernel panic - not syncing: Requested init /bin/sh failed (error -8).

# Redo the kernel build enabling even more options:
make O=$kb menuconfig # This needs to be automated to do the following:
# [*] 64-bit kernel
# Binary Emulations
#   [*] IA32 Emulation
#   [*] x32 ABI for 64-bit mode

# elf developer packages are needed for this step to supply elf.h
make O=$kb

qemu-system-x86_64 -initrd $bb/rootfs.gz -kernel $kb/arch/x86/boot/bzImage -nographic -append "console=ttyS0 init=/bin/sh" # should give you a working shell
# The following commands can be typed into the shell
# find / | less
# ls /bin # even a working vi is part of this ~1.5 MB initramfs + ~1 MB Kernel
