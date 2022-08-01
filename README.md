Add some milk to your (corn) flakes! :P

jokes aside, this is more or less a gathering of various nix related tools and sane configs to be used on a typical NixOS Desktop installation.
Configured in a way it (should) be completely overridable. Just reconfigure what you don't like in your `configuration.nix`. :)

It's currently not using flakes at all, but that's probably the next thing to work on...

If you miss something or think something shouldn't be enabled per default, make an Issue or a PR.
I'm glad for any input! :)

The long term idea for this is to become to NixOS a bit like what Manjaro is to Arch linux.

# NixOS based "Distro"

# Current Features (and weirdnesses :P)

- Wifi, Sound, Bluetooth, Antivirus, printing, virtualization
- [Home-Manager](https://github.com/nix-community/home-manager) integration
- [nixos-hardware](https://github.com/NixOS/nixos-hardware) usage instructions
- [nix user repository (nur)](https://github.com/nix-community/NUR)
- [NPKG package manager](https://github.com/vlinkz/npkg) which can automatically add packages to your `configuration.nix`
- TODO: Add [Nix GUI](https://github.com/nix-gui/nix-gui) as alternative to npkg
- Install instructions with encryption and safe hibernation
- Full KeepassXC integration as secret service/keyring and Browser Integration
- with `milk.laptop.enable = true;`: Brightness, Touchpad, USB-C Docking Station
- with `milk.yubikey.enable = true;`: all tools required to use and configure a yubikey
- Installation documentation includes BTRFS filesystem plus disk encryption. Allows for Snapshots, COW, etc.
- A lot of CLI Tools
- with `milk.fancyPkgs.enable = true;`: some very fancy CLI Tools
- with `milk.desktopPkgs.enable = true;`: Basic Desktop tools like Browser, Mail Client, Office Suite, etc.
- with `milk.vm.enable = true;`: Everything required to run this inside a KVM/Libvirt VM
- TODO: The way too fancy [nixos-boot](https://github.com/Melkor333/nixos-boot) loader which takes too much ressources on a small boot...

# Usage

The following is how to add this repo to an existing config, but there's also a [full installation example](install.md)

## First you need to clone the repository (as root):
```
cd /mnt/etc/nixos
sudo git clone git@githut.com:Melkor333/milkos.git
```

You can use it by simply adding configuration options to your `configuration.nix`:
``` nix
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  nixos-hardware = builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      (import "${nixos-hardware}/lenovo/thinkpad/t14s/amd/gen1")
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      ./milkos
    ];
  # enable the basic milkos configuration:
  milk.enable = true;

  # configure your users home settings:
  milk.home = {
    user = "Melkor333";
    enable = true;
    keepassxc.enable = true;
    keepassxc.managedConfigfile = true;
  };
```

## Setup nixos unstable branch

Setup unstable branch by executing the following on the command line (this repo is not tested against stable)
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

## Add local_packages.nix for npkg

This file will be used by `npkg` to automatically add packages to your declarative configuration.

```
sudo cp local_packages.nix /etc/nixos/local_packages.nix
```

# Further TODO:
Basic Laptop requirements:
- [ ] Maybe a full fledged xmonad/qtile/etc. config
- [ ] Application launcher and stuff
- [ ] Fancy Terminal/Shell Setup
- [ ] Proper documentation
  - [x] Install (partitioning, etc.)
  - [ ] Configuration of Desktop
- [ ] A script which helps with the setup (or even an installer...)
