{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.home.gpg;
  home = config.milk.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk.home.gpg = {
    enable = mkOption {
      type = types.bool;
      description = "enable gpg agent";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${home.user} = {
      programs.gpg.enable = true;
    };
  };
}
