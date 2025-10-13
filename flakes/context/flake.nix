{
  description = "Book using context";

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
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
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
          treefmt.programs = {
            nixfmt.enable = true;
            statix.enable = true;
            texfmt.enable = true;
          };
          #treefmt.projectRootFile = "flake.nix";
          pre-commit.settings.hooks = {
            treefmt.enable = true;
          };
          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [ texliveConTeXt ];
            shellHook = config.git-hooks.installationScript;
          };
        };
      flake = { };
    };
}
