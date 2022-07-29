{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk.home.keepassxc;
  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk.home.keepassxc = {
    enable = mkOption {
      type = types.bool;
      description = "enable keepassxc. This adds keepassxc as a startupservice and makes it secret-tool, etc.";
      default = false;
    };

    managedConfigfile = mkOption {
      type = types.bool;
      description = "If the configfile for keepassxc should be managed by nix (and therefore be readonly)";
      default = true;
    };

    config = mkOption {
      type = types.lines;
      description = "The config File of keepassxc. Default enables browser, secret service, etc. integration";
      default = builtins.readFile ./keepassxc.ini;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.keepassxc];
    home-manager.users.${config.milk.home.user} = {
      home.packages = [pkgs.keepassxc];
      programs.firefox.extensions = with pkgs.nur.repos.rycee.firefox-addons;
        mkIf config.home-manager.users.${config.milk.home.user}.programs.firefox.enable [
          keepassxc-browser
        ];

      # KeepassXC config
      systemd.user.services.keepassxc = {
        Unit = {
          Description = "KeePassXC password manager";
          After = ["graphical-session-pre.target" "ssh-agent.service"];
          PartOf = ["graphical-session.target"];
        };

        Install = {WantedBy = ["graphical-session.target"];};

        Service = {
          ExecStart = "${pkgs.keepassxc}/bin/keepassxc --lock";
          Type = mkIf cfg.managedConfigfile "dbus";
          BusName = mkIf cfg.managedConfigfile "org.freedesktop.secrets";
        };
      };
      home.file.".config/keepassxc/keepassxc.ini".text = mkIf cfg.managedConfigfile cfg.config;
    };
  };
}
