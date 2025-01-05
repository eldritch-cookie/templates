{
  description = "Description for the project";

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
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haskell-flake.url = "github:srid/haskell-flake";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.haskell-flake.flakeModule
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
        let
          hprojs = hpkgs: overlay: {
            basePackages = hpkgs;
            otherOverlays = [ overlay ];
            autoWire = [
              "checks"
              "devShells"
              "packages"
            ];
            devShell = {
              tools = hp: { inherit (hp) haskell-dap; };
              mkShellArgs.shellHook = config.pre-commit.installationScript;
            };
            defaults.devShell.tools = hp: { inherit (hp) cabal-install haskell-language-server ghcide; };
          };
          id2 = self: super: { };
        in
        {
          treefmt.programs = {
            nixfmt-rfc-style.enable = true;
            cabal-fmt.enable = true;
            fourmolu.enable = true;
          };
          treefmt.projectRootFile = "flake.nix";
          pre-commit.settings = {
            hooks = {
              treefmt.enable = true;
              commitizen.enable = true;
              editorconfig-checker.enable = true;
            };
          };
          haskellProjects.ghc96 = hprojs pkgs.haskell.packages.ghc96 id2;
          haskellProjects.default = hprojs pkgs.haskell.packages.ghc910 id2;
          haskellProjects.ghc912 = hprojs pkgs.haskell.packages.ghc912 id2;
        };
      flake = { };
    };
}
