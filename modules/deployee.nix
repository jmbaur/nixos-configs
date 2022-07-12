{ config, lib, ... }:
let
  cfg = config.custom.deployee;
in
with lib;
{
  options.custom.deployee = {
    enable = mkEnableOption "Make this machine a deploy target";
    authorizedKeyFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = (cfg.authorizedKeyFiles != [ ]);
      message = "No authorized keys configured for deployee";
    }];

    services.openssh = {
      enable = true;
      listenAddresses = [ ];
    };

    users.users.root.openssh.authorizedKeys.keyFiles = cfg.authorizedKeyFiles;
  };
}
