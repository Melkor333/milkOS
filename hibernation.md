## Warning! NixOS doesn't work *that* well with hibernation. If you upgrade your config and select the wrong boot entry after hibernation you can lose data or break your installation!

The following guide explains swap & Hibernation configuration on btrfs

### Configure Swap for hibernation


For the following, the `count=` must be **at least** as much as you have ram. Your ram will be written to the swapfile on hibernate. To be ultrasave, you can double your total memory (if you have enough storage...)

```
free -m
              total        used        free      shared  buff/cache   available
Mem:          31723         293       30888          33         541       31021
Swap:             0           0           0

mkdir /mnt/swap
mount /dev/mapper/linux -o subvol=@swap /mnt/swap
touch /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile # disable copy on write
chmod 600 /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=63446
mkswap /mnt/swap/swapfile
```

## Setup swap hibernation & boot
First, find out the place of the swapfile
```
filefrag -v /mnt/swap/swapfile
Filesystem type is: 9123683e
File size of /mnt/swap/swapfile is 66527952896 (16242176 blocks of 4096 bytes)
 ext:     logical_offset:        physical_offset: length:   expected: flags:
   0:        0..  229375:      16400..    245775: 229376:
   1:   229376..16242175:     267520..  16280319: 16012800:     245776: last,eof
/mnt/swap/swapfile: 2 extents found
```
In the above output, the relevan number is `16400` (the first physical_offset with the two .. at the end).
change your `/mnt/etc/nixos/hardware-configuration.nix` and add the following. change the offset number and remove the already existing line `swapDevices = []`:
```
  boot.kernelParams = [ "resume_offset=16400" ] # CHANGE THIS NUMBER ACCORDINGLY
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 1024 * 32 * 2; # Twice the ram size is enough for hibernate
    }
  ];
```

Also add the following. The first uuid is the one listed in `ls -lah /dev/disk/by-uuid/` pointing to the first partition of your disk (e.g. nvme0n1p1). The second one is the same as already in the file under `fileSystems."/"`:
```
  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-uuid/41451240-5e03-474c-9368-8a6b91c8b134";
  boot.resumeDevice = "/dev/disk/by-uuid/d5e2901f-b854-4365-9d87-f1a2bc988dc5";

  ######## The following should already exist and is just here for reference
  ##########################################################################
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d5e2901f-b854-4365-9d87-f1a2bc988dc5";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };
  ##########################################################################

```
Modify the line to contain `"dm-snapshot"`:
```
  boot.initrd.kernelModules = [ "dm-snapshot" ];
```
