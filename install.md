# Full Installation

The following guide describes how to set up a complete NixOS system (the way I do it). It's not necessarily related. If you just want to add this to your preexisting config, jump to `# Setup Milk`.

## Getting a Commandline
### Install a new device with an additional separate device

- create a bootable USB-Stick with Nixos Minimal
- boot the new device with that installer
- Set a temporary password for the `nixos` user with `passwd nixos`
- run `sudo systemctl start sshd`
- run `ip a` and use the shown IP to connect to from the second device
- on the secondary device, run `ssh nixos@IP` where IP is the IP from previous command
- run `sudo -i`

### From a graphical installer

- create a bootable USB-Stick with Nixos Gnome/KDE installer
- Boot the new device with that installer
- Adjust keyboard layout (TODO: how?)
- open a terminal
 run `sudo -i`

### TODO: From an existing Debian/Redhat/whatever

## Partitioning

I recommend one LUKS encrypted partition containing BTRFS. This allows flexible partitioning (if necessary) lateron or theoreticylly even multiboot inside the same LUKS (But only linux!)

### First figure out the device
```
fdisk -l
Disk /dev/loop0: 699.37 MiB, 733343744 bytes, 1432312 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 14.42 GiB, 15479597056 bytes, 30233588 sectors
Disk model: DataTraveler G3
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x9fb6382f

Device     Boot Start     End Sectors  Size Id Type
/dev/sda1  *        0 1540095 1540096  752M  0 Empty
/dev/sda2       14780   65979   51200   25M ef EFI (FAT-12/16/32)


Disk /dev/nvme0n1: 953.87 GiB, 1024209543168 bytes, 2000409264 sectors
Disk model: SAMSUNG MZVLB1T0HBLR-000L7
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: DB54733F-E73C-4EAF-9C00-C048A0D5D026

Device              Start        End    Sectors   Size Type
/dev/nvme0n1p1       2048     534527     532480   260M EFI System
/dev/nvme0n1p2     534528     567295      32768    16M Microsoft reserved
/dev/nvme0n1p3     567296 1998360575 1997793280 952.6G Microsoft basic data
/dev/nvme0n1p4 1998360576 2000408575    2048000  1000M Windows recovery environment
```
In above case it's `/dev/nvme0n1`
### Partition the disk:

#### UEFI
```
disk="/dev/nvme0n1"
parted "$disk" -- mklabel gpt
parted "$disk" -- mkpart primary 512MiB 100%
parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
parted "$disk" -- set 2 esp on
```

#### Legacy
```
disk="/dev/nvme0n1"
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB 100%
```

### Setup LUKS & btrfs

```
# This will ask for a password twice!
cryptsetup luksFormat "${disk}p1"
cryptsetup luksOpen "${disk}p1" linux
mkfs.btrfs /dev/mapper/linux

mkdir /mnt/btrfs
mount /dev/mapper/linux /mnt/btrfs
cd /mnt/btrfs
btrfs subvolume create @nixos
btrfs subvolume create @swap
# optionally create additional subvolumes
btrfs subvolume create @home

cd
umount /mnt/btrfs
mount /dev/mapper/linux -o subvol=@nixos /mnt

mkfs.fat -F 32 -n boot ${disk}p2
mkdir /mnt/boot
mount ${disk}p2 /mnt/boot
```

It's possible to configure [swap & hibernation](hibernation.md) right here.

## Generate the basic configuration

```
nixos-generate-config --root /mnt
```

I also recommend adding:
```
hardware.enableRedistributableFirmware = true;
```

## Setup Milk

### Clone The repo and set it up

Now clone the repo:

```
cd /mnt/etc/nixos
git clone git@githut.com:Melkor333/milkos.git
```

Change the `/mnt/etc/nixos/configuration.nix` to look like this::

```
{ config, pkgs, ... }:
let
  # TODO: Fix it somehow that this is not necessary
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./milkos
      (import "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz"}/nixos)
    ];

    { ... snip ... }

```

## Fix configuration

Comment out lines like the following or even delete them (we'll be using NetworkManager):
```
  #networking.interfaces.enp0s31f6.useDHCP = true;
  #networking.interfaces.wlp82s0.useDHCP = true;
```

Enable milkos by adding the following line:

```
  milk.enable = true;
```

Give your Device a name:
```
  networking.hostName = "myhostname";
```

Setup unstable branch by executing the following on the command line (this repo is not tested against stable)
```
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

Properly set the preconfigured variables like `# time.timeZone...` :)

## Setup user home

My Home Currently looks a bit like this:
```
  milk = {
    enable = true;
    fancyPkgs.enable = true;
    desktopPkgs.enable = true;
    home = {
      enable = true;
      user = "Melkor333";
      fullName = "Samuel Hierholzer";
      keepassxc.enable = true;
    };
  };
```

## Setup XServer

TODO: Milkos DOES NOT handle a proper window/desktop manager. But it enables a lot of services by default. I'll need to clear this up and make a variable like `enableWmServices` or something. This should then be disabled when using DE's like KDE/Gnome. MR's welcome :)
But this makes it necessary for you to set up `services.xserver` according to your needs. Mainly `services.xserver.windowmanager` or `services.xserver.desktopManager` are relevant.

I set up the window manager as follows in `/mnt/etc/nixos/configuration.nix`. xfce is just a fallback if xmonad doesn't work for some reason. (My XMonad is currently managed outside of nix...):

```
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = true;
      xfce.enable = true;
    };
    displayManager.lightdm.enable = true;
    windowManager.xmonad = {
      enableContribAndExtras = true;
      enable = true;
    };
    layout = "ch";
    libinput.touchpad.disableWhileTyping = true;
  };
```

## Add Nixos Hardware

Check on https://github.com/NixOS/nixos-hardware if your device is there and add the two lines containing `nixos-hardware` to `/mnt/etc/nixos/configuration.nix`. Replace the DEVICENAME with the path to your folder, eg. `lenovo/thinkpad/t14s/amd/gen1`:
```
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  nixos-hardware = builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      (import "${nixos-hardware}/DEVICENAME")
      ./milkos
    ];
```

## Add local_packages.nix for npkg

This file will be used by `npkg` to automatically add packages to your declarative configuration.

```
sudo cp local_packages.nix /etc/nixos/local_packages.nix
```

Edit it to your needs so that it (already) contains all the stuff you want :)

## Install

```
nixos-install
```

## Set password for the user

After rebooting the device and logging in for the first time without a password, set one:
```
passwd USERNAME
```
