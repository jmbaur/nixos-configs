{
  description = "NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
    git-get.url = "github:jmbaur/git-get";
    gobar.url = "github:jmbaur/gobar";
    gosee.url = "github:jmbaur/gosee";
    neovim.url = "github:jmbaur/neovim";
    deadnix.url = "github:astro/deadnix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , deploy-rs
    , git-get
    , gobar
    , gosee
    , neovim
    , deadnix
    , home-manager
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let pkgs = import nixpkgs { inherit system; }; in
      {
        formatter = pkgs.nixpkgs-fmt;
      }) // {
      nixosModules = import ./modules {
        extraOverlays = [
          deadnix.overlays.default
          deploy-rs.overlay
          git-get.overlays.default
          gobar.overlays.default
          gosee.overlays.default
          neovim.overlays.default
        ];
        extraImports = [ home-manager.nixosModules.home-manager ];
      };
      overlays = import ./overlays;
    };
}
