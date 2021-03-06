{ config, lib, pkgs, ... }:
let
  cfg = config.custom.laptop;
in

{
  options.custom.laptop.enable = lib.mkEnableOption "laptop config";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.acpi ];

    # Set a random MAC address for physical network interfaces.
    systemd.network.links."00-default" = {
      matchConfig.Type = "ether wlan wwan";
      linkConfig = {
        NamePolicy = "path kernel";
        MACAddressPolicy = "random";
      };
    };
  };
}
