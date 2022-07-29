{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.CONFIG;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk.CONFIG = {
    enable = mkOption {
      type = types.bool;
      description = "enable CONFIG";
      default = false;
    };
    # Optionally add more options here:
  };

  config = mkIf cfg.enable {
    # Do Stuff
  };
}
