{
  description = "NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
    deadnix.url = "github:astro/deadnix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    git-get.url = "github:jmbaur/git-get";
    git-get.inputs.nixpkgs.follows = "nixpkgs";
    gobar.url = "github:jmbaur/gobar";
    gobar.inputs.nixpkgs.follows = "nixpkgs";
    gosee.url = "github:jmbaur/gosee";
    gosee.inputs.nixpkgs.follows = "nixpkgs";
    neovim.url = "github:jmbaur/neovim";
    neovim.inputs.nixpkgs.follows = "nixpkgs";
    tempus-themes.url = "gitlab:protesilaos/tempus-themes";
    tempus-themes.flake = false;
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-wayland
    , flake-utils
    , deploy-rs
    , git-get
    , gobar
    , gosee
    , neovim
    , deadnix
    , home-manager
    , tempus-themes
    , ...
    }: flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
      }) // {
      nixosModules = import ./modules {
        extraOverlays = [
          (final: prev: {
            tempus-themes = prev.stdenv.mkDerivation {
              name = "tempus-themes";
              src = tempus-themes;
              installPhase = "mkdir -p $out && cp -r . $out";
            };
          })
          deadnix.overlays.default
          deploy-rs.overlay
          git-get.overlays.default
          gobar.overlays.default
          gosee.overlays.default
          neovim.overlays.default
          nixpkgs-wayland.overlays.default
        ];
        extraImports = [ home-manager.nixosModules.home-manager ];
      };
      overlays = import ./overlays;
    };
}
