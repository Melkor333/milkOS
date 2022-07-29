{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.home.git;
  home = config.milk.home;
  # MakeSuggestion
  mkSug = mkOverride 700;
  #home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  options.milk.home.git = {
    enable = mkOption {
      type = types.bool;
      description = "enable git";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${home.user}.programs.git = {
      enable = true;
      # DO STUFF
      userEmail = mkSug home.emailAddress;
      userName = mkSug home.fullName;
      # TODO: If gpg is enabled, sign per default
      # signing = {
      #signByDefault = true;
      #key = ????;
      #};
    };
  };
}
