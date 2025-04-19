# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
  self,
  inputs,
  nixpkgs,
  overlays,
}: {
  os,
  user,
  host,
  system,
  setupFunc,
  sysModules,
}:
assert builtins.pathExists ../wallpaper.jpeg;
assert (os == "darwin" && builtins.elem system self.darwinSystems)
|| (os == "nixos" && builtins.elem system self.nixosSystems);
  setupFunc {
    inherit system;

    modules =
      [
        {
          nix.settings.experimental-features = "nix-command flakes";
          nix.optimise.automatic = true;

          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnsupportedSystem = true;
          # nixpkgs.config.allowBroken = true;
        }
      ]
      ++ sysModules
      ++ [
        ../modules/${os}
      ];

    specialArgs = {
      inherit overlays inputs;
      env = {
        inherit
          os
          user
          host
          system
          ;
      };
    };
  }
