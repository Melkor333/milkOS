{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.grantos.laptop;
  mkSug = mkOverride 700;
in {
  options.grantos.laptop = {
    enable = mkOption {
      type = types.bool;
      description = "enable laptop";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # -------------------------------------
    # ACPI
    # TODO: Backlight changes don't currently work without root permissions
    services.acpid.enable = mkSug true;

    # -------------------------------------
    # Touchpad
    #services.xserver.synaptics.enable = mkSug false;
    services.xserver.libinput.enable = mkSug true;

    # -------------------------------------
    # Make sure hardware works
    hardware.enableAllFirmware = mkSug true;

    # -------------------------------------
    # Power Management
    powerManagement.enable = mkSug true;

    # -------------------------------------
    # Bluetooth
    hardware.bluetooth = {
      enable = mkSug true;
      package = mkSug pkgs.bluezFull;
      hsphfpd.enable = mkSug true;
    };
    services.blueman.enable = true;

    # This enables usb port sleep which is hella annoying
    #powerManagement.powertop.enable = mkSug false;

    #TODO: Maybe enable this:
    #services.xsettingsd.enable
    services.upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };

    # Packages for various stuff
    environment.systemPackages = [
      pkgs.powertop
    ];
  };
}
