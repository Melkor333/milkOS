{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.grantos.home.CONFIG;
  home = config.grantos.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
  #home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  options.grantos.home.CONFIG = {
    enable = mkOption {
      type = types.bool;
      description = "enable CONFIG";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${home.user} = {
      # DO STUFF
    };
  };
}
