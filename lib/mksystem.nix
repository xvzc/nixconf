# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  self,
  inputs,
  nixpkgs,
  overlays,
}:
{
  os,
  user,
  host,
  system,
  setupFunc,
  osModules,
}:
let
  nixSettings = import ../nix-settings.nix { inherit overlays; };
in
assert builtins.pathExists ../wallpaper.jpeg;
assert (os == "darwin" || "nixos");
assert (os == "darwin" && self.lib.hasInfix "darwin" system || os == "nixos");
setupFunc {
  inherit system;

  modules = self.lib.flatten [
    nixSettings
    osModules
    ../modules/${os}
    ../users/${user}.nix
  ];

  specialArgs = {
    inherit inputs;
    lib = self.lib;
    curEnv = {
      inherit
        os
        user
        host
        system
        ;
    };
  };
}
