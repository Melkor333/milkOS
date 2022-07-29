{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  imports = [
    ./nur.nix
    ./npkg.nix
    ./git.nix
    ./gpg.nix
    ./keepassxc
  ];

  options.milk.home = {
    enable = mkOption {
      type = types.bool;
      description = "enable home";
      default = false;
    };

    user = mkOption {
      type = types.str;
      description = "The username to be configured (currently only 1 user can be configured. Might change)";
    };

    fullName = mkOption {
      type = types.str;
      description = "The username to be configured (currently only 1 user can be configured. Might change)";
    };

    emailAddress = mkOption {
      type = types.str;
      description = "The username to be configured (currently only 1 user can be configured. Might change)";
    };
  };

  config = mkIf cfg.enable {
    milk.home.git.enable = mkSug true;
    milk.home.gpg.enable = mkSug true;
    milk.home.npkg.enable = mkSug true;
    milk.home.nur.enable = mkSug true;
    milk.home.keepassxc.enable = mkSug true;
    # Do Stuff
    home-manager.users.${cfg.user}.home.stateVersion = mkSug config.system.stateVersion;
    users.users.${cfg.user} = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "libvirtd"]; # Enable sudo
    };
  };
}
