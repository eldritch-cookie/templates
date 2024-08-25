{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haskell-flake.url = "github:srid/haskell-flake";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.haskell-flake.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        hprojs = hpkgs: overlay: {
          basePackages = hpkgs;
          otherOverlays = [overlay];
          autoWire = ["checks" "devShells" "packages"];
          devShell = {
            tools = hp: {inherit (hp) fast-tags haskell-dap;};
            mkShellArgs.shellHook = config.pre-commit.installationScript;
          };
        };
        id2 = self: super: {};
      in {
        treefmt.programs = {
          alejandra.enable = true;
          cabal-fmt.enable = true;
          ormolu = {
            enable = true;
            package = pkgs.haskellPackages.fourmolu;
          };
        };
        treefmt.projectRootFile = "flake.nix";
        pre-commit.settings = {
          hooks = {
            treefmt.enable = true;
            commitizen.enable = true;
            editorconfig-checker.enable = true;
          };
        };
        haskellProjects.default = hprojs pkgs.haskellPackages id2;
        haskellProjects.ghc98 = hprojs pkgs.haskell.packages.ghc98 id2;
        haskellProjects.ghc910 = hprojs pkgs.haskell.packages.ghc910 id2;
      };
      flake = {
      };
    };
}
