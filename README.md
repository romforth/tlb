Tinyconfig Linux Build
----------------------

A linux kernel with a working vi/busybox can be yours for the low, low disk
space usage of only ~1 + ~1.5 MB (for the kernel and initramfs, respectively).

Jokes aside, this is just a helper script to build a tiny linux kernel (using
the `tinyconfig` linux kernel build configuration) along with the code to build
an initramfs (busybox) for use as a VM (tested using QEMU). Rather than use the
regular graphics console, the serial console is used for testing.

The only feature that is missing that I may probably add later is networking/ssh

Although `tinyconfig_linux_build.sh` looks like a runnable shell script, it is
meant to be used as a copy/paste template (think "Linux From Scratch", except
much simpler) where you run each of the commands in the script one at a time
ensuring that the results of the run match the running commentary in the script
and fixing things that break along the way.

I assume there are zillions of similar minimal linux builds. The ones that I'm
aware of / used are compared below:

- The simplest that I've tested has to be
	https://github.com/ivandavidov/minimal-linux-script
  which gives you a fairly minimal but usable linux+busybox combo. The only
  difference from the script that I've created here is that it uses `defconfig`
  as the starting point for the kernel build whereas I start from a much smaller
  `tinyconfig` configuration and add on only the necessary stuff that is needed.
- For a build experience similar to mine, but using Nix (instead of Ubuntu,
  which I used), see https://blinry.org/tiny-linux
- The website at: https://www.insentricity.com/a.cl/283/booting-a-486-from-floppy-with-the-most-up-to-date-stable-linux-kernel shrinks this even further to fit on a floppy (but is meant for older processors).
- `floppinux` appears to be a variation on the same theme and is on Github
	https://github.com/w84death/floppinux
- There used to be other floppy based distros which are probably no longer in
  vogue. Some that I remember are: BasicLinux, MuLinux, HAL2000? ... etc
- The canonical reference if you want to build a linux kernel is LFS of course,
  (https://linuxfromscratch.org) which makes you jump through various hoops by
  first setting up cross compilers and compiling things twice which helps cover
  all your bases but is a lot of work. Think of the work documented here as a
  quick and dirty hack to short circuit through that entire process.
- If you do not wish to build anything, but just want to use a really tiny
  distro, there's Tiny Core Linux (~16MB ISO, for the smallest version, IIRC).
- Slitaz, DSL/Damn Small Linux, Puppylinux are some of the other available
  options if you are looking for something minimalistic distro wise.
- If you want to stay mainstream yet build stuff yourself, you cannot go wrong
  with something Debian based, just search for "How to Build a Debian LiveCD"
- For pure, source based distros, there's Gentoo as well - may the source be
  with you, always.
- Nix is the new hotness and you can generate a fairly minimal (for some bloated
  definition of minimal) ISO using just a few commands.
