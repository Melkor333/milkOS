{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.grantos;
  mkSug = mkOverride 700;
  #nixos-boot = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
  imports = [
    ./basics.nix
    ./home
    ./laptop.nix
    ./nvim.nix
    ./packages.nix
    ./yubikey.nix
    ./vm.nix # OK
    /etc/nixos/local_packages.nix
  ];

  meta.maintainers = with maintainers; [melkor333];

  options.grantos = {
    enable = mkOption {
      type = types.bool;
      description = "enable the grantos package and therefore some basics";
      default = true;
    };
  };

  # If a module should be enabled per default, it should be enabled here
  config = mkIf cfg.enable {
    # NUR (~ AUR)
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
    # TODO: make some function which adds the `mkDefault`
    grantos.nvim.enable = mkDefault true; # OK
    grantos.basics = mkDefault true; # OK
    grantos.defaultPkgs.enable = mkDefault true;
  };
}
