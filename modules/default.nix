{ extraOverlays ? [ ]
, extraImports ? [ ]
, ...
}:

{
  default = { config, lib, ... }: {
    imports = [
      ./common.nix
      ./deployee.nix
      ./deployer.nix
      ./dev.nix
      ./gui.nix
      ./home-manager
      ./remote-boot.nix
    ] ++ extraImports;
    nixpkgs.overlays = extraOverlays ++ (lib.mapAttrsToList
      (_: v: v)
      (import ../overlays));
  };
}
