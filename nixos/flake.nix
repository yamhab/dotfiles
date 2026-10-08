{
  inputs = {
    lanzaboote = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/lanzaboote";
    };
    mangowm = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mangowm/mango";
    };
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };
    nixos-hardware = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:NixOS/nixos-hardware";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    inputs@{
      lanzaboote,
      mangowm,
      nix-index-database,
      nixos-hardware,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations.phobos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          lanzaboote.nixosModules.lanzaboote
          mangowm.nixosModules.mango
          nix-index-database.nixosModules.default
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
