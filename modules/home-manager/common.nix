{ config, lib, pkgs, globalConfig, ... }:
let
  cfg = config.custom.common;
in
with lib; {
  options.custom.common = {
    enable = mkOption {
      type = types.bool;
      default = globalConfig.custom.common.enable;
    };
  };
  config = mkIf cfg.enable {
    home.stateVersion = globalConfig.system.stateVersion;

    nixpkgs.config.allowUnfree = true;

    home.shellAliases = {
      grep = "grep --color=auto";
    };

    home.packages = with pkgs; [
      gmni
      iperf3
      librespeed-cli
      nmap
      nvme-cli
      picocom
      pwgen
      rtorrent
      sl
      smartmontools
      sshfs
      stow
      tailscale
      tcpdump
      tree
      unzip
      usbutils
      w3m
      wireguard-tools
      zip
    ];

    programs.dircolors.enable = true;
  };
}
