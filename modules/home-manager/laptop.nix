{ config, lib, globalConfig, ... }:
{
  options.custom.laptop.enable = lib.mkOption {
    type = lib.types.bool;
    default = globalConfig.custom.laptop.enable;
  };
}
