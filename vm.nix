{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.grantos;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.grantos.vm = {
    enable = mkOption {
      type = types.bool;
      description = "enable vm stuff. Stuff like guest-agent and stuff";
      default = false;
    };
    # Optionally add more options here:
  };

  config = mkIf cfg.vm.enable {
    # Do Stuff

    environment.systemPackages = with pkgs; [
      cloud-utils # growpart and stuff
    ];
    services.qemuGuest.enable = mkSug true;
    services.spice-vdagentd.enable = mkSug true;
  };
}
