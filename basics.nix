{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk;
  mkSug = mkOverride 700;
in {
  options.milk = {
    basics = mkOption {
      type = types.bool;
      description = "enable various configs which just make sense";
      default = true;
    };
  };

  # If a module should be enabled per default, it should be enabled here
  config = mkIf cfg.basics {
    # -------------------------------------
    # Audio
    sound.enable = mkSug true;
    # TODO: Optionally enable/switch to pipewire
    hardware.pulseaudio.enable = mkSug true; # Alternative would pe pipewire

    # -------------------------------------
    # Boot Loader
    # Prevent a full boot partition. This happens way too quickly and often!
    # only 20 System configs.
    boot.loader.systemd-boot.configurationLimit = mkSug 20;
    boot.loader.grub.configurationLimit = mkSug 20;

    # -------------------------------------
    # Antivirus
    services.clamav = {
      daemon.enable = mkSug true;
      updater.enable = mkSug true;
    };

    # -------------------------------------
    # Dconf
    programs.dconf.enable = mkSug true;

    # -------------------------------------
    # Kernel
    hardware.cpu.intel.updateMicrocode = mkSug true;
    hardware.cpu.amd.updateMicrocode = mkSug true;

    # -------------------------------------
    # Networkmanager
    networking.networkmanager.enable = mkSug true;

    # -------------------------------------
    # Nix
    nix.settings.sandbox = mkSug true;
    nix.gc.automatic = mkSug true;
    nix.gc.dates = mkSug "weekly";
    # TODO: Blind copy pasta :)
    nix.gc.options = mkSug "--max-freed $((64 * 1024**3))";

    # -------------------------------------
    # Printing
    services.printing = {
      enable = true;
      # Just give me all the printerdrivers!
      drivers = with pkgs; [gutenprint gutenprintBin hplip splix brlaser brgenml1lpr brgenml1cupswrapper cnijfilter2];
    };
    services.avahi.enable = mkSug true;
    services.avahi.nssmdns = true;
    services.system-config-printer.enable = true;
    programs.system-config-printer.enable = true;

    # Scanning
    hardware.sane.enable = true;

    # -------------------------------------
    # USB
    # TODO: Maybe do the following? -> should probably be added to a "hardened" file
    #services.usbguard.enable = true;

    # -------------------------------------
    # Virtualisation
    virtualisation.libvirtd = {
      enable = mkSug true;
      onShutdown = mkSug "suspend";
      qemu.runAsRoot = mkSug false;
    };

    # -------------------------------------
    # XDG
    # Let firefox & co. use xdg instead of their own stuff
    # This is actually deprecated
    #xdg.portal.gtkUsePortal = true;
  };
}
