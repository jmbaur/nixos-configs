{
  description = "NixOS configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    deadnix.url = "github:astro/deadnix";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    git-get.url = "github:jmbaur/git-get";
    git-get.inputs.nixpkgs.follows = "nixpkgs";
    gobar.url = "github:jmbaur/gobar";
    gobar.inputs.nixpkgs.follows = "nixpkgs";
    gosee.url = "github:jmbaur/gosee";
    gosee.inputs.nixpkgs.follows = "nixpkgs";
    neovim.url = "github:jmbaur/neovim";
    neovim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      { formatter = pkgs.nixpkgs-fmt; }) // {
    nixosModules.default = {
      imports = [
        home-manager.nixosModules.home-manager
        ./modules
      ];
      nixpkgs.overlays = [
        deadnix.overlays.default
        git-get.overlays.default
        gobar.overlays.default
        gosee.overlays.default
        neovim.overlays.default
        self.overlays.default
      ];
    };
    overlays.default = import ./overlays;
  };
}
