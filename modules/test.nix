{
  flake-parts-lib,
  inputs,
  self,
  ...
}:
{
  flake.tests = {
    test-flake-parts-module = {
      expr = flake-parts-lib.mkFlake { inherit inputs; } {
        imports = [ ./flake-parts-module.nix ];
        systems = [ "x86_64-linux" ];
      };
    };
  };
}
