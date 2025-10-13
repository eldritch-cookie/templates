{
  description = "My Personal Templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          treefmt = {
            programs = {
              nixfmt.enable = true;
              statix.enable = true;
              cabal-fmt.enable = true;
              fourmolu = {
                enable = true;
                package = pkgs.haskell.packages.ghc912.fourmolu;
              };
              yamlfmt.enable = true;
              keep-sorted.enable = true;
            };
          };
        };
      flake = {
        templates = {
          default = self.templates.haskell;
          haskell = {
            path = ./flakes/haskell;
            description = "a template for a small haskell project";
          };
          agda = {
            path = ./flakes/agda;
            description = 
            "a template for a small agda project with haskell code";
          };
          context = {
            path = ./flakes/context;
            description = "a template for a small context project";
          };

        };
      };
    };
}
