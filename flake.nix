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
          hp = pkgs.haskell.packages.ghc912.extend (
            hfinal: hprev: {
              extra = hfinal.extra_1_8;
              Diff = hfinal.Diff_1_0_2;
              generic-deriving = hfinal.generic-deriving_1_14_6;
              ghc-lib-parser = hfinal.ghc-lib-parser_9_12_1_20241218;
              happy = hfinal.happy_2_1_3;
              hashable = hfinal.hashable_1_5_0_0;
              integer-logarithms = hfinal.integer-logarithms_1_0_4;
              QuickCheck = hfinal.QuickCheck_2_15_0_1;
              semirings = hfinal.semirings_0_7;
              tasty = hfinal.tasty_1_5_2;
              tasty-quickcheck = hfinal.tasty-quickcheck_0_11;
              th-abstraction = hfinal.th-abstraction_0_7_1_0;
              th-compat = hfinal.th-compat_0_1_6;
              witherable = hfinal.witherable_0_5;

              boring = pkgs.haskell.lib.doJailbreak hprev.boring;
              ChasingBottoms = pkgs.haskell.lib.doJailbreak hprev.ChasingBottoms;
              indexed-traversable = pkgs.haskell.lib.doJailbreak hprev.indexed-traversable; # NOTE: version 0.1.4 has bounds base >=4.12 && <4.21
              indexed-traversable-instances = pkgs.haskell.lib.doJailbreak hprev.indexed-traversable-instances; # NOTE: version 0.1.4 has bounds base >=4.12 && <4.21
              integer-conversion = pkgs.haskell.lib.doJailbreak hfinal.integer-conversion_0_1_1;
              newtype-generics = pkgs.haskell.lib.doJailbreak hprev.newtype-generics;
              optparse-applicative = pkgs.haskell.lib.doJailbreak hprev.optparse-applicative;
              path = pkgs.haskell.lib.doJailbreak hprev.path;
              quickcheck-instances = pkgs.haskell.lib.doJailbreak hfinal.quickcheck-instances_0_3_32;
              scientific = pkgs.haskell.lib.doJailbreak hfinal.scientific_0_3_8_0;
              semialign = pkgs.haskell.lib.doJailbreak hprev.semialign;
              strict = pkgs.haskell.lib.doJailbreak hprev.strict;
              text-iso8601 = pkgs.haskell.lib.doJailbreak hprev.text-iso8601;
              time-compat = pkgs.haskell.lib.doJailbreak hprev.time-compat;
              these = pkgs.haskell.lib.doJailbreak hprev.these;
              uuid-types = pkgs.haskell.lib.doJailbreak hfinal.uuid-types_1_0_6;

              alex = pkgs.haskell.lib.dontCheck hprev.alex_3_5_1_0;
              doctest = pkgs.haskell.lib.dontCheck hfinal.doctest_0_23_0;
              unordered-containers = pkgs.haskell.lib.dontCheck hprev.unordered-containers;

              aeson = pkgs.haskell.lib.doJailbreak (pkgs.haskell.lib.dontCheck hfinal.aeson_2_2_3_0); # nothunks is used in the test suite
              fourmolu = pkgs.haskell.lib.dontCheck (
                hfinal.callHackageDirect {
                  pkg = "fourmolu";
                  ver = "0.18.0.0";
                  sha256 = "sha256-fnzuSyxB2k/i7f/cXEiUIgwtFoKe2fKsXPGXlEwAG/0=";
                } { }
              );
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
