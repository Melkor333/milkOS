{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.home.nur;
  home = config.milk.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk.home.nur = {
    enable = mkOption {
      type = types.bool;
      description = "enable the nur repository for the user nix-env";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${home.user}.home.file.".config/nixpkgs/config.nix".text = ''
      {
        packageOverrides = pkgs: {
            nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
                  inherit pkgs;
            };
        };
        allowUnfree = true;
      }
    '';
  };
}
