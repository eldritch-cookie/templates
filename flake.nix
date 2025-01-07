{
  description = "My Personal Templates";

  inputs = {
    nixpkgs.url = "nixpkgs";
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
      imports = [ inputs.treefmt-nix.flakeModule ];
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
        let
          hp = pkgs.haskell.packages.ghc910.extend (
            hfinal: hprev: {
            }
          );
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              cabal-fmt.enable = true;
              fourmolu = {
                enable = true;
                package = hp.fourmolu;
              };
              yamlfmt.enable = true;
            };
            settings = {
              global.excludes = [ ".git/" ];
            };
          };
        };
      flake = {
        templates.default = {
          path = ./starter/haskell;
          description = "a template for a small haskell project";
        };
      };
    };
}
