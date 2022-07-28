{
  config,
  lib,
  pkgs,
  ...
}:

with lib; let
  cfg = config.grantos.home.npkg;
  # MakeSuggestion
  mkSug = mkOverride 700;
  #pam_scripts = pkgs.callPackage ./pam_script.nix { };
  npkg_package = (pkgs.fetchFromGitHub { owner = "vlinkz"; repo = "npkg"; rev = "0.1.1"; sha256 = "sha256-pEsAh7MPNXtQYe2aPaPppdHAcHrctJRGAkP1TOwzaxs="; });
in {
  options.grantos.home.npkg = {
    enable = mkOption {
      type = types.bool;
      description = "enable the npkg config. this configures it so that the system path is proper";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # nixpkgs.overlays = mkIf cfg.managedConfigfile [ (final: prev: {
    #   firefox = prev.firefox.overrideAttrs (old: {
    #     propagatedBuildInputs = [ final.pkgs.keepassxc ];
    #   });
    # })];
    home-manager.users.${config.grantos.home.user} = {
      # TODO:
      home.packages = [npkg_package];

      # The config file
      home.file.".config/npkg/config.json".text = builtins.toJSON {
        systemconfig = "/etc/nixos/local_packages.nix";
        homeconfig = "/home/${config.grantos.home.user}/.config/nixpkgs/home.nix";
        flake = null;
      };
    };
  };
}
