{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk = {
    nvim.enable = mkOption {
      type = types.bool;
      description = "enable simple global nvim config";
      default = false;
    };
  };

  config = mkIf cfg.nvim.enable {
    environment.systemPackages = with pkgs; [
      (
        neovim.override {
          vimAlias = true;
          viAlias = true;
          configure = {
            packages.myPlugins = with pkgs.vimPlugins; {
              start = [vim-nix];
              opt = [];
            };
            customRC = ''
              " your custom vimrc
              set nocompatible
              set backspace=indent,eol,start
              set modeline
            '';
          };
        }
      )
    ];
  };
}
