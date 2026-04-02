# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, pkgs, ... }:
{
  # ┌─────────────────┐
  # │ GLOBAL OVERLAYS │
  # └─────────────────┘
  nixpkgs.overlays = [
    # inputs.neovim-nightly-overlay.overlays.default
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };

      nanum-square-neo = final.callPackage ./pkgs/nanum-square-neo.nix { };
      spoofdpi = final.callPackage ./pkgs/spoofdpi.nix { };
    })
  ];
}
