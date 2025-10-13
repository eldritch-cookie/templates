{
  description = "Description for the project";
  nixConfig.allow-import-from-derivation = true;

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #hu-nixpkgs.url = "github:NixOS/nixpkgs/haskell-updates";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haskell-flake.url = "github:srid/haskell-flake";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
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
              "packages"
            ];
            devShell = {
              tools = hp: { inherit (hp) haskell-dap; };
            };
            defaults.devShell.tools = hp: { inherit (hp) cabal-install haskell-language-server ghcide; };
          };
          id2 = self: super: { };
        in
        {
          treefmt.programs = {
            nixfmt.enable = true;
            statix.enable = true;

            cabal-fmt.enable = true;
            fourmolu = {
              enable = true;
              package = pkgs.haskell.packages.ghc912.fourmolu;
            };
            keep-sorted.enable = true;

            # jsonfmt.enable = true;
            # just.enable = true;
          };
          treefmt.projectRootFile = "flake.nix";
          pre-commit.settings = {
            hooks = {
              treefmt.enable = true;
              editorconfig-checker.enable = true;
            };
          };
          haskellProjects.ghc910 = hprojs pkgs.haskell.packages.ghc910 id2;
          haskellProjects.default = hprojs pkgs.haskell.packages.ghc912 id2;
          devShells.default = pkgs.mkShell {
            packages = [(pkgs.agda.withPackages (p: [p.standard-library]))]; # TODO: add agda2hs or remove haskell stuff
            packagesFrom = [config.haskellProjects.default.outputs.devShell];
            shellHook = config.pre-commit.installationScript;
          };
        };
      flake = { };
    };
}
