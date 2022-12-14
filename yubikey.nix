{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.yubikey;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk.yubikey = {
    enable = mkOption {
      type = types.bool;
      description = "enable yubikey packages";
      default = false;
    };
    # Optionally add more options here:
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Yubikey
      yubikey-manager
      yubikey-personalization
      yubikey-personalization-gui
      yubioath-desktop
    ];
    services.udev.packages = [pkgs.yubikey-personalization];
  };
}
