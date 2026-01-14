# Original src: https://github.com/Misterio77/nix-config/blob/main/overlays/default.nix
{ inputs, ... }:
{
  # ┌─────────────────┐
  # │ GLOBAL OVERLAYS │
  # └─────────────────┘
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
}
