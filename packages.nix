{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.milk;
  defaultPkgs = with pkgs;
    if cfg.defaultPkgs.enable
    then [
      # Basic CLI Utils
      git
      inetutils
      pciutils
      tmux
      wget
      zip
      unzip
      dnsutils
      ldns
      iotop
      iftop
      htop
      file
      pwgen
      dos2unix
      tree

      # Networking
      openvpn
      #networkmanager-openvpn
    ]
    else [];

  fancyPkgs = with pkgs;
    if cfg.fancyPkgs.enable
    then [
      bat # TODO: alias cat
      lsd # TODO: alias ls
      cht-sh # TODO: alias man
      neofetch
    ]
    else [];

  desktopPkgs = with pkgs;
    if cfg.desktopPkgs.enable
    then [
      firefox
      #google-chrome

      thunderbird

      libreoffice
      okular
      gimp

      mattermost-desktop

      pulseaudio
      # Borg backup frontend
      # TODO: Add Usage docs to Readme
      vorta
      gimp
      galculator
      gpick

      # Virtualisation
      virt-manager
      libguestfs
      # The following is over 500MB in size.
      #OVMFFull # Uefi boot
      barrier # Open source Uefi boot

      libsecret # secret-tool (usable with pass, keepassxc, *-keyring)
      libnotify # notify-send cmd utility
    ]
    else [];

  # MakeSuggestion
  mkSug = mkOverride 700;
in {
  options.milk = {
    defaultPkgs.enable = mkOption {
      type = types.bool;
      description = "enable sane default package set";
      default = false;
    };

    fancyPkgs.enable = mkOption {
      type = types.bool;
      description = "enable fancy package set";
      default = false;
    };

    desktopPkgs.enable = mkOption {
      type = types.bool;
      description = "enable desktop package set";
      default = false;
    };
  };

  config = {
    nixpkgs.overlays = [];
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = defaultPkgs ++ fancyPkgs ++ desktopPkgs;
    programs.mtr.enable = mkIf cfg.defaultPkgs.enable (mkSug true); # Ping & Traceroute
  };
}
