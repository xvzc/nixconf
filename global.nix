# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, pkgs, ... }:
{
  nix.optimise.automatic = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

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
