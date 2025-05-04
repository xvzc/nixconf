{
  inputs,
  nixpkgs,
}:
{
  system,
  profile,
  ...
}@args:
let
  lib = nixpkgs.lib;
  ctx = import ./mkcontext.nix { inherit nixpkgs args; };
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs { inherit system; };

  useGlobalPkgs = true;
  useUserPackages = true;
  extraSpecialArgs = { inherit ctx; };
  modules = lib.lists.flatten [
    ../configuration.nix
    ../profiles/${profile}/home/${ctx.os}.nix
  ];
}
