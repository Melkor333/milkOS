{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.home.CONFIG;
  home = config.milk.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
  #home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  options.milk.home.CONFIG = {
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
