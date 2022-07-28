{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.grantos.home.gpg;
  home = config.grantos.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.grantos.home.gpg = {
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
