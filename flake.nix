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
              primitive = hprev.primitive_0_9_0_0;
              th-abstraction = hprev.th-abstraction_0_7_0_0;
              fourmolu = pkgs.haskell.lib.dontCheck hprev.fourmolu_0_16_2_0;
              base-orphans = pkgs.haskell.lib.dontCheck hprev.base-orphans;
              call-stack = pkgs.haskell.lib.dontCheck hprev.call-stack;
              time-compat = pkgs.haskell.lib.doJailbreak hprev.time-compat;
              uuid-types = hprev.uuid-types_1_0_6;
              scientific = hprev.scientific_0_3_8_0;
              unordered-containers = pkgs.haskell.lib.dontCheck hprev.unordered-containers;
              quickcheck-instances = hprev.quickcheck-instances_0_3_31;
              aeson = pkgs.haskell.lib.dontCheck hprev.aeson_2_2_3_0;
              integer-conversion = hprev.integer-conversion_0_1_1;
              hashable = pkgs.haskell.lib.dontCheck (hprev.hashable_1_5_0_0.override { os-string = null; });
              strict = hprev.strict_0_5_1;
              witherable = hprev.witherable_0_5;
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
