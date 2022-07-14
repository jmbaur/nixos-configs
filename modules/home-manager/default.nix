{ config, ... }: {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { globalConfig = config; };
    sharedModules = [ ./common.nix ./dev.nix ./gui.nix ./laptop.nix ];
  };
}
